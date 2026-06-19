---
title: AgroCure API
emoji: 🌱
colorFrom: green
colorTo: yellow
sdk: docker
app_port: 7860
pinned: false
---

# AgroCure API

FastAPI backend for the AgroCure app — a two-stage hierarchical plant-disease
classifier (EfficientNetV2-S) covering 16 plants and 30 diseases, plus "Sage",
an OpenAI-powered plant-care companion.

## Endpoints
- `GET /health` — service status
- `GET /classes` — all supported plant/disease classes
- `POST /predict` — multipart image upload → diagnosis
- `POST /chat` — Sage chat (requires the `OPENAI_API_KEY` Space secret)

Interactive docs at `/docs`.
