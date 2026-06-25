"""Daily task-completion progress for the authenticated patient."""
from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.models import Task, User

router = APIRouter(prefix="/api/progress", tags=["progress"])


@router.get("/today")
def today(date_str: str | None = None, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    day = date_str or date.today().isoformat()
    tasks = db.query(Task).filter(Task.user_id == user.id, Task.task_date == day).all()
    total = len(tasks)
    done = sum(1 for t in tasks if t.is_done)
    return {
        "total": total,
        "done": done,
        "pending": total - done,
        "percentage": round((done / total * 100) if total else 0, 1),
    }
