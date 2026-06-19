import os

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter()


class Msg(BaseModel):
    role: str          # "user" | "assistant"
    content: str


class ChatRequest(BaseModel):
    plant: Optional[str] = None
    disease: Optional[str] = None
    messages: List[Msg]


SYSTEM_PROMPT = (
    "You are Sage, a warm, knowledgeable plant-care companion inside the AgroCure app. "
    "AgroCure is an AI that diagnoses crop diseases from a photo of a leaf. "
    "You help farmers and gardeners understand a diagnosis and care for their plants. "
    "Be concise, practical and encouraging. Prefer short paragraphs and simple numbered "
    "steps for treatments. When unsure, say so and suggest consulting a local agronomist. "
    "Only give advice about plants, crops, diseases, pests and growing conditions."
)


@router.post("/chat", tags=["AI"])
async def chat(req: ChatRequest):
    """Sage — the AI companion. Calls OpenAI using the key from the .env file.

    If no key is configured the endpoint stays alive and returns a helpful
    message instead of erroring, so the app keeps working before setup.
    """
    api_key = os.getenv("OPENAI_API_KEY", "").strip()
    if not api_key:
        return {
            "reply": (
                "Sage isn't connected yet. Add your OPENAI_API_KEY to the "
                "backend .env file and restart the server to enable AI chat."
            ),
            "connected": False,
        }

    # Build the conversation with a context-aware system prompt.
    system = SYSTEM_PROMPT
    if req.plant and req.disease:
        system += (
            f"\n\nContext: the user just scanned a {req.plant} leaf and the "
            f"model diagnosed '{req.disease}'. Tailor your answers to this case."
        )

    messages = [{"role": "system", "content": system}]
    messages += [{"role": m.role, "content": m.content} for m in req.messages]

    try:
        from openai import OpenAI

        client = OpenAI(api_key=api_key)
        completion = client.chat.completions.create(
            model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
            messages=messages,
            temperature=0.4,
            max_tokens=600,
        )
        reply = completion.choices[0].message.content
        return {"reply": reply, "connected": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Chat failed: {e}")
