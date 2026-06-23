from pydantic import BaseModel
from typing import Optional


class MessageOut(BaseModel):
    id: int
    user_id: int
    sender: str
    sender_avatar: Optional[str] = None
    subject: str
    preview: Optional[str] = None
    body: Optional[str] = None
    category: str
    is_read: bool
    sent_at: Optional[str] = None

    model_config = {"from_attributes": True}
