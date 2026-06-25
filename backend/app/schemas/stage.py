"""ERAS pre-op checklist (FR-060) + mobilisation milestones (FR-102) schemas."""
from pydantic import BaseModel


class ErasItemOut(BaseModel):
    item_key: str
    label: str
    progress: int   # 0–100
    target: int


class ErasUpdate(BaseModel):
    progress: int


class ErasSummaryOut(BaseModel):
    items: list[ErasItemOut]
    overall: int  # average % across the 7 rings


class MobilisationOut(BaseModel):
    id: str
    milestone: str
    label: str
    achieved: bool
