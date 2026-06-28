"""Education Hub + CMS (FR-180–184).

  Admin/clinician: create, edit, upload media for, publish & delete content.
  Patient: browse published content (filtered to their surgery type), stream
           media, track progress, favourite.

Media goes through the swappable storage backend (local filesystem or S3 — see
app/core/storage.py); the DB stores only the storage reference.
"""
import uuid
from datetime import datetime, timezone
from pathlib import Path

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from fastapi.responses import RedirectResponse, Response
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.core.storage import storage
from app.database import get_db
from app.enums import ContentTopic, ContentType, UserRole
from app.models import ContentProgress, EducationContent, User

router = APIRouter(prefix="/api", tags=["education"])


def _staff(user: User = Depends(get_current_user)) -> User:
    if user.role not in (UserRole.admin, UserRole.clinician):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Staff access only.")
    return user


def _out(c: EducationContent) -> dict:
    return {
        "id": str(c.id), "title": c.title, "type": c.type.value if c.type else None,
        "topic": c.topic.value if c.topic else None, "stage": c.stage,
        "surgery_types": c.surgery_types, "duration_sec": c.duration_sec,
        "category": c.category, "has_media": bool(c.s3_key),
        "has_german_subtitles": c.has_german_subtitles, "sort_order": c.sort_order,
        "published": c.published,
        # Externally-hosted media is returned directly; uploaded files stream via our route.
        "media_url": (
            c.s3_key if (c.s3_key or "").startswith("http")
            else (f"/api/education/media/{c.id}" if c.s3_key else None)
        ),
    }


# --------------------------------------------------------------------------
# Admin / clinician CMS
# --------------------------------------------------------------------------
class ContentIn(BaseModel):
    title: str
    type: ContentType = ContentType.video
    topic: ContentTopic | None = None
    stage: str | None = None
    surgery_types: list[str] | None = None   # None = applies to all
    duration_sec: int | None = None
    category: str | None = None
    external_url: str | None = None          # use a hosted URL instead of an upload
    has_german_subtitles: bool = False
    sort_order: int = 0
    published: bool = True


class ContentUpdate(BaseModel):
    """Partial update — only the fields the client sends are changed."""
    title: str | None = None
    type: ContentType | None = None
    topic: ContentTopic | None = None
    stage: str | None = None
    surgery_types: list[str] | None = None
    duration_sec: int | None = None
    category: str | None = None
    external_url: str | None = None
    has_german_subtitles: bool | None = None
    sort_order: int | None = None
    published: bool | None = None


@router.get("/admin/content")
def admin_list(staff: User = Depends(_staff), db: Session = Depends(get_db)):
    rows = db.query(EducationContent).order_by(EducationContent.sort_order, EducationContent.title).all()
    return [_out(c) for c in rows]


@router.post("/admin/content")
def admin_create(payload: ContentIn, staff: User = Depends(_staff), db: Session = Depends(get_db)):
    c = EducationContent(
        title=payload.title, type=payload.type, topic=payload.topic, stage=payload.stage,
        surgery_types=payload.surgery_types, duration_sec=payload.duration_sec,
        category=payload.category, s3_key=payload.external_url,
        has_german_subtitles=payload.has_german_subtitles, sort_order=payload.sort_order,
        published=payload.published,
    )
    db.add(c); db.commit(); db.refresh(c)
    return _out(c)


@router.patch("/admin/content/{content_id}")
def admin_update(content_id: uuid.UUID, payload: ContentUpdate, staff: User = Depends(_staff), db: Session = Depends(get_db)):
    c = db.query(EducationContent).filter(EducationContent.id == content_id).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Content not found.")
    data = payload.model_dump(exclude_unset=True)  # only fields the client sent
    ext = data.pop("external_url", None)
    for k, v in data.items():
        setattr(c, k, v)
    if ext:
        c.s3_key = ext
    db.commit(); db.refresh(c)
    return _out(c)


@router.post("/admin/content/{content_id}/upload")
def admin_upload(content_id: uuid.UUID, file: UploadFile = File(...), staff: User = Depends(_staff), db: Session = Depends(get_db)):
    c = db.query(EducationContent).filter(EducationContent.id == content_id).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Content not found.")
    ext = Path(file.filename or "").suffix[:10]
    c.s3_key = storage.save(
        f"education/{content_id}{ext}", file.file.read(),
        content_type=file.content_type or "application/octet-stream",
    )
    db.commit()
    return {"id": str(c.id), "media_url": f"/api/education/media/{c.id}", "stored": c.s3_key}


@router.delete("/admin/content/{content_id}", status_code=204)
def admin_delete(content_id: uuid.UUID, staff: User = Depends(_staff), db: Session = Depends(get_db)):
    c = db.query(EducationContent).filter(EducationContent.id == content_id).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Content not found.")
    db.query(ContentProgress).filter(ContentProgress.content_id == content_id).delete()
    db.delete(c); db.commit()


# --------------------------------------------------------------------------
# Patient Education Hub
# --------------------------------------------------------------------------
@router.get("/education")
def patient_list(topic: str | None = None, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    q = db.query(EducationContent).filter(EducationContent.published.is_(True))
    if topic:
        try:
            q = q.filter(EducationContent.topic == ContentTopic(topic))
        except ValueError:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid topic.")
    rows = q.order_by(EducationContent.sort_order, EducationContent.title).all()
    # Filter by surgery type: surgery_types null/empty = applies to everyone.
    st = user.surgery_type.value if user.surgery_type else None
    visible = [c for c in rows if not c.surgery_types or (st and st in c.surgery_types)]
    # Attach the patient's progress.
    prog = {p.content_id: p for p in db.query(ContentProgress).filter(ContentProgress.user_id == user.id)}
    out = []
    for c in visible:
        d = _out(c)
        p = prog.get(c.id)
        d["progress"] = {"completed": p.completed, "favourited": p.favourited,
                         "resume_position_sec": p.resume_position_sec} if p else None
        out.append(d)
    return out


@router.get("/education/media/{content_id}")
def stream_media(content_id: uuid.UUID, db: Session = Depends(get_db)):
    c = db.query(EducationContent).filter(EducationContent.id == content_id).first()
    if not c or not c.s3_key:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Media not found.")
    if c.s3_key.startswith("http"):
        # External hosted media — the client should use the URL directly.
        raise HTTPException(status.HTTP_409_CONFLICT, "External media; use media_url field.")
    # S3 backend can hand back a presigned URL; otherwise stream the bytes.
    presigned = storage.url(c.s3_key)
    if presigned:
        return RedirectResponse(presigned)
    data = storage.read(c.s3_key)
    if data is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "File missing.")
    return Response(content=data, media_type="application/octet-stream")


class ProgressIn(BaseModel):
    resume_position_sec: int | None = None
    completed: bool | None = None
    favourited: bool | None = None


@router.post("/education/{content_id}/progress")
def track_progress(content_id: uuid.UUID, payload: ProgressIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = db.query(EducationContent).filter(EducationContent.id == content_id).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Content not found.")
    p = db.query(ContentProgress).filter(ContentProgress.user_id == user.id, ContentProgress.content_id == content_id).first()
    if not p:
        p = ContentProgress(user_id=user.id, content_id=content_id)
        db.add(p)
    if payload.resume_position_sec is not None:
        p.resume_position_sec = payload.resume_position_sec
    if payload.completed is not None:
        p.completed = payload.completed
    if payload.favourited is not None:
        p.favourited = payload.favourited
    p.last_viewed_at = datetime.now(timezone.utc)
    db.commit()
    return {"content_id": str(content_id), "completed": p.completed,
            "favourited": p.favourited, "resume_position_sec": p.resume_position_sec}
