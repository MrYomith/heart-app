from pydantic import BaseModel
from typing import Optional


class TaskBase(BaseModel):
    title: str
    subtitle: Optional[str] = None
    icon: Optional[str] = None
    category: Optional[str] = None
    scheduled_time: Optional[str] = None
    time_color: Optional[str] = "teal"
    phase: Optional[str] = None
    task_date: Optional[str] = None
    is_done: bool = False
    priority: int = 0


class TaskCreate(TaskBase):
    user_id: int


class TaskOut(TaskBase):
    id: int
    user_id: int

    model_config = {"from_attributes": True}


class TaskToggle(BaseModel):
    is_done: bool
