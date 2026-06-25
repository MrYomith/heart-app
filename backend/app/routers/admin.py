"""Admin board (role=admin) — manage the platform's real data, not mock seeds.

  Hospitals (CRUD) · enrollment codes · message templates (FR-203) ·
  clinician/care-team accounts · platform stats · user list.
Admins manage accounts and configuration; they do NOT see patient clinical data
(PRD §1.5 Administrator role).
"""
import secrets
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.core.security import hash_password
from app.database import get_db
from app.enums import ClinicianRole, HospitalType, UserRole
from app.models import (
    Alert,
    EnrollmentCode,
    Hospital,
    MessageTemplate,
    User,
)

router = APIRouter(prefix="/api/admin", tags=["admin"])


def get_current_admin(user: User = Depends(get_current_user)) -> User:
    if user.role != UserRole.admin:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Admin access only.")
    return user


def _now() -> datetime:
    return datetime.now(timezone.utc)


# --------------------------------------------------------------------------
# Platform stats
# --------------------------------------------------------------------------
@router.get("/stats")
def stats(admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return {
        "patients": db.query(User).filter(User.role == UserRole.patient, User.deleted_at.is_(None)).count(),
        "clinicians": db.query(User).filter(User.role == UserRole.clinician).count(),
        "hospitals": db.query(Hospital).count(),
        "open_alerts": db.query(Alert).filter(Alert.resolved_at.is_(None)).count(),
        "enrollment_codes": db.query(EnrollmentCode).filter(EnrollmentCode.is_active.is_(True)).count(),
    }


# --------------------------------------------------------------------------
# Hospitals
# --------------------------------------------------------------------------
class HospitalIn(BaseModel):
    name: str
    city: str | None = None
    address: str | None = None
    phone: str | None = None
    type: HospitalType = HospitalType.hospital
    surgeon_message: str | None = None


def _hosp_out(h: Hospital) -> dict:
    return {"id": str(h.id), "name": h.name, "city": h.city, "address": h.address,
            "phone": h.phone, "type": h.type.value if h.type else "hospital",
            "surgeon_message": h.surgeon_message}


@router.get("/hospitals")
def list_hospitals(admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return [_hosp_out(h) for h in db.query(Hospital).order_by(Hospital.name).all()]


@router.post("/hospitals")
def create_hospital(payload: HospitalIn, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    h = Hospital(name=payload.name, city=payload.city, address=payload.address,
                 phone=payload.phone, type=payload.type, surgeon_message=payload.surgeon_message)
    db.add(h); db.commit(); db.refresh(h)
    return _hosp_out(h)


@router.patch("/hospitals/{hospital_id}")
def update_hospital(hospital_id: uuid.UUID, payload: HospitalIn, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    h = db.query(Hospital).filter(Hospital.id == hospital_id).first()
    if not h:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Hospital not found.")
    h.name = payload.name; h.city = payload.city; h.address = payload.address
    h.phone = payload.phone; h.type = payload.type; h.surgeon_message = payload.surgeon_message
    db.commit(); db.refresh(h)
    return _hosp_out(h)


@router.delete("/hospitals/{hospital_id}", status_code=204)
def delete_hospital(hospital_id: uuid.UUID, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    h = db.query(Hospital).filter(Hospital.id == hospital_id).first()
    if not h:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Hospital not found.")
    if db.query(User).filter(User.hospital_id == hospital_id).count() > 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Hospital has linked users; reassign them first.")
    db.delete(h); db.commit()


# --------------------------------------------------------------------------
# Enrollment codes
# --------------------------------------------------------------------------
class CodeIn(BaseModel):
    hospital_id: uuid.UUID
    label: str | None = None
    max_uses: int | None = None


def _code_out(c: EnrollmentCode) -> dict:
    return {"id": str(c.id), "code": c.code, "hospital_id": str(c.hospital_id), "label": c.label,
            "is_active": c.is_active, "max_uses": c.max_uses, "used_count": c.used_count}


@router.get("/codes")
def list_codes(admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return [_code_out(c) for c in db.query(EnrollmentCode).order_by(EnrollmentCode.created_at.desc()).all()]


@router.post("/codes")
def create_code(payload: CodeIn, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    hosp = db.query(Hospital).filter(Hospital.id == payload.hospital_id).first()
    if not hosp:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Hospital not found.")
    code = f"{(hosp.name[:4] or 'HOSP').upper().replace(' ', '')}-{secrets.token_hex(2).upper()}"
    c = EnrollmentCode(hospital_id=payload.hospital_id, code=code, label=payload.label,
                       is_active=True, max_uses=payload.max_uses, used_count=0)
    db.add(c); db.commit(); db.refresh(c)
    return _code_out(c)


@router.patch("/codes/{code_id}/toggle")
def toggle_code(code_id: uuid.UUID, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    c = db.query(EnrollmentCode).filter(EnrollmentCode.id == code_id).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Code not found.")
    c.is_active = not c.is_active
    db.commit(); db.refresh(c)
    return _code_out(c)


# --------------------------------------------------------------------------
# Care-team accounts (clinicians)
# --------------------------------------------------------------------------
class ClinicianIn(BaseModel):
    name: str
    email: EmailStr
    password: str
    specialty: ClinicianRole
    hospital_id: uuid.UUID


@router.get("/clinicians")
def list_clinicians(admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    rows = db.query(User).filter(User.role == UserRole.clinician).all()
    return [{"id": str(c.id), "name": c.name, "email": c.email,
             "specialty": c.clinician_specialty.value if c.clinician_specialty else None,
             "hospital_id": str(c.hospital_id) if c.hospital_id else None} for c in rows]


@router.post("/clinicians")
def create_clinician(payload: ClinicianIn, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == payload.email).first():
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "An account with this email already exists.")
    c = User(name=payload.name, email=payload.email, password_hash=hash_password(payload.password),
             role=UserRole.clinician, clinician_specialty=payload.specialty,
             hospital_id=payload.hospital_id, onboarding_complete=True)
    db.add(c); db.commit(); db.refresh(c)
    return {"id": str(c.id), "name": c.name, "email": c.email, "specialty": c.clinician_specialty.value}


# --------------------------------------------------------------------------
# Message templates (FR-203)
# --------------------------------------------------------------------------
class TemplateIn(BaseModel):
    title: str
    body: str
    clinician_role: ClinicianRole | None = None


@router.get("/templates")
def list_templates(admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    rows = db.query(MessageTemplate).all()
    return [{"id": str(t.id), "title": t.title, "body": t.body,
             "clinician_role": t.clinician_role.value if t.clinician_role else None} for t in rows]


@router.post("/templates")
def create_template(payload: TemplateIn, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    t = MessageTemplate(title=payload.title, body=payload.body,
                        clinician_role=payload.clinician_role, created_by=admin.id)
    db.add(t); db.commit(); db.refresh(t)
    return {"id": str(t.id), "title": t.title, "body": t.body}


@router.delete("/templates/{template_id}", status_code=204)
def delete_template(template_id: uuid.UUID, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    t = db.query(MessageTemplate).filter(MessageTemplate.id == template_id).first()
    if not t:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Template not found.")
    db.delete(t); db.commit()
