"""Secure messages for the authenticated patient (FR-200).

Backed by message_threads + messages; returned flat for the inbox UI.
"""
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import MessageCategory
from app.models import Message, MessageThread, User
from app.schemas.message import MessageOut

router = APIRouter(prefix="/api/messages", tags=["messages"])

# Map the backend thread category → display category the app filters on, + an avatar.
_CATEGORY_DISPLAY = {
    "care_team": ("Support", "👩‍⚕️"),
    "physiotherapy": ("Education", "🏃"),
    "education": ("Education", "📚"),
    "emotional_support": ("Support", "❤️"),
    "alerts": ("Alerts", "🔔"),
    "family": ("Support", "👪"),
}


def _to_out(msg: Message, thread: MessageThread) -> MessageOut:
    cat = thread.category.value if thread.category else "care_team"
    display, avatar = _CATEGORY_DISPLAY.get(cat, ("Support", "🫀"))
    body = msg.body or ""
    return MessageOut(
        id=str(msg.id),
        sender=msg.sender_role or "Care Team",
        avatar=avatar,
        subject=thread.subject or "Message",
        preview=(body[:70] + "…") if len(body) > 70 else body,
        body=body,
        category=display,
        is_read=msg.is_read,
        sent_at=msg.sent_at.isoformat() if msg.sent_at else None,
    )


@router.get("", response_model=list[MessageOut])
def list_messages(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(Message, MessageThread)
        .join(MessageThread, Message.thread_id == MessageThread.id)
        .filter(MessageThread.patient_id == user.id)
        .order_by(Message.sent_at.desc().nullslast())
        .all()
    )
    return [_to_out(m, t) for m, t in rows]


@router.get("/unread-count")
def unread_count(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    n = (
        db.query(Message)
        .join(MessageThread, Message.thread_id == MessageThread.id)
        .filter(MessageThread.patient_id == user.id, Message.is_read.is_(False))
        .count()
    )
    return {"unread": n}


class SendMessageIn(BaseModel):
    body: str


@router.post("/send", response_model=MessageOut)
def send_message(payload: SendMessageIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Patient sends a message to their care team (FR-200). Posts into the patient's
    care_team thread, creating it if needed."""
    now = datetime.now(timezone.utc)
    thread = (
        db.query(MessageThread)
        .filter(MessageThread.patient_id == user.id, MessageThread.category == MessageCategory.care_team)
        .order_by(MessageThread.last_message_at.desc().nullslast())
        .first()
    )
    if not thread:
        thread = MessageThread(patient_id=user.id, category=MessageCategory.care_team,
                               subject="Care Team", last_message_at=now)
        db.add(thread)
        db.flush()
    msg = Message(thread_id=thread.id, sender_id=user.id, sender_role=user.name or "You",
                  body=payload.body, is_read=True, read_at=now, sent_at=now)
    db.add(msg)
    thread.last_message_at = now
    db.commit()
    db.refresh(msg)
    return _to_out(msg, thread)


@router.patch("/{message_id}/read", response_model=MessageOut)
def mark_read(message_id: uuid.UUID, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = (
        db.query(Message, MessageThread)
        .join(MessageThread, Message.thread_id == MessageThread.id)
        .filter(Message.id == message_id, MessageThread.patient_id == user.id)
        .first()
    )
    if not row:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Message not found.")
    msg, thread = row
    msg.is_read = True
    msg.read_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(msg)
    return _to_out(msg, thread)
