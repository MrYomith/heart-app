"""AI meal analysis via the Claude API (FR-044/FR-106 AI layer).

A patient photographs and/or describes a meal; Claude parses it into nutrition
estimates tuned for a cardiac-recovery diet. Reads ANTHROPIC_API_KEY from the
environment — the feature returns a clear 503 until the key is configured.
"""
import base64
import json
import os

# Vision-capable Claude model (latest Opus per the claude-api reference).
_MODEL = os.getenv("FOOD_AI_MODEL", "claude-opus-4-8")

_SYSTEM = (
    "You are a clinical nutrition assistant for cardiac-surgery patients on a "
    "heart-healthy (low-sodium, low-saturated-fat) recovery diet. Estimate the "
    "nutrition of the meal shown/described. Be realistic; if unsure, give your "
    "best estimate. Respond with ONLY a JSON object, no prose, no markdown fences."
)

_INSTRUCTION = (
    "Return a JSON object with exactly these keys:\n"
    '  "items": array of short strings (the foods you identify),\n'
    '  "calories_kcal": integer,\n'
    '  "protein_g": integer,\n'
    '  "carbs_g": integer,\n'
    '  "fat_g": integer,\n'
    '  "sodium_mg": integer,\n'
    '  "heart_healthy": boolean (true if appropriate for a low-sodium cardiac diet),\n'
    '  "notes": string (<=200 chars, one practical cardiac-diet tip about this meal).'
)


class FoodAIUnavailable(RuntimeError):
    """Raised when the Anthropic API key is not configured."""


def _client():
    if not os.getenv("ANTHROPIC_API_KEY"):
        raise FoodAIUnavailable(
            "AI food logging needs an Anthropic API key. Set ANTHROPIC_API_KEY in the backend environment."
        )
    import anthropic  # imported lazily so the app boots without the key
    return anthropic.Anthropic()


def _parse_json(text: str) -> dict:
    text = text.strip()
    if text.startswith("```"):  # strip accidental markdown fences
        text = text.split("```", 2)[1] if text.count("```") >= 2 else text.strip("`")
        text = text.removeprefix("json").strip()
    return json.loads(text)


def analyze_meal(description: str | None = None,
                 image_bytes: bytes | None = None,
                 media_type: str | None = None) -> dict:
    """Return parsed nutrition for a meal photo and/or text description."""
    if not description and not image_bytes:
        raise ValueError("Provide a photo or a description of the meal.")

    content: list = []
    if image_bytes:
        content.append({
            "type": "image",
            "source": {
                "type": "base64",
                "media_type": media_type or "image/jpeg",
                "data": base64.standard_b64encode(image_bytes).decode("utf-8"),
            },
        })
    text = _INSTRUCTION
    if description:
        text += f"\n\nThe patient describes the meal as: {description}"
    content.append({"type": "text", "text": text})

    import anthropic
    try:
        resp = _client().messages.create(
            model=_MODEL,
            max_tokens=1024,
            system=_SYSTEM,
            messages=[{"role": "user", "content": content}],
        )
    except anthropic.APIStatusError as e:
        # Surface the real reason (e.g. usage-limit reached, invalid key) instead
        # of a generic failure, so the app can show a helpful message.
        msg = "AI is temporarily unavailable."
        try:
            msg = e.response.json().get("error", {}).get("message", msg)
        except Exception:
            pass
        raise FoodAIUnavailable(msg)
    body = next((b.text for b in resp.content if b.type == "text"), "")
    data = _parse_json(body)

    # Normalise / clamp so the API always returns a consistent shape.
    def _int(key):
        try:
            return max(0, int(data.get(key) or 0))
        except (TypeError, ValueError):
            return 0
    return {
        "items": [str(x) for x in (data.get("items") or [])][:20],
        "calories_kcal": _int("calories_kcal"),
        "protein_g": _int("protein_g"),
        "carbs_g": _int("carbs_g"),
        "fat_g": _int("fat_g"),
        "sodium_mg": _int("sodium_mg"),
        "heart_healthy": bool(data.get("heart_healthy", False)),
        "notes": str(data.get("notes") or "")[:200],
    }
