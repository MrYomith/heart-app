"""Admin-managed content & catalogs (AppContent).

Patient reads published items by category/stage (global + their hospital's
overrides). Admin does full CRUD so symptoms, phase resources, emergency
contacts, fasting steps, reminders and support links are editable without an
app release.
"""
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.models import AppContent, User
from app.routers.admin import get_current_admin

router = APIRouter(prefix="/api", tags=["content"])


def _out(c: AppContent) -> dict:
    return {
        "id": str(c.id), "category": c.category, "item_key": c.item_key, "title": c.title,
        "body": c.body, "emoji": c.emoji, "severity": c.severity, "stage": c.stage,
        "section": c.section, "payload": c.payload, "sort_order": c.sort_order,
        "hospital_id": str(c.hospital_id) if c.hospital_id else None, "published": c.published,
    }


# ── Patient read ──────────────────────────────────────────────────────────
@router.get("/content")
def list_content(category: str, stage: str | None = None,
                 user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    q = db.query(AppContent).filter(AppContent.category == category, AppContent.published.is_(True))
    # Global items (hospital_id null) + the patient's hospital overrides.
    q = q.filter(or_(AppContent.hospital_id.is_(None), AppContent.hospital_id == user.hospital_id))
    if stage:
        q = q.filter(AppContent.stage == stage)
    rows = q.order_by(AppContent.sort_order, AppContent.title).all()
    return [_out(c) for c in rows]


# ── Admin CRUD ────────────────────────────────────────────────────────────
class ContentIn(BaseModel):
    category: str
    title: str
    item_key: str | None = None
    body: str | None = None
    emoji: str | None = None
    severity: str | None = None
    stage: str | None = None
    section: str | None = None
    payload: dict | None = None
    sort_order: int = 0
    published: bool = True


class ContentPatch(BaseModel):
    """Partial update — only the fields the client sends are changed."""
    category: str | None = None
    title: str | None = None
    item_key: str | None = None
    body: str | None = None
    emoji: str | None = None
    severity: str | None = None
    stage: str | None = None
    section: str | None = None
    payload: dict | None = None
    sort_order: int | None = None
    published: bool | None = None


@router.get("/admin/app-content")
def admin_list(category: str | None = None, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    q = db.query(AppContent)
    if category:
        q = q.filter(AppContent.category == category)
    return [_out(c) for c in q.order_by(AppContent.category, AppContent.sort_order).all()]


@router.post("/admin/app-content")
def admin_create(payload: ContentIn, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    c = AppContent(**payload.model_dump())
    db.add(c); db.commit(); db.refresh(c)
    return _out(c)


@router.patch("/admin/app-content/{content_id}")
def admin_update(content_id: uuid.UUID, payload: ContentPatch, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    c = db.query(AppContent).filter(AppContent.id == content_id).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Content not found.")
    for k, v in payload.model_dump(exclude_unset=True).items():  # only sent fields
        setattr(c, k, v)
    db.commit(); db.refresh(c)
    return _out(c)


@router.delete("/admin/app-content/{content_id}", status_code=204)
def admin_delete(content_id: uuid.UUID, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    c = db.query(AppContent).filter(AppContent.id == content_id).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Content not found.")
    db.delete(c); db.commit()
