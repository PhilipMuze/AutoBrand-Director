# ── Build stage ──────────────────────────────────────────────────────────────
FROM node:20-slim AS builder

WORKDIR /app

# Copy dependency manifests and install
COPY package.json package-lock.json* ./
RUN npm ci --only=production --legacy-peer-deps
# ── Run stage ────────────────────────────────────────────────────────────────
FROM node:20-slim

WORKDIR /app

# Copy installed dependencies
COPY --from=builder /app/node_modules ./node_modules

# Copy application source
COPY package.json index.js ./

# Cloud Run injects PORT env var (default 8080)
ENV PORT=8080
EXPOSE 8080

# Run as non-root for security
USER node

CMD ["node", "index.js"]
