from pydantic import BaseModel
from typing import Optional


class UserBase(BaseModel):
    name: str
    email: str
    surgery_date: Optional[str] = None
    current_phase: Optional[str] = "diagnosis"
    journey_progress: Optional[float] = 0.0
    hospital: Optional[str] = None
    surgeon: Optional[str] = None
    diagnosis: Optional[str] = None


class UserCreate(UserBase):
    pass


class UserOut(UserBase):
    id: int

    model_config = {"from_attributes": True}
