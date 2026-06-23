from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Text
from app.database import Base


class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    sender = Column(String, nullable=False)
    sender_avatar = Column(String, nullable=True)
    subject = Column(String, nullable=False)
    preview = Column(String, nullable=True)
    body = Column(Text, nullable=True)
    category = Column(String, default="care_team")
    is_read = Column(Boolean, default=False)
    sent_at = Column(String, nullable=True)
