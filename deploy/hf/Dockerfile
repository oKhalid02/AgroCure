# AgroCure API — Hugging Face Space (Docker SDK)
# Serves the two-stage plant-disease model + Sage chat on port 7860.
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/tmp/hf

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Application code + trained model weights
COPY api ./api
COPY src ./src
COPY checkpoints ./checkpoints

EXPOSE 7860
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "7860"]
