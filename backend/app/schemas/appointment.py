from pydantic import BaseModel
from typing import Optional


class AppointmentOut(BaseModel):
    id: int
    user_id: int
    title: str
    subtitle: Optional[str] = None
    date: str
    time: Optional[str] = None
    location: Optional[str] = None
    appointment_type: str
    is_confirmed: bool

    model_config = {"from_attributes": True}
