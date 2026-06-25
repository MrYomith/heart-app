from pydantic import BaseModel


class MessageOut(BaseModel):
    id: str
    sender: str
    avatar: str | None = None
    subject: str
    preview: str
    body: str
    category: str
    is_read: bool
    sent_at: str | None = None
