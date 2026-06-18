from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/health", tags=["System"])
def health_check():
    return {
        "status": "ok",
        "version": "4.0.0",
        "timestamp": datetime.utcnow().isoformat(),
    }
