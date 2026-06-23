from pydantic import BaseModel
from typing import Optional


class MedicationOut(BaseModel):
    id: int
    user_id: int
    name: str
    dose: Optional[str] = None
    schedule: Optional[str] = None
    times: Optional[str] = None
    is_active: bool
    notes: Optional[str] = None

    model_config = {"from_attributes": True}
