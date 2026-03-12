# 🎨 AutoBrand Director

> **Your AI Creative Director** — Describe your brand and get a full marketing campaign with AI-generated visuals, slogans, storyboards, and social media assets in one seamless flow.

**Gemini Live Agent Challenge** · *Creative Storyteller Category*

---

## ✨ What It Does

AutoBrand Director is a **multimodal AI agent** that acts as your personal creative director. Give it a brand brief (text + optional image), and it generates a **complete marketing campaign** with interleaved text and AI-generated images in a single response:

- 🎯 **Campaign Slogan & Tagline**
- 🖼️ **AI-Generated Hero Visual** (actual image, not a description)
- 📖 **Brand Story** narrative
- 📸 **AI-Generated Social Media Visual**
- 📝 **Instagram Caption** with hashtags
- 🎬 **30-Second Video Storyboard**
- 🎙️ **Voiceover Script**

This breaks the "text box" paradigm — the AI **sees** your brand assets, **creates** visual content, and **writes** compelling copy, all woven together in one fluid, interleaved output stream.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                        │
│  ┌──────────┐  ┌──────────────┐  ┌─────────────────────┐   │
│  │  Login    │→ │ Campaign     │→ │ Chat UI with        │   │
│  │  (Auth)   │  │ Brief Input  │  │ Interleaved Output  │   │
│  └──────────┘  └──────────────┘  └─────────────────────┘   │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS (REST API)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│               Google Cloud Run (Backend)                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │          Express.js API Server (Node.js)              │    │
│  │                                                       │    │
│  │  POST /generate-campaign  →  Gemini 2.0 Flash        │    │
│  │  GET  /campaigns/:uid     →  Firestore Query         │    │
│  └────────────┬──────────────────┬──────────────────────┘    │
│               │                  │                            │
│       ┌───────▼───────┐  ┌──────▼──────────┐                │
│       │ Gemini 2.0    │  │ Cloud Firestore  │                │
│       │ Flash (GenAI  │  │ (Campaign Data)  │                │
│       │ SDK) - Text + │  └─────────────────┘                │
│       │ Image Gen     │                                      │
│       └───────┬───────┘  ┌──────────────────┐               │
│               │          │ Cloud Storage     │               │
│               └─────────►│ (Generated Images)│               │
│                          └──────────────────┘               │
└─────────────────────────────────────────────────────────────┘

Google Cloud Services Used:
  • Cloud Run          — Hosts the Express.js backend
  • Cloud Firestore    — Stores campaign data per user
  • Cloud Storage      — Stores AI-generated images
  • Gemini 2.0 Flash   — Interleaved text + image generation
  • Firebase Auth      — User authentication
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **AI Model** | Gemini 2.0 Flash (`gemini-2.0-flash-exp`) with `responseModalities: ["Text", "Image"]` |
| **AI SDK** | `@google/genai` (Google GenAI SDK for Node.js) |
| **Backend** | Express.js on Node.js 20+, deployed on **Google Cloud Run** |
| **Frontend** | Flutter (Dart) — cross-platform mobile app |
| **Auth** | Firebase Authentication (email/password) |
| **Database** | Cloud Firestore |
| **Storage** | Google Cloud Storage (for generated images) |
| **IaC** | `deploy.sh` — automated Cloud Run deployment script |

---

## 🚀 Spin-Up Instructions

### Prerequisites

- [Node.js 20+](https://nodejs.org/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install)
- A [Gemini API Key](https://aistudio.google.com/apikey)
- A Firebase project with Auth and Firestore enabled

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/hackathons.git
cd hackathons
```

### 2. Backend Setup

```bash
cd functions

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Edit .env and set your GEMINI_API_KEY and BUCKET_NAME

# Run locally
npm run dev
# Server starts at http://localhost:8080
```

**Environment Variables:**

| Variable | Description |
|----------|-------------|
| `GEMINI_API_KEY` | Your Gemini API key from [AI Studio](https://aistudio.google.com/apikey) |
| `BUCKET_NAME` | Your Google Cloud Storage bucket (e.g., `your-project.firebasestorage.app`) |
| `PORT` | Server port (defaults to `8080`) |

### 3. Frontend Setup

```bash
cd "AutoBrand Director"

# Install Flutter dependencies
flutter pub get

# Update the API URL in lib/pages/campaign_page.dart
# Change "http://10.0.2.2:8080" to your backend URL

# Run on emulator or device
flutter run
```

### 4. Deploy to Google Cloud (Production)

```bash
cd functions

# Set your API key
export GEMINI_API_KEY="your-api-key-here"

# Deploy (requires gcloud CLI authenticated)
chmod +x deploy.sh
./deploy.sh
```

The script will:

1. Enable all required Google Cloud APIs
2. Build a Docker container with Cloud Build
3. Deploy to Cloud Run
4. Print the live service URL

---

## 📂 Project Structure

```
hackathons/
├── functions/                    # Backend (Express.js)
│   ├── index.js                  # API server + Gemini integration
│   ├── package.json              # Dependencies
│   ├── Dockerfile                # Cloud Run container
│   ├── deploy.sh                 # Automated deployment (IaC)
│   └── .env                      # Environment variables (not committed)
│
├── AutoBrand Director/           # Frontend (Flutter)
│   ├── lib/
│   │   ├── main.dart             # App entry + theme
│   │   ├── home.dart             # Auth gate
│   │   ├── Authentification/     # Login page
│   │   ├── pages/                # Campaign page
│   │   ├── models/               # Data models
│   │   ├── services/             # API service
│   │   └── widgets/              # Chat UI components
│   └── pubspec.yaml
│
├── firebase.json                 # Firebase config
└── README.md                     # This file
```

---

## 🏆 Hackathon Category: Creative Storyteller

AutoBrand Director is a **Creative Storyteller** agent that:

- ✅ Uses **Gemini's interleaved/mixed output** capabilities (text + generated images in one response)
- ✅ Built with **Google GenAI SDK** (`@google/genai`)
- ✅ Backend hosted on **Google Cloud Run**
- ✅ Uses **Cloud Firestore** and **Cloud Storage** (Google Cloud services)
- ✅ **Multimodal input**: accepts text briefs + brand images
- ✅ **Multimodal output**: generates text copy + visual assets seamlessly
- ✅ Automated deployment via **infrastructure-as-code** (bonus)

---

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.

---

*Built for the [Gemini Live Agent Challenge](https://devpost.com/hackathons) hackathon.*
