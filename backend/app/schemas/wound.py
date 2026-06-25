"""Wound photo log (FR-104) schemas."""
from pydantic import BaseModel


class WoundPhotoOut(BaseModel):
    id: str
    day_post_op: int | None = None
    uploaded_at: str | None = None
    reviewed: bool = False
    image_base64: str | None = None  # data for in-app display (local stand-in for S3)


class WoundStatusOut(BaseModel):
    day_post_op: int | None
    dressing_locked: bool   # True before Day 3 — keep dressing on
    message: str
