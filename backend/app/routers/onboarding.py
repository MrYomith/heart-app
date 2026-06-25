"""Onboarding wizard endpoints (FR-010–015).

Save & resume during the wizard, then a final commit that writes the patient's
medical profile, conditions, allergies, and the GAD-7 baseline score.
"""
from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import (
    ConditionSource,
    NyhaClass,
    ScoreType,
    Severity,
    SurgeryType,
)
from app.models import (
    ClinicalScore,
    OnboardingProgress,
    PatientAllergy,
    PatientCondition,
    User,
)
from app.schemas.onboarding import (
    OnboardingComplete,
    OnboardingProgressOut,
    OnboardingSave,
)
from app.services.patient_setup import setup_patient

router = APIRouter(prefix="/api/onboarding", tags=["onboarding"])


def _gad7_severity(score: int) -> Severity:
    # Validated GAD-7 cut-offs: 0-4 minimal, 5-9 mild, 10-14 moderate, 15-21 severe.
    if score <= 4:
        return Severity.minimal
    if score <= 9:
        return Severity.mild
    if score <= 14:
        return Severity.moderate
    return Severity.severe


def _parse_date(s: str | None) -> date | None:
    if not s:
        return None
    try:
        return date.fromisoformat(s)
    except ValueError:
        return None


@router.get("", response_model=OnboardingProgressOut)
def get_progress(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    prog = db.query(OnboardingProgress).filter(OnboardingProgress.user_id == user.id).first()
    if not prog:
        return OnboardingProgressOut(current_step=1, step_data=None, completed=user.onboarding_complete)
    return OnboardingProgressOut(current_step=prog.current_step, step_data=prog.step_data, completed=prog.completed)


@router.patch("", response_model=OnboardingProgressOut)
def save_progress(payload: OnboardingSave, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    prog = db.query(OnboardingProgress).filter(OnboardingProgress.user_id == user.id).first()
    if not prog:
        prog = OnboardingProgress(user_id=user.id)
        db.add(prog)
    prog.current_step = payload.current_step
    prog.step_data = payload.step_data
    db.commit()
    db.refresh(prog)
    return OnboardingProgressOut(current_step=prog.current_step, step_data=prog.step_data, completed=prog.completed)


@router.post("/complete")
def complete(payload: OnboardingComplete, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)

    # --- Medical profile on the user ---
    user.date_of_birth = _parse_date(payload.date_of_birth)
    if payload.surgery_type:
        try:
            user.surgery_type = SurgeryType(payload.surgery_type)
        except ValueError:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid surgery type.")
    user.surgery_date = _parse_date(payload.surgery_date)
    if payload.nyha_class:
        try:
            user.nyha_class = NyhaClass(payload.nyha_class)
        except ValueError:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid NYHA class.")
    if payload.diagnosis:
        user.diagnosis = payload.diagnosis

    # --- Conditions & allergies (replace existing onboarding rows) ---
    db.query(PatientCondition).filter(
        PatientCondition.user_id == user.id, PatientCondition.source == ConditionSource.onboarding
    ).delete()
    for c in payload.conditions:
        if c.strip():
            db.add(PatientCondition(user_id=user.id, condition=c.strip(), source=ConditionSource.onboarding))
    db.query(PatientAllergy).filter(PatientAllergy.user_id == user.id).delete()
    for a in payload.allergies:
        if a.strip():
            db.add(PatientAllergy(user_id=user.id, allergy=a.strip()))

    # --- GAD-7 baseline (FR-013) ---
    gad7_result = None
    if payload.gad7_answers:
        valid = [x for x in payload.gad7_answers if isinstance(x, int) and 0 <= x <= 3]
        score = sum(valid)
        severity = _gad7_severity(score)
        db.add(ClinicalScore(
            user_id=user.id,
            score_type=ScoreType.gad7,
            score=score,
            answers={"items": payload.gad7_answers},
            severity=severity,
            administered_at=now,
            scheduled_week=0,
        ))
        gad7_result = {"score": score, "severity": severity.value, "suggest_care_team": score >= 15}

    user.onboarding_complete = True
    prog = db.query(OnboardingProgress).filter(OnboardingProgress.user_id == user.id).first()
    if prog:
        prog.completed = True

    # Give the patient a real journey + starter daily plan so the app has content.
    setup_patient(db, user)

    db.commit()

    return {"onboarding_complete": True, "gad7": gad7_result}
