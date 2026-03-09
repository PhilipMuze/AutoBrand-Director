import { Storage } from "@google-cloud/storage";
import { GoogleGenAI } from "@google/genai";
import cors from "cors";
import express from "express";
import admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";

admin.initializeApp();
const db = admin.firestore();

const storage = new Storage();
const bucket = storage.bucket(process.env.BUCKET_NAME);

const app = express();
app.use(cors());
app.use(express.json());

const genAI = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY
});

app.post("/generate-campaign", async (req, res) => {
    const { uid, prompt } = req.body;
    const sessionId = uuidv4();

    try {
        // genAI.models.generateContentStream()
        const response = await genAI.models.generateContent({
            model: "gemini-1.5-pro",
            contents: [
                {
                    role: "user",
                    parts: [
                        {
                            text: `
You are an elite Creative Director AI.

Generate a full marketing campaign with:
- Campaign slogan
- Brand story
- Inline generated image description
- 30-second video storyboard
- Voiceover script
- Instagram caption with hashtags

Use interleaved multimodal output.
User brief:
${prompt}
`
                        }
                    ]
                }
            ],
            generationConfig: {
                temperature: 0.8,
                maxOutputTokens: 4096
            }
        });

        const output = response.candidates[0].content.parts;

        await db.collection("campaigns").doc(sessionId).set({
            uid,
            prompt,
            output,
            createdAt: new Date()
        });

        res.json({
            sessionId,
            output
        });

    } catch (error) {
        console.error(error);
        res.status(500).send("Generation failed");
    }
});

app.listen(8080, () => console.log("Server running"));