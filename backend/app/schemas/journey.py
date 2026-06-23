from pydantic import BaseModel
from typing import Optional


class JourneyPhaseOut(BaseModel):
    id: int
    user_id: int
    phase_key: str
    label: str
    emoji: Optional[str] = None
    status: str
    date_label: Optional[str] = None
    subtitle: Optional[str] = None
    order: int

    model_config = {"from_attributes": True}
