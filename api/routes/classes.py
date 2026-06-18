from fastapi import APIRouter
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "models"))
import config_v4 as config

router = APIRouter()

@router.get("/classes", tags=["Info"])
def get_classes():
    all_classes = []
    for plant, diseases in config.PLANT_DISEASES.items():
        for disease in diseases:
            all_classes.append({
                "label": f"{plant}{config.DISPLAY_SEP}{disease}",
                "plant": plant,
                "disease": disease,
            })
    return {
        "total": len(all_classes),
        "plants": len(config.PLANT_DISEASES),
        "classes": all_classes,
    }
