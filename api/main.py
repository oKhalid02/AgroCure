import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src", "models"))

from dotenv import load_dotenv
load_dotenv()  # read OPENAI_API_KEY etc. from the project-root .env file

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.routes import predict, health, classes, chat

app = FastAPI(
    title="AgroCure API",
    description="Plant disease classification — Stage 1 (plant) → Stage 2 (disease)",
    version="4.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(predict.router)
app.include_router(classes.router)
app.include_router(chat.router)
