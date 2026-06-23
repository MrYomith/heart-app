from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.task import Task
from app.models.user import User

router = APIRouter(prefix="/api/progress", tags=["progress"])


@router.get("/user/{user_id}/today")
def get_today_progress(user_id: int, date: str = None, db: Session = Depends(get_db)):
    query = db.query(Task).filter(Task.user_id == user_id)
    if date:
        query = query.filter(Task.task_date == date)
    tasks = query.all()
    total = len(tasks)
    done = sum(1 for t in tasks if t.is_done)
    return {
        "total": total,
        "done": done,
        "in_progress": 0,
        "pending": total - done,
        "percentage": round((done / total * 100) if total > 0 else 0, 1),
    }


@router.get("/user/{user_id}/weekly")
def get_weekly_progress(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    # Placeholder: return mock weekly trend data
    return {
        "journey_progress": user.journey_progress,
        "recovery_prediction": 85,
        "days": [
            {"day": "Mon", "score": 70},
            {"day": "Tue", "score": 75},
            {"day": "Wed", "score": 68},
            {"day": "Thu", "score": 80},
            {"day": "Fri", "score": 85},
            {"day": "Sat", "score": 72},
            {"day": "Sun", "score": 88},
        ],
    }


@router.get("/user/{user_id}/wearables")
def get_wearable_summary(user_id: int, db: Session = Depends(get_db)):
    # In a real app this would pull from wearable integration
    return {
        "heart_rate": 72,
        "steps": 5240,
        "steps_goal": 7000,
        "activity_minutes": 45,
        "sleep": "7h 15m",
        "spo2": 98,
        "hrv": 62,
        "connected": True,
    }
