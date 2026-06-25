"""Stage-4 recovery trackers: delirium screening (FR-103) + nutrition (FR-106)."""
from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import AlertSeverity, AlertType, ScoreType, Severity
from app.models import Alert, ClinicalScore, NutritionLog, User
from app.schemas.recovery import (
    DeliriumResult,
    DeliriumSubmit,
    NutritionLogIn,
    NutritionTodayOut,
)

delirium_router = APIRouter(prefix="/api/delirium", tags=["delirium"])
nutrition_router = APIRouter(prefix="/api/nutrition", tags=["nutrition"])

PROTEIN_TARGET = 75   # grams/day (FR-106)
HYDRATION_TARGET = 8  # glasses/day
CONFUSION_THRESHOLD = 2  # ≥2 incorrect orientation answers → nurse alert


@delirium_router.post("", response_model=DeliriumResult)
def submit_delirium(payload: DeliriumSubmit, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    confusion = sum(1 for correct in payload.answers if not correct)
    risk = confusion >= CONFUSION_THRESHOLD

    db.add(ClinicalScore(
        user_id=user.id,
        score_type=ScoreType.delirium,
        score=confusion,
        answers={"answers": payload.answers},
        severity=Severity.moderate if risk else Severity.minimal,
        administered_at=now,
    ))
    if risk:
        db.add(Alert(patient_id=user.id, type=AlertType.delirium, severity=AlertSeverity.warning, triggered_at=now))
    db.commit()

    return DeliriumResult(
        confusion_score=confusion,
        risk=risk,
        message=(
            "Thanks for checking in. We've let your nurse know you seem a little disoriented — they'll pop by to help."
            if risk else
            "You're well oriented today — that's a great sign of recovery. 🌿"
        ),
    )


@nutrition_router.get("/today", response_model=NutritionTodayOut)
def nutrition_today(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = db.query(NutritionLog).filter(NutritionLog.user_id == user.id, NutritionLog.log_date == date.today()).first()
    return _today_out(row)


@nutrition_router.post("", response_model=NutritionTodayOut)
def log_nutrition(payload: NutritionLogIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    today = date.today()
    row = db.query(NutritionLog).filter(NutritionLog.user_id == user.id, NutritionLog.log_date == today).first()
    if not row:
        row = NutritionLog(user_id=user.id, log_date=today)
        db.add(row)
    if payload.protein_grams is not None:
        row.protein_grams = payload.protein_grams
    if payload.hydration_glasses is not None:
        row.hydration_glasses = payload.hydration_glasses
    if payload.meals_count is not None:
        row.meals_count = payload.meals_count
    row.bowel_movement = payload.bowel_movement
    db.commit()
    db.refresh(row)
    return _today_out(row)


def _today_out(row: NutritionLog | None) -> NutritionTodayOut:
    return NutritionTodayOut(
        protein_grams=(row.protein_grams if row and row.protein_grams else 0),
        hydration_glasses=(row.hydration_glasses if row and row.hydration_glasses else 0),
        meals_count=(row.meals_count if row and row.meals_count else 0),
        bowel_movement=(row.bowel_movement if row else False),
        protein_target=PROTEIN_TARGET,
        hydration_target=HYDRATION_TARGET,
    )
