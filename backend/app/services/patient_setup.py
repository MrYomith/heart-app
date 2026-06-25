"""Set up a patient's journey + starter daily plan when onboarding completes.

Gives Home / Journey / Today's Plan real content immediately. The richer
auto-generation per stage (FR-160) comes with the Stage features later.
"""
from datetime import date, datetime, timedelta, timezone

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.enums import (
    AppointmentType,
    ErasItem,
    MessageCategory,
    MobilisationMilestone,
    PhaseKey,
    PhaseStatus,
    SurgeryType,
    TaskCategory,
)
from app.models import (
    Appointment,
    ErasProgress,
    JourneyPhase,
    Medication,
    Message,
    MessageThread,
    MobilisationMilestoneLog,
    Task,
    User,
)

_PHASES = [
    (PhaseKey.diagnosis, "Diagnosis", "🫀", "Understanding your condition"),
    (PhaseKey.preop, "Pre-op Preparation", "🛡️", "Getting ready for surgery"),
    (PhaseKey.surgery, "Surgery Day", "🏥", "The day of your operation"),
    (PhaseKey.inpatient, "Inpatient Recovery", "🩹", "Healing in hospital"),
    (PhaseKey.rehab, "Post-Discharge Rehab", "🚶", "Getting stronger at home"),
    (PhaseKey.thriving, "Thriving", "⭐", "Living well long-term"),
]

# (icon, title, subtitle, category, scheduled_time, time_color)
_STARTER_TASKS = [
    ("❤️", "Emotional check-in", "How are you feeling today?", TaskCategory.emotional, "Evening", "orange"),
    ("📖", "Learn about your surgery", "Watch today's short video", TaskCategory.education, "Morning", "teal"),
    ("🚶", "Gentle walk", "15 minutes at your own pace", TaskCategory.activity, "10:00", "teal"),
    ("💧", "Hydration", "Drink 6–8 glasses of water", TaskCategory.hydration, "Throughout day", "teal"),
    ("💊", "Medications", "Take your scheduled medications", TaskCategory.medication, "08:00", "teal"),
]


def seed_journey(db: Session, user: User) -> None:
    if db.query(JourneyPhase).filter(JourneyPhase.user_id == user.id).first():
        return
    for i, (key, label, emoji, subtitle) in enumerate(_PHASES):
        db.add(JourneyPhase(
            user_id=user.id,
            phase_key=key,
            label=label,
            emoji=emoji,
            subtitle=subtitle,
            status=PhaseStatus.active if i == 0 else PhaseStatus.upcoming,
            sort_order=i,
        ))


def seed_starter_tasks(db: Session, user: User) -> None:
    today = date.today().isoformat()
    exists = db.query(Task).filter(Task.user_id == user.id, Task.task_date == today).first()
    if exists:
        return
    for i, (icon, title, subtitle, cat, when, color) in enumerate(_STARTER_TASKS):
        db.add(Task(
            user_id=user.id,
            title=title,
            subtitle=subtitle,
            icon=icon,
            category=cat,
            scheduled_time=when,
            time_color=color,
            phase=user.current_phase.value if user.current_phase else "diagnosis",
            task_date=today,
            priority=i + 1,
        ))


def seed_welcome_message(db: Session, user: User) -> None:
    if db.query(MessageThread).filter(MessageThread.patient_id == user.id).first():
        return
    now = datetime.now(timezone.utc)
    thread = MessageThread(
        patient_id=user.id,
        category=MessageCategory.care_team,
        subject="Welcome to MioHeart",
        last_message_at=now,
    )
    db.add(thread)
    db.flush()
    db.add(Message(
        thread_id=thread.id,
        sender_role="MioHeart Care Team",
        body=(
            "Welcome to MioHeart! 🤍 I'm here to guide you through every step of your "
            "heart journey. Your daily plan is ready on the Home screen. If anything "
            "worries you, you can reach your care team right here, anytime."
        ),
        is_read=False,
        sent_at=now,
    ))


# Provisional starting regimens by surgery type. The hospital/clinician confirms or
# edits these per patient (Step 3) — they are sensible defaults, not a prescription.
# (name, dose, schedule, times, anticoagulant, purpose)
_MED_TEMPLATES = {
    SurgeryType.cabg: [
        ("Aspirin", "100 mg", "Once every morning", "08:00", True, "Keeps your blood from clotting and protects your new graft."),
        ("Metoprolol", "25 mg", "Twice daily", "08:00,20:00", False, "Slows and steadies your heart, lowering its workload."),
        ("Atorvastatin", "40 mg", "Once at bedtime", "20:00", False, "Lowers cholesterol to protect your arteries."),
        ("Ramipril", "5 mg", "Once every morning", "08:00", False, "Relaxes blood vessels and protects your heart."),
    ],
    SurgeryType.valve: [
        ("Warfarin", "As per INR", "Once each evening", "18:00", True, "Prevents clots forming on your new valve — your dose follows your INR blood test."),
        ("Bisoprolol", "2.5 mg", "Once every morning", "08:00", False, "Steadies your heart rhythm and rate."),
        ("Furosemide", "20 mg", "Once every morning", "08:00", False, "Helps clear extra fluid while your heart recovers."),
        ("Atorvastatin", "20 mg", "Once at bedtime", "20:00", False, "Protects your arteries."),
    ],
    SurgeryType.tavi: [
        ("Aspirin", "100 mg", "Once every morning", "08:00", True, "Keeps blood flowing smoothly through your new valve."),
        ("Clopidogrel", "75 mg", "Once every morning", "08:00", True, "Works with aspirin to prevent clots in the early months."),
        ("Bisoprolol", "2.5 mg", "Once every morning", "08:00", False, "Steadies your heart rate."),
        ("Atorvastatin", "40 mg", "Once at bedtime", "20:00", False, "Lowers cholesterol to protect your heart."),
    ],
    SurgeryType.aortic: [
        ("Bisoprolol", "5 mg", "Once every morning", "08:00", False, "Keeps your heart rate and blood pressure gentle on the repair."),
        ("Ramipril", "2.5 mg", "Once every morning", "08:00", False, "Relaxes your blood vessels and lowers blood pressure."),
        ("Atorvastatin", "40 mg", "Once at bedtime", "20:00", False, "Protects your arteries."),
        ("Aspirin", "100 mg", "Once every morning", "08:00", True, "Helps prevent clots."),
    ],
    SurgeryType.combined: [
        ("Warfarin", "As per INR", "Once each evening", "18:00", True, "Prevents clots on your new valve and grafts — dose follows your INR test."),
        ("Metoprolol", "25 mg", "Twice daily", "08:00,20:00", False, "Slows and steadies your heart."),
        ("Atorvastatin", "40 mg", "Once at bedtime", "20:00", False, "Lowers cholesterol to protect your arteries."),
        ("Furosemide", "20 mg", "Once every morning", "08:00", False, "Clears extra fluid while you recover."),
    ],
}


def _surgery_label(user: User) -> str:
    return {
        SurgeryType.cabg: "Bypass (CABG)",
        SurgeryType.valve: "Valve",
        SurgeryType.tavi: "TAVI",
        SurgeryType.aortic: "Aortic",
        SurgeryType.combined: "Combined",
    }.get(user.surgery_type, "Cardiac")


def seed_appointments(db: Session, user: User) -> None:
    if db.query(Appointment).filter(Appointment.user_id == user.id).first():
        return
    # Anchor appointments to the patient's own surgery date (or ~3 weeks out if unknown),
    # so two patients with different dates see different calendars.
    surgery = user.surgery_date or (date.today() + timedelta(days=21))
    location = user.hospital.name if getattr(user, "hospital", None) else "Your hospital"
    # (title, subtitle, offset_days_from_surgery, time, type)
    items = [
        ("Pre-op Assessment", f"{_surgery_label(user)} surgery review", -14, "09:00", AppointmentType.followup),
        ("Blood Tests", "Pre-surgery labs", -10, "08:00", AppointmentType.review),
        ("Surgery Day", f"{_surgery_label(user)} procedure", 0, "07:00", AppointmentType.followup),
        ("Post-op Review", "First check-up after surgery", 14, "10:30", AppointmentType.review),
    ]
    for title, subtitle, offset, t, atype in items:
        d = surgery + timedelta(days=offset)
        db.add(Appointment(
            user_id=user.id, title=title, subtitle=subtitle, date=d.isoformat(), time=t,
            location=location, appointment_type=atype, is_confirmed=True,
        ))


def seed_medications(db: Session, user: User) -> None:
    if db.query(Medication).filter(Medication.user_id == user.id).first():
        return
    meds = _MED_TEMPLATES.get(user.surgery_type, _MED_TEMPLATES[SurgeryType.cabg])
    for name, dose, schedule, times, anti, purpose in meds:
        db.add(Medication(
            user_id=user.id, name=name, dose=dose, schedule=schedule, times=times,
            is_anticoagulant=anti, purpose_de=purpose, is_active=True,
        ))


def seed_eras(db: Session, user: User) -> None:
    if db.query(ErasProgress).filter(ErasProgress.user_id == user.id).first():
        return
    for item in ErasItem:
        db.add(ErasProgress(user_id=user.id, item_key=item, progress=0, target=100))


def seed_mobilisation(db: Session, user: User) -> None:
    if db.query(MobilisationMilestoneLog).filter(MobilisationMilestoneLog.user_id == user.id).first():
        return
    for m in (MobilisationMilestone.sitting, MobilisationMilestone.standing, MobilisationMilestone.first_walk):
        db.add(MobilisationMilestoneLog(user_id=user.id, milestone=m, achieved=False))


def setup_patient(db: Session, user: User) -> None:
    # Idempotent + race-safe: each seeder checks for existing rows, and unique
    # indexes (user+phase_key, user+date+title) hard-prevent duplicates if two
    # onboarding requests race. Swallow the loser's IntegrityError.
    try:
        seed_journey(db, user)
        seed_starter_tasks(db, user)
        seed_welcome_message(db, user)
        seed_appointments(db, user)
        seed_medications(db, user)
        seed_eras(db, user)
        seed_mobilisation(db, user)
        db.commit()
    except IntegrityError:
        db.rollback()
