from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.appointment import Appointment
from app.schemas.appointment import AppointmentOut

router = APIRouter(prefix="/api/appointments", tags=["appointments"])


@router.get("/user/{user_id}", response_model=List[AppointmentOut])
def get_appointments(user_id: int, db: Session = Depends(get_db)):
    return (
        db.query(Appointment)
        .filter(Appointment.user_id == user_id)
        .order_by(Appointment.date)
        .all()
    )


@router.post("/", response_model=AppointmentOut, status_code=201)
def create_appointment(payload: dict, db: Session = Depends(get_db)):
    appt = Appointment(**payload)
    db.add(appt)
    db.commit()
    db.refresh(appt)
    return appt


@router.delete("/{appt_id}", status_code=204)
def delete_appointment(appt_id: int, db: Session = Depends(get_db)):
    appt = db.query(Appointment).filter(Appointment.id == appt_id).first()
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found")
    db.delete(appt)
    db.commit()
