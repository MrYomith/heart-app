"""FR-035 — Stage transitions (hybrid model).

Patients move through the six journey stages automatically based on their
surgery/discharge dates, while a surgeon or assigned nurse can override
(advance / pause / roll back) from the dashboard. Every transition — automatic
or manual — is written to stage_transitions and the audit log with a reason.

Default date rules (from FR-035 acceptance criteria):
  diagnosis  → until 6 weeks before surgery
  preop      → 6 weeks before surgery, up to T-1
  surgery    → T-1 day through surgery day
  inpatient  → after surgery day, until discharge
  rehab      → from discharge date, for 12 weeks
  thriving   → 12+ weeks after discharge
"""
from datetime import date, datetime, timedelta, timezone

from sqlalchemy.orm import Session

from app.enums import (
    ActivatedBy,
    PhaseKey,
    PhaseStatus,
    TransitionTrigger,
)
from app.models import AuditLog, JourneyPhase, StageTransition, User

ORDER = [
    PhaseKey.diagnosis,
    PhaseKey.preop,
    PhaseKey.surgery,
    PhaseKey.inpatient,
    PhaseKey.rehab,
    PhaseKey.thriving,
]

PREOP_LEAD = timedelta(weeks=6)
REHAB_WINDOW = timedelta(weeks=12)


def compute_expected_phase(user: User, today: date | None = None) -> PhaseKey | None:
    """The stage the patient should be in by date alone.

    Returns None when it can't be computed (no surgery date) — the caller then
    leaves the patient where they are. Never returns a stage past what the dates
    justify; clinician confirmation drives anything earlier than the dates imply.
    """
    today = today or datetime.now(timezone.utc).date()
    surgery = user.surgery_date
    if not surgery:
        # Without a scheduled date we can't auto-advance beyond diagnosis.
        return None

    discharge = user.discharge_date
    if today < surgery - PREOP_LEAD:
        return PhaseKey.diagnosis
    if today < surgery - timedelta(days=1):
        return PhaseKey.preop
    if today < surgery:
        return PhaseKey.surgery
    # On/after surgery day:
    if discharge is None:
        return PhaseKey.inpatient
    if today < discharge:
        return PhaseKey.inpatient
    if today < discharge + REHAB_WINDOW:
        return PhaseKey.rehab
    return PhaseKey.thriving


def _progress_for(phase: PhaseKey) -> float:
    return round((ORDER.index(phase) / (len(ORDER) - 1)) * 100, 1)


def _move(db: Session, user: User, to_phase: PhaseKey, *, trigger: TransitionTrigger,
          actor_id=None, reason: str | None = None) -> None:
    """Set the patient's current phase to `to_phase`, update the phase rows,
    and log the transition + audit entry. Does not commit."""
    from_phase = user.current_phase
    now = datetime.now(timezone.utc)
    to_idx = ORDER.index(to_phase)

    rows = {r.phase_key: r for r in db.query(JourneyPhase).filter(JourneyPhase.user_id == user.id)}
    for i, key in enumerate(ORDER):
        row = rows.get(key)
        if not row:
            continue
        if i < to_idx:
            row.status = PhaseStatus.completed
        elif i == to_idx:
            if row.status != PhaseStatus.active:
                row.activated_at = now
                row.activated_by = ActivatedBy.clinician if trigger == TransitionTrigger.clinician else ActivatedBy.auto
            row.status = PhaseStatus.active
        else:
            row.status = PhaseStatus.upcoming

    user.current_phase = to_phase
    user.journey_progress = _progress_for(to_phase)

    db.add(StageTransition(
        user_id=user.id, from_phase=from_phase, to_phase=to_phase,
        trigger=trigger, actor_id=actor_id, reason=reason, created_at=now,
    ))
    db.add(AuditLog(
        actor_id=actor_id, actor_role=("clinician" if trigger == TransitionTrigger.clinician else "system"),
        action="stage_transition", entity_type="journey_phase", entity_id=None,
        patient_id=user.id,
        audit_metadata={
            "from": from_phase.value if from_phase else None,
            "to": to_phase.value,
            "trigger": trigger.value,
            "reason": reason,
        },
        ip_hash=None, created_at=now,
    ))


def apply_auto_transitions(db: Session, user: User, commit: bool = True) -> bool:
    """Advance the patient by date if needed. Forward-only — never auto-rolls back
    (a clinician does that). No-op when paused or when the date can't be computed.
    Returns True if the stage changed."""
    if user.stage_paused:
        return False
    expected = compute_expected_phase(user)
    if expected is None:
        return False
    current = user.current_phase or PhaseKey.diagnosis
    if ORDER.index(expected) <= ORDER.index(current):
        return False  # forward-only
    _move(db, user, expected, trigger=TransitionTrigger.auto_date)
    if commit:
        db.commit()
    return True


def manual_transition(db: Session, user: User, to_phase: PhaseKey, actor: User, reason: str | None) -> None:
    """Clinician override: advance or roll back to any stage. Always logged."""
    _move(db, user, to_phase, trigger=TransitionTrigger.clinician, actor_id=actor.id, reason=reason)
    db.commit()


def set_paused(db: Session, user: User, paused: bool, actor: User, reason: str | None) -> None:
    user.stage_paused = paused
    now = datetime.now(timezone.utc)
    db.add(AuditLog(
        actor_id=actor.id, actor_role="clinician",
        action="stage_paused" if paused else "stage_resumed",
        entity_type="user", entity_id=user.id, patient_id=user.id,
        audit_metadata={"reason": reason}, ip_hash=None, created_at=now,
    ))
    db.commit()
