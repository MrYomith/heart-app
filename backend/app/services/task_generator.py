"""Phase-based daily plan generation (FR-021, FR-160).

Real patients should always open the app to a relevant daily plan. When no
tasks exist for a given day we generate a phase-appropriate set on the fly,
persist them, and let the patient tick them off (which drives daily progress).
"""
from datetime import date

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.enums import PhaseKey, TaskCategory
from app.models import Task, User

C = TaskCategory

# (title, subtitle, icon, category, scheduled_time, time_color)
_TEMPLATES: dict[PhaseKey, list[tuple]] = {
    PhaseKey.diagnosis: [
        ("Learn about your condition", "Watch a short explainer", "📖", C.education, "Morning", "teal"),
        ("Emotional check-in", "How are you feeling today?", "💚", C.emotional, "Anytime", "teal"),
        ("Review your medications", "Know what each one does", "💊", C.medication, "08:00", "teal"),
        ("Gentle walk", "10–15 minutes at your pace", "🚶", C.activity, "Afternoon", "orange"),
        ("Heart-healthy meal", "Plenty of vegetables & lean protein", "🥗", C.nutrition, "Lunch", "teal"),
    ],
    PhaseKey.preop: [
        ("Breathing practice", "Spirometry / deep breathing", "🫁", C.breathing, "Morning", "teal"),
        ("Prehab walk", "Build stamina before surgery", "🚶", C.activity, "Afternoon", "orange"),
        ("Confirm fasting plan", "Check your pre-surgery instructions", "🍽️", C.nutrition, "Evening", "teal"),
        ("Review medication pause", "Which meds to stop & when", "💊", C.medication, "08:00", "teal"),
        ("Emotional check-in", "How are you feeling today?", "💚", C.emotional, "Anytime", "teal"),
    ],
    PhaseKey.surgery: [
        ("Follow fasting guidance", "Nothing to eat/drink as advised", "🚫", C.nutrition, "Morning", "orange"),
        ("Calm breathing", "4-7-8 breathing to ease nerves", "🫁", C.breathing, "Anytime", "teal"),
        ("Message your care team", "Ask any last questions", "💬", C.emotional, "Anytime", "teal"),
    ],
    PhaseKey.inpatient: [
        ("Breathing exercise", "Incentive spirometry – 10 breaths", "🫁", C.breathing, "Morning", "teal"),
        ("Mobilisation", "Short walk with assistance", "🚶", C.activity, "10:00", "orange"),
        ("Pain check-in", "Rate your pain so we can help", "😣", C.emotional, "Anytime", "teal"),
        ("Protein & fluids", "Support healing with nutrition", "🥣", C.nutrition, "Lunch", "teal"),
        ("Hydration", "Sip water through the day", "💧", C.hydration, "All day", "teal"),
        ("Medications", "Take as scheduled", "💊", C.medication, "14:00", "teal"),
        ("Wound check", "Note anything unusual", "🩹", C.wound, "20:00", "teal"),
    ],
    PhaseKey.rehab: [
        ("Cardiac rehab / walk", "Aim for your daily activity goal", "🚶", C.activity, "Morning", "orange"),
        ("Medications", "Including any anticoagulant", "💊", C.medication, "08:00", "teal"),
        ("Sternal-safe movement", "Protect your healing sternum", "🛡️", C.activity, "Afternoon", "teal"),
        ("Mood check-in", "Track how you're feeling", "💚", C.emotional, "Evening", "teal"),
        ("Heart-healthy meal", "Balanced, low-salt plate", "🥗", C.nutrition, "Lunch", "teal"),
    ],
    PhaseKey.thriving: [
        ("30 minutes of activity", "Walking, cycling or swimming", "🏃", C.activity, "Morning", "orange"),
        ("Medications", "Keep your routine consistent", "💊", C.medication, "08:00", "teal"),
        ("Mindfulness", "5–10 minutes to reset", "🧘", C.emotional, "Anytime", "teal"),
        ("Heart-healthy meal", "Mediterranean-style eating", "🥗", C.nutrition, "Lunch", "teal"),
        ("Gratitude note", "One good thing about today", "📔", C.emotional, "Evening", "teal"),
    ],
}


# "Why this?" — clinical reasoning Mio shows per task category (FR-160).
_REASONING: dict = {
    C.breathing: "Deep breathing re-expands your lungs and lowers the risk of chest infection after surgery.",
    C.activity: "Gentle movement improves circulation, prevents clots, and rebuilds your strength safely.",
    C.nutrition: "Good protein and nutrients give your heart and tissues what they need to heal.",
    C.hydration: "Staying hydrated supports your circulation and helps your medications work well.",
    C.medication: "Taking your medicines on time protects your heart and your surgical result.",
    C.emotional: "Checking in on your mood helps us support you — recovery is emotional as well as physical.",
    C.education: "Understanding your journey reduces anxiety and helps you make confident decisions.",
    C.wound: "Watching your wound means we catch any concern early and keep healing on track.",
}


def ensure_today_tasks(db: Session, user: User, day: str) -> list[Task]:
    """Return the user's tasks for `day`, generating a phase-appropriate plan
    (persisted) if none exist yet. Only generates for the current calendar day
    so historical dates stay accurate."""
    existing = (
        db.query(Task)
        .filter(Task.user_id == user.id, Task.task_date == day)
        .order_by(Task.priority)
        .all()
    )
    if existing or day != date.today().isoformat():
        return existing

    phase = user.current_phase or PhaseKey.diagnosis
    templates = _TEMPLATES.get(phase, _TEMPLATES[PhaseKey.diagnosis])
    created = [
        Task(
            user_id=user.id, title=t[0], subtitle=t[1], icon=t[2], category=t[3],
            scheduled_time=t[4], time_color=t[5], is_done=False, priority=i + 1,
            phase=phase.value, task_date=day, reasoning=_REASONING.get(t[3]),
        )
        for i, t in enumerate(templates)
    ]
    db.add_all(created)
    try:
        db.commit()
    except IntegrityError:
        # A concurrent request already generated today's plan (unique index on
        # user_id+task_date+title). Roll back and return the winning rows —
        # this is what prevented the "tasks shown double" bug.
        db.rollback()
        return (
            db.query(Task)
            .filter(Task.user_id == user.id, Task.task_date == day)
            .order_by(Task.priority)
            .all()
        )
    for c in created:
        db.refresh(c)
    return created
