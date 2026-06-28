"""Knowledge quizzes + badges for the Education Hub (FR-182/183).

Patient lists quizzes per topic, takes a quiz (server-side grading so answers
aren't leaked), and earns badges. Backed by quizzes / quiz_questions /
quiz_attempts / badges / user_badges.
"""
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.models import Badge, Quiz, QuizAttempt, QuizQuestion, User, UserBadge

router = APIRouter(prefix="/api", tags=["quizzes"])


def _now() -> datetime:
    return datetime.now(timezone.utc)


@router.get("/quizzes")
def list_quizzes(topic: str | None = None, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Quizzes (optionally by topic) with question count + the patient's best score."""
    q = db.query(Quiz)
    if topic:
        q = q.filter(Quiz.topic == topic)
    quizzes = q.order_by(Quiz.title).all()
    best = {}
    for a in db.query(QuizAttempt).filter(QuizAttempt.user_id == user.id):
        best[a.quiz_id] = max(best.get(a.quiz_id, 0), a.score or 0)
    out = []
    for z in quizzes:
        n = db.query(QuizQuestion).filter(QuizQuestion.quiz_id == z.id).count()
        out.append({
            "id": str(z.id), "title": z.title, "topic": z.topic,
            "question_count": n,
            "best_score": best.get(z.id),
            "completed": z.id in best,
        })
    return out


@router.get("/quizzes/{quiz_id}")
def get_quiz(quiz_id: uuid.UUID, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Quiz questions + options — correct answers are NOT included (graded server-side)."""
    z = db.query(Quiz).filter(Quiz.id == quiz_id).first()
    if not z:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Quiz not found.")
    questions = db.query(QuizQuestion).filter(QuizQuestion.quiz_id == quiz_id).all()
    return {
        "id": str(z.id), "title": z.title, "topic": z.topic,
        "questions": [{"id": str(q.id), "question": q.question, "options": q.options} for q in questions],
    }


class QuizSubmit(BaseModel):
    answers: dict[str, int]  # question_id -> chosen option index


@router.post("/quizzes/{quiz_id}/attempt")
def submit_quiz(quiz_id: uuid.UUID, payload: QuizSubmit, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    z = db.query(Quiz).filter(Quiz.id == quiz_id).first()
    if not z:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Quiz not found.")
    questions = db.query(QuizQuestion).filter(QuizQuestion.quiz_id == quiz_id).all()
    total = len(questions) or 1
    correct = 0
    results = []
    for q in questions:
        chosen = payload.answers.get(str(q.id))
        is_correct = chosen is not None and chosen == q.correct_index
        if is_correct:
            correct += 1
        results.append({
            "question_id": str(q.id), "correct_index": q.correct_index,
            "chosen": chosen, "is_correct": is_correct, "explanation": q.explanation,
        })
    score = round(correct / total * 100)

    db.add(QuizAttempt(user_id=user.id, quiz_id=quiz_id, score=score, answers=payload.answers, attempted_at=_now()))

    # Award the "Quiz Master" badge once a quiz is passed (≥80%).
    awarded = None
    if score >= 80:
        badge = db.query(Badge).filter(Badge.key == "quiz_master").first()
        if badge and not db.query(UserBadge).filter(UserBadge.user_id == user.id, UserBadge.badge_id == badge.id).first():
            db.add(UserBadge(user_id=user.id, badge_id=badge.id, earned_at=_now()))
            awarded = {"key": badge.key, "name": badge.name, "icon": badge.icon}

    db.commit()
    return {"score": score, "correct": correct, "total": total, "results": results, "badge_awarded": awarded}


@router.get("/badges")
def list_badges(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """All badges with whether the patient has earned each (FR-183)."""
    earned = {ub.badge_id for ub in db.query(UserBadge).filter(UserBadge.user_id == user.id)}
    return [{"key": b.key, "name": b.name, "description": b.description, "icon": b.icon,
             "earned": b.id in earned} for b in db.query(Badge).order_by(Badge.name).all()]
