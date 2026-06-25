
"""Hospital enrollment endpoints.

Two real-world paths:
  - by-code:  patient enters a clinic activation code -> auto-approved
  - request:  patient picks a hospital -> pending until the hospital approves
Self-guided app features work regardless; clinical features check enrollment status.
"""
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import EnrollmentInitiatedBy, EnrollmentStatus, UserRole
from app.models import EnrollmentCode, Hospital, HospitalEnrollment, User
from app.schemas.onboarding import (
    EnrollByCode,
    EnrollmentStatusOut,
    EnrollRequest,
    HospitalOut,
)
from app.services.care_team import assign_care_team

router = APIRouter(prefix="/api", tags=["enrollment"])


def get_current_coordinator(user: User = Depends(get_current_user)) -> User:
    """A clinician/admin who can approve patients for their own hospital."""
    if user.role not in (UserRole.clinician, UserRole.admin):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Hospital staff access only.")
    return user


@router.get("/hospitals", response_model=list[HospitalOut])
def list_hospitals(_: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(Hospital).order_by(Hospital.name).all()
    return [HospitalOut.from_row(h) for h in rows]


def _active_enrollment(db: Session, user_id) -> HospitalEnrollment | None:
    return (
        db.query(HospitalEnrollment)
        .filter(HospitalEnrollment.patient_id == user_id, HospitalEnrollment.status != EnrollmentStatus.rejected)
        .order_by(HospitalEnrollment.created_at.desc())
        .first()
    )


@router.get("/enrollment/status", response_model=EnrollmentStatusOut)
def enrollment_status(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    enr = _active_enrollment(db, user.id)
    if not enr:
        return EnrollmentStatusOut(status="none")
    hosp = db.query(Hospital).filter(Hospital.id == enr.hospital_id).first()
    return EnrollmentStatusOut(
        status=enr.status.value,
        hospital_id=str(enr.hospital_id),
        hospital_name=hosp.name if hosp else None,
    )


@router.post("/enrollment/by-code", response_model=EnrollmentStatusOut)
def enroll_by_code(payload: EnrollByCode, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    code = db.query(EnrollmentCode).filter(EnrollmentCode.code == payload.code.strip().upper()).first()
    if not code or not code.is_active:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "That code is not valid. Please check with your clinic.")
    if code.expires_at and code.expires_at < now:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "That code has expired.")
    if code.max_uses is not None and code.used_count >= code.max_uses:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "That code has already been used.")

    if _active_enrollment(db, user.id):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "You are already connected to a hospital.")

    enr = HospitalEnrollment(
        patient_id=user.id,
        hospital_id=code.hospital_id,
        status=EnrollmentStatus.approved,          # code path = auto-approved
        initiated_by=EnrollmentInitiatedBy.code,
        code_used=code.code,
        requested_at=now,
        approved_at=now,
    )
    db.add(enr)
    code.used_count += 1
    user.hospital_id = code.hospital_id
    assign_care_team(db, user, code.hospital_id)  # code path is approved → wire the care team now
    db.commit()

    hosp = db.query(Hospital).filter(Hospital.id == code.hospital_id).first()
    return EnrollmentStatusOut(status="approved", hospital_id=str(code.hospital_id), hospital_name=hosp.name if hosp else None)


@router.post("/enrollment/request", response_model=EnrollmentStatusOut)
def enroll_request(payload: EnrollRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    hosp = db.query(Hospital).filter(Hospital.id == payload.hospital_id).first()
    if not hosp:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Hospital not found.")
    if _active_enrollment(db, user.id):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "You already have a pending or active hospital connection.")

    enr = HospitalEnrollment(
        patient_id=user.id,
        hospital_id=hosp.id,
        status=EnrollmentStatus.pending,           # pick path = needs hospital approval
        initiated_by=EnrollmentInitiatedBy.patient,
        requested_at=now,
    )
    db.add(enr)
    user.hospital_id = hosp.id  # tentative; care-team features still gated until approved
    db.commit()
    return EnrollmentStatusOut(status="pending", hospital_id=str(hosp.id), hospital_name=hosp.name)


# ---------------------------------------------------------------------------
# Hospital coordinator side — review & approve patients requesting to join.
# Scoped to the coordinator's own hospital.
# ---------------------------------------------------------------------------

@router.get("/enrollment/pending", response_model=list[EnrollmentStatusOut])
def list_pending(coord: User = Depends(get_current_coordinator), db: Session = Depends(get_db)):
    if not coord.hospital_id:
        return []
    rows = (
        db.query(HospitalEnrollment)
        .filter(
            HospitalEnrollment.hospital_id == coord.hospital_id,
            HospitalEnrollment.status == EnrollmentStatus.pending,
        )
        .order_by(HospitalEnrollment.requested_at.asc())
        .all()
    )
    out = []
    for enr in rows:
        patient = db.query(User).filter(User.id == enr.patient_id).first()
        out.append(EnrollmentStatusOut(
            status="pending",
            enrollment_id=str(enr.id),
            hospital_id=str(enr.hospital_id),
            patient_name=patient.name if patient else None,
            patient_email=patient.email if patient else None,
        ))
    return out


@router.post("/enrollment/{enrollment_id}/approve", response_model=EnrollmentStatusOut)
def approve_enrollment(enrollment_id: str, coord: User = Depends(get_current_coordinator), db: Session = Depends(get_db)):
    enr = db.query(HospitalEnrollment).filter(HospitalEnrollment.id == enrollment_id).first()
    if not enr:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Enrollment not found.")
    if enr.hospital_id != coord.hospital_id:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Not your hospital.")
    if enr.status != EnrollmentStatus.pending:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "This request is not pending.")

    now = datetime.now(timezone.utc)
    enr.status = EnrollmentStatus.approved
    enr.approved_at = now
    patient = db.query(User).filter(User.id == enr.patient_id).first()
    if patient:
        patient.hospital_id = enr.hospital_id
        assign_care_team(db, patient, enr.hospital_id)  # turn on monitoring
    db.commit()
    hosp = db.query(Hospital).filter(Hospital.id == enr.hospital_id).first()
    return EnrollmentStatusOut(status="approved", hospital_id=str(enr.hospital_id), hospital_name=hosp.name if hosp else None)


@router.post("/enrollment/{enrollment_id}/reject", response_model=EnrollmentStatusOut)
def reject_enrollment(enrollment_id: str, coord: User = Depends(get_current_coordinator), db: Session = Depends(get_db)):
    enr = db.query(HospitalEnrollment).filter(HospitalEnrollment.id == enrollment_id).first()
    if not enr:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Enrollment not found.")
    if enr.hospital_id != coord.hospital_id:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Not your hospital.")
    enr.status = EnrollmentStatus.rejected
    patient = db.query(User).filter(User.id == enr.patient_id).first()
    if patient and patient.hospital_id == enr.hospital_id:
        patient.hospital_id = None  # release the tentative link
    db.commit()
    return EnrollmentStatusOut(status="rejected", hospital_id=str(enr.hospital_id))
