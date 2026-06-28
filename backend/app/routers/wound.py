"""Wound photo log (FR-104).

Images go through the swappable storage backend (local filesystem or S3 — see
app/core/storage.py) and are returned base64 for in-app display. The DB stores only
the storage reference, so switching to encrypted S3 is a config change. Day-3
dressing lock per the PRD.
"""
import base64
import uuid
from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends, File, UploadFile
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.core.storage import storage
from app.database import get_db
from app.models import User, WoundPhoto
from app.schemas.wound import WoundPhotoOut, WoundStatusOut

router = APIRouter(prefix="/api/wound-photos", tags=["wound"])

DRESSING_LOCK_DAYS = 3


def _day_and_lock(user: User) -> tuple[int | None, bool]:
    if user.surgery_date:
        delta = (date.today() - user.surgery_date).days
        if delta >= 0:
            return delta, delta < DRESSING_LOCK_DAYS
    return None, False


def _to_out(row: WoundPhoto, include_image: bool) -> WoundPhotoOut:
    image_b64 = None
    if include_image and row.s3_key:
        data = storage.read(row.s3_key)
        if data is not None:
            image_b64 = base64.b64encode(data).decode()
    return WoundPhotoOut(
        id=str(row.id),
        day_post_op=row.day_post_op,
        uploaded_at=row.uploaded_at.isoformat() if row.uploaded_at else None,
        reviewed=row.reviewed_by is not None,
        image_base64=image_b64,
    )


@router.get("/status", response_model=WoundStatusOut)
def status(user: User = Depends(get_current_user)):
    day, locked = _day_and_lock(user)
    if locked:
        msg = f"Keep your dressing on — do not remove it before Day {DRESSING_LOCK_DAYS}. You can still photograph the outside of the dressing."
    elif day is not None:
        msg = "You can change your dressing and photograph the wound. Log it daily so your nurse can review."
    else:
        msg = "Photograph your wound daily so your care team can keep an eye on healing."
    return WoundStatusOut(day_post_op=day, dressing_locked=locked, message=msg)


@router.get("", response_model=list[WoundPhotoOut])
def list_photos(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(WoundPhoto)
        .filter(WoundPhoto.user_id == user.id)
        .order_by(WoundPhoto.uploaded_at.desc().nullslast())
        .all()
    )
    return [_to_out(r, include_image=True) for r in rows]


@router.post("", response_model=WoundPhotoOut, status_code=201)
async def upload_photo(file: UploadFile = File(...), user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    day, _ = _day_and_lock(user)
    fid = uuid.uuid4()
    ref = storage.save(f"wound/{fid}.jpg", await file.read(), content_type=file.content_type or "image/jpeg")
    row = WoundPhoto(id=fid, user_id=user.id, s3_key=ref, day_post_op=day, is_locked=False, uploaded_at=now)
    db.add(row)
    db.commit()
    db.refresh(row)
    return _to_out(row, include_image=True)
