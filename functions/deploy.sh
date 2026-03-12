#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# AutoBrand Director — Automated Cloud Run Deployment Script
# Infrastructure-as-Code for the Gemini Live Agent Challenge (bonus points)
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
PROJECT_ID="${GCP_PROJECT_ID:-pgmhackathons}"
REGION="${GCP_REGION:-us-central1}"
SERVICE_NAME="autobrand-director-api"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

# Required environment variables for the Cloud Run service
GEMINI_API_KEY="${GEMINI_API_KEY:?Error: GEMINI_API_KEY environment variable is required}"
BUCKET_NAME="${BUCKET_NAME:-${PROJECT_ID}.firebasestorage.app}"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        AutoBrand Director — Cloud Run Deployment            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Project:  ${PROJECT_ID}"
echo "  Region:   ${REGION}"
echo "  Service:  ${SERVICE_NAME}"
echo "  Image:    ${IMAGE_NAME}"
echo ""

# ── Step 1: Set project ──────────────────────────────────────────────────────
echo "▶ Setting active project..."
gcloud config set project "${PROJECT_ID}"

# ── Step 2: Enable required APIs ─────────────────────────────────────────────
echo "▶ Enabling required Google Cloud APIs..."
gcloud services enable \
    run.googleapis.com \
    cloudbuild.googleapis.com \
    containerregistry.googleapis.com \
    firestore.googleapis.com \
    storage.googleapis.com \
    aiplatform.googleapis.com \
    generativelanguage.googleapis.com

# ── Step 3: Build container image ────────────────────────────────────────────
echo "▶ Building container image with Cloud Build..."
gcloud builds submit \
    --tag "${IMAGE_NAME}" \
    --timeout=600

# ── Step 4: Deploy to Cloud Run ──────────────────────────────────────────────
echo "▶ Deploying to Cloud Run..."
gcloud run deploy "${SERVICE_NAME}" \
    --image "${IMAGE_NAME}" \
    --region "${REGION}" \
    --platform managed \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 10 \
    --timeout 300 \
    --set-env-vars "GEMINI_API_KEY=${GEMINI_API_KEY},BUCKET_NAME=${BUCKET_NAME},GOOGLE_CLOUD_PROJECT=${PROJECT_ID}"

# ── Step 5: Get service URL ──────────────────────────────────────────────────
SERVICE_URL=$(gcloud run services describe "${SERVICE_NAME}" \
    --region "${REGION}" \
    --format "value(status.url)")

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   ✅ Deployment Complete!                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Service URL: ${SERVICE_URL}"
echo ""
echo "  Test with:"
echo "    curl ${SERVICE_URL}/"
echo ""
echo "  Update your Flutter app's baseUrl to:"
echo "    ${SERVICE_URL}"
echo ""
