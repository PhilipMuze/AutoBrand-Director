import { Storage } from "@google-cloud/storage";
import { GoogleGenAI } from "@google/genai";
import cors from "cors";
import "dotenv/config";
import express from "express";
import admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";

// ── Firebase & Cloud Setup ──────────────────────────────────────────────────
admin.initializeApp();
const db = admin.firestore();
const storage = new Storage();
const bucket = storage.bucket(
    process.env.BUCKET_NAME
);

// ── Express ─────────────────────────────────────────────────────────────────
const app = express();
app.use(cors());
app.use(express.json({ limit: "20mb" }));

// ── Gemini Setup ─────────────────────────────────────────────────────────────
const genAI = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY,
});

const CAMPAIGN_SYSTEM_PROMPT = `You are AutoBrand Director — an elite AI Creative Director.

When given a campaign brief you MUST produce a COMPLETE marketing campaign that 
seamlessly interleaves text AND generated images in a single response.

Your response must include ALL of the following sections with actual generated 
images inline (not image descriptions):

1. **Campaign Slogan & Tagline** – bold, memorable, on-brand
2. **Hero Visual** – GENERATE an actual image that captures the brand essence
3. **Brand Story** – a short narrative (2-3 paragraphs)
4. **Social Media Post Visual** – GENERATE an Instagram-ready image
5. **Instagram Caption** with relevant hashtags
6. **30-Second Video Storyboard** – describe 3-4 key frames
7. **Voiceover Script** – the narration for the video

Make the generated images professional, vibrant, and visually stunning.
Weave the text and images together fluidly — this is interleaved multimodal output.`;

// ── Helper: Upload base64 image to Cloud Storage ────────────────────────────
async function uploadImageToStorage(base64Data, mimeType, sessionId, index) {
    const extension = mimeType.split("/")[1] || "png";
    const filename = `campaigns/${sessionId}/generated_${index}.${extension}`;
    const file = bucket.file(filename);

    const buffer = Buffer.from(base64Data, "base64");
    await file.save(buffer, {
        metadata: { contentType: mimeType },
        public: true,
    });

    return `https://storage.googleapis.com/${bucket.name}/${filename}`;
}

// ── Helper: Parse Gemini response parts into a storable format ──────────────
// Only stores storageUrl (no raw base64) to avoid Firestore size/nesting limits
async function parseResponseParts(parts, sessionId) {
    const output = [];
    let imageIndex = 0;

    for (const part of parts) {
        if (part.text) {
            output.push({ text: part.text });
        } else if (part.inlineData) {
            try {
                const url = await uploadImageToStorage(
                    part.inlineData.data,
                    part.inlineData.mimeType,
                    sessionId,
                    imageIndex++
                );
                // ✅ Only store the URL + mimeType, never raw base64
                output.push({
                    storageUrl: url,
                    mimeType: part.inlineData.mimeType,
                });
            } catch (err) {
                console.error("Image upload failed:", err.message);
                // Skip failed images rather than storing broken base64
            }
        }
    }

    return output;
}

// ── POST /generate-campaign ─────────────────────────────────────────────────
app.post("/generate-campaign", async (req, res) => {
    const { uid, prompt, image_base64 } = req.body;

    if (!uid) {
        return res.status(400).json({ error: "uid is required" });
    }
    if (!prompt) {
        return res.status(400).json({ error: "prompt is required" });
    }

    const sessionId = uuidv4();

    try {
        // Build the user content parts
        const userParts = [{ text: prompt }];

        // Add image part if provided (multimodal input)
        if (image_base64) {
            let base64str = image_base64;
            let mimeType = "image/jpeg";
            if (image_base64.startsWith("data:")) {
                const segments = image_base64.split(",");
                mimeType = segments[0].split(":")[1].split(";")[0];
                base64str = segments[1];
            }
            userParts.push({
                inlineData: {
                    data: base64str,
                    mimeType: mimeType,
                },
            });
        }

        // Call Gemini with interleaved text + image output
        const response = await genAI.models.generateContent({
            model: "gemini-3.1-flash-image-preview",
            contents: [
                {
                    role: "user",
                    parts: userParts,
                },
            ],
            config: {
                systemInstruction: CAMPAIGN_SYSTEM_PROMPT,
                responseModalities: ["TEXT", "IMAGE"],
                temperature: 0.8,
                maxOutputTokens: 8192,
            },
        });

        // Parse response — interleaved text and generated images
        const rawParts = response.candidates?.[0]?.content?.parts || [];
        const output = await parseResponseParts(rawParts, sessionId);

        const campaignData = {
            uid,
            prompt,
            output,
            hasImage: !!image_base64,
            hasGeneratedImages: output.some((p) => p.storageUrl),
            model: "gemini-3.1-flash-image-preview",
            createdAt: new Date().toISOString(),
        };

        await db.collection("campaigns").doc(sessionId).set(campaignData);

        res.json({
            sessionId,
            ...campaignData,
        });
    } catch (error) {
        console.error("Generation failed:", error);
        res.status(500).json({
            error: "Generation failed",
            details: error.message,
        });
    }
});

// ── GET /campaigns/:uid ─────────────────────────────────────────────────────
app.get("/campaigns/:uid", async (req, res) => {
    const { uid } = req.params;

    if (!uid) {
        return res.status(400).json({ error: "uid is required" });
    }

    try {
        const snapshot = await db
            .collection("campaigns")
            .where("uid", "==", uid)
            .orderBy("createdAt", "desc")
            .get();

        const campaigns = [];
        snapshot.forEach((doc) => {
            campaigns.push({
                id: doc.id,
                ...doc.data(),
            });
        });

        res.json(campaigns);
    } catch (error) {
        console.error("Error fetching campaigns:", error);
        res.status(500).json({
            error: "Failed to fetch campaigns",
            details: error.message,
        });
    }
});

// ── Health check ────────────────────────────────────────────────────────────
app.get("/", (_req, res) => {
    res.json({
        service: "AutoBrand Director API",
        status: "healthy",
        model: "gemini-3.1-flash-image-preview",
        version: "2.0.0",
    });
});

// ── Start server ────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 8080;
app.listen(PORT, () =>
    console.log(`🚀 AutoBrand Director API running on port ${PORT}`)
);