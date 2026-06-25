"""Appointments / calendar for the authenticated patient (FR-161)."""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.models import Appointment, User
from app.schemas.appointment import AppointmentOut

router = APIRouter(prefix="/api/appointments", tags=["appointments"])


@router.get("", response_model=list[AppointmentOut])
def list_appointments(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(Appointment)
        .filter(Appointment.user_id == user.id)
        .order_by(Appointment.date)
        .all()
    )
    return [AppointmentOut.from_row(a) for a in rows]
