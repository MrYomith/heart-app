from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.message import Message
from app.schemas.message import MessageOut

router = APIRouter(prefix="/api/messages", tags=["messages"])


@router.get("/user/{user_id}", response_model=List[MessageOut])
def get_messages(user_id: int, category: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Message).filter(Message.user_id == user_id)
    if category:
        query = query.filter(Message.category == category)
    return query.order_by(Message.id.desc()).all()


@router.get("/user/{user_id}/unread-count")
def get_unread_count(user_id: int, db: Session = Depends(get_db)):
    count = db.query(Message).filter(
        Message.user_id == user_id,
        Message.is_read == False
    ).count()
    return {"unread": count}


@router.patch("/{message_id}/read", response_model=MessageOut)
def mark_read(message_id: int, db: Session = Depends(get_db)):
    msg = db.query(Message).filter(Message.id == message_id).first()
    if not msg:
        raise HTTPException(status_code=404, detail="Message not found")
    msg.is_read = True
    db.commit()
    db.refresh(msg)
    return msg


@router.post("/", response_model=MessageOut, status_code=201)
def send_message(payload: dict, db: Session = Depends(get_db)):
    msg = Message(**payload)
    db.add(msg)
    db.commit()
    db.refresh(msg)
    return msg
