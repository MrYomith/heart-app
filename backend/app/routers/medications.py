from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.medication import Medication
from app.schemas.medication import MedicationOut

router = APIRouter(prefix="/api/medications", tags=["medications"])


@router.get("/user/{user_id}", response_model=List[MedicationOut])
def get_medications(user_id: int, db: Session = Depends(get_db)):
    return db.query(Medication).filter(
        Medication.user_id == user_id,
        Medication.is_active == True
    ).all()


@router.post("/", response_model=MedicationOut, status_code=201)
def add_medication(payload: dict, db: Session = Depends(get_db)):
    med = Medication(**payload)
    db.add(med)
    db.commit()
    db.refresh(med)
    return med


@router.patch("/{med_id}", response_model=MedicationOut)
def update_medication(med_id: int, payload: dict, db: Session = Depends(get_db)):
    med = db.query(Medication).filter(Medication.id == med_id).first()
    if not med:
        raise HTTPException(status_code=404, detail="Medication not found")
    for key, value in payload.items():
        if hasattr(med, key):
            setattr(med, key, value)
    db.commit()
    db.refresh(med)
    return med


@router.delete("/{med_id}", status_code=204)
def remove_medication(med_id: int, db: Session = Depends(get_db)):
    med = db.query(Medication).filter(Medication.id == med_id).first()
    if not med:
        raise HTTPException(status_code=404, detail="Medication not found")
    med.is_active = False
    db.commit()
