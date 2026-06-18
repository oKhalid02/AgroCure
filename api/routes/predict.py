import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "models"))

from fastapi import APIRouter, UploadFile, File, HTTPException
from PIL import Image
import io

router = APIRouter()

# Load model once at startup
_pipeline = None

def get_pipeline():
    global _pipeline
    if _pipeline is None:
        import inference_v4
        _pipeline = inference_v4.AgroCureV4()
    return _pipeline

@router.post("/predict", tags=["Prediction"])
async def predict(file: UploadFile = File(...)):
    # Validate file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image.")

    # Read image
    contents = await file.read()
    try:
        image = Image.open(io.BytesIO(contents)).convert("RGB")
    except Exception:
        raise HTTPException(status_code=400, detail="Could not read image file.")

    # Save to temp file (inference_v4 expects a file path)
    tmp_path = f"/tmp/agrocure_input_{os.getpid()}.jpg"
    image.save(tmp_path)

    try:
        pipeline = get_pipeline()
        result   = pipeline.predict(tmp_path)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)

    # Confidence level label
    conf = result["confidence"]
    if conf >= 0.90:
        level = "high"
    elif conf >= 0.70:
        level = "medium"
    else:
        level = "low"

    return {
        "plant":            result["plant"],
        "disease":          result["disease"],
        "label":            result["label"],
        "confidence":       round(conf, 4),
        "confidence_pct":   f"{conf*100:.1f}%",
        "confidence_level": level,
        "stage1_conf":      result.get("stage1_conf"),
        "stage2_conf":      result.get("stage2_conf"),
    }
