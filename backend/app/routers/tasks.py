from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.task import Task
from app.schemas.task import TaskCreate, TaskOut, TaskToggle

router = APIRouter(prefix="/api/tasks", tags=["tasks"])


@router.get("/user/{user_id}/today", response_model=List[TaskOut])
def get_today_tasks(user_id: int, date: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Task).filter(Task.user_id == user_id)
    if date:
        query = query.filter(Task.task_date == date)
    return query.order_by(Task.priority).all()


@router.get("/user/{user_id}", response_model=List[TaskOut])
def get_all_tasks(user_id: int, phase: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Task).filter(Task.user_id == user_id)
    if phase:
        query = query.filter(Task.phase == phase)
    return query.order_by(Task.priority).all()


@router.post("/", response_model=TaskOut, status_code=201)
def create_task(payload: TaskCreate, db: Session = Depends(get_db)):
    task = Task(**payload.model_dump())
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


@router.patch("/{task_id}/toggle", response_model=TaskOut)
def toggle_task(task_id: int, payload: TaskToggle, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    task.is_done = payload.is_done
    db.commit()
    db.refresh(task)
    return task


@router.delete("/{task_id}", status_code=204)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    db.delete(task)
    db.commit()
