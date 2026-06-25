"""Wire an approved patient to their hospital's care team.

This is the link that turns a patient from Tier 1 (self-guided) into Tier 2
(monitored): once enrolled & approved, every active clinician at the hospital
gets a ClinicianAssignment, so the patient appears on their dashboard and the
alert loop reaches a real care team.
"""
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.enums import ClinicianRole, UserRole
from app.models import ClinicianAssignment, User


def assign_care_team(db: Session, patient: User, hospital_id) -> int:
    """Create assignments linking `patient` to every active clinician at `hospital_id`.

    Idempotent: skips clinicians already assigned. Returns how many were added.
    Does not commit — the caller owns the transaction.
    """
    if not hospital_id:
        return 0

    clinicians = (
        db.query(User)
        .filter(
            User.role == UserRole.clinician,
            User.hospital_id == hospital_id,
            User.is_active.is_(True),
            User.deleted_at.is_(None),
        )
        .all()
    )

    existing = {
        a.clinician_id
        for a in db.query(ClinicianAssignment).filter(
            ClinicianAssignment.patient_id == patient.id,
            ClinicianAssignment.active.is_(True),
        )
    }

    now = datetime.now(timezone.utc)
    added = 0
    for c in clinicians:
        if c.id in existing:
            continue
        db.add(ClinicianAssignment(
            clinician_id=c.id,
            patient_id=patient.id,
            clinician_role=c.clinician_specialty or ClinicianRole.nurse,
            hospital_id=hospital_id,
            assigned_at=now,
            active=True,
        ))
        added += 1
    return added
