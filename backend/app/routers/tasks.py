"""Today's Plan tasks for the authenticated patient (FR-021, FR-160)."""
import uuid
from datetime import date

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.models import Task, User
from app.schemas.task import TaskOut, TaskToggle
from app.services.task_generator import ensure_today_tasks

router = APIRouter(prefix="/api/tasks", tags=["tasks"])


@router.get("/today", response_model=list[TaskOut])
def today(date_str: str | None = None, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    day = date_str or date.today().isoformat()
    # Auto-generate a phase-appropriate plan if the patient has none for today,
    # so the daily plan (and the progress it drives) is never empty.
    rows = ensure_today_tasks(db, user, day)
    return [TaskOut.from_row(t) for t in rows]


@router.get("", response_model=list[TaskOut])
def all_tasks(phase: str | None = None, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    q = db.query(Task).filter(Task.user_id == user.id)
    if phase:
        q = q.filter(Task.phase == phase)
    return [TaskOut.from_row(t) for t in q.order_by(Task.priority).all()]


@router.patch("/{task_id}/toggle", response_model=TaskOut)
def toggle(task_id: uuid.UUID, payload: TaskToggle, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == user.id).first()
    if not task:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Task not found.")
    task.is_done = payload.is_done
    db.commit()
    db.refresh(task)
    return TaskOut.from_row(task)
