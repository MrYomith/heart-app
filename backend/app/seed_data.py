"""Seed the database with rich demo data for two patients.

Run after migrating:  python -m app.seed_data
Additive & idempotent: creates the demo hospital and any missing demo users
(by email) without touching real accounts. Re-running only fills gaps.

Demo logins (email / password):
  ahmet@example.com  / demo1234   — CABG, inpatient recovery (Day 5)
  maria@example.com  / demo1234   — Valve replacement, post-discharge rehab
  nurse@example.com  / demo1234   — clinician (care-team dashboard)
"""
from datetime import date, datetime, timedelta, timezone

from app.core.security import hash_password
from app.database import SessionLocal
from app.enums import (
    AppointmentType,
    CessationType,
    ClinicianRole,
    ConsentType,
    MessageCategory,
    NyhaClass,
    PhaseKey,
    PhaseStatus,
    ScoreType,
    Severity,
    SurgeryType,
    TaskCategory,
    UserRole,
    VitalSource,
    VitalType,
)
from app.models import (
    ActivityLog,
    Appointment,
    CessationTracking,
    ClinicalScore,
    ConsentLog,
    Hospital,
    JourneyPhase,
    Medication,
    Message,
    MessageThread,
    RecoverySnapshot,
    Task,
    User,
    Vital,
)

now = lambda: datetime.now(timezone.utc)
today = date.today()
DEMO_PASSWORD = "demo1234"


def _get_or_create_hospital(db) -> Hospital:
    h = db.query(Hospital).filter(Hospital.name == "HerzZentrum Hamburg").first()
    if h:
        return h
    h = Hospital(
        name="HerzZentrum Hamburg",
        address="Martinistraße 52",
        city="Hamburg",
        postcode="20246",
        surgeon_message="You are in good hands. Our whole team is with you. — Dr. Müller",
    )
    db.add(h)
    db.flush()
    return h


def _vitals_series(user_id, kind: VitalType, days: int, fn, source=VitalSource.manual):
    """One reading per day for the last `days` days; fn(i)->value, i=0 is oldest."""
    rows = []
    for i in range(days):
        d = today - timedelta(days=(days - 1 - i))
        rows.append(Vital(
            user_id=user_id, type=kind, value=float(fn(i)),
            recorded_at=datetime(d.year, d.month, d.day, 8, 0, tzinfo=timezone.utc),
            source=source,
        ))
    return rows


def _seed_ahmet(db, hospital):
    """CABG patient, Day 5 inpatient — improving pain/mood, climbing recovery curve."""
    surgery = today - timedelta(days=5)
    user = User(
        name="Ahmet Yilmaz", email="ahmet@example.com",
        password_hash=hash_password(DEMO_PASSWORD),
        role=UserRole.patient, locale="de", onboarding_complete=True,
        surgery_type=SurgeryType.cabg, surgery_date=surgery,
        hospital_id=hospital.id, surgeon_name="Dr. Müller",
        nyha_class=NyhaClass.II, diagnosis="Coronary Artery Disease",
        current_phase=PhaseKey.inpatient, journey_progress=60.0,
        date_of_birth=date(1968, 3, 14),
    )
    db.add(user); db.flush()

    db.add(ConsentLog(
        user_id=user.id, consent_type=ConsentType.privacy, consent_version="v1.0",
        text_shown="Privacy Policy v1.0", accepted_at=now(), created_at=now(),
    ))

    db.add_all([
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.diagnosis, label="Diagnosis", emoji="🫀", status=PhaseStatus.completed, sort_order=0),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.preop, label="Pre-op Preparation", emoji="🛡️", status=PhaseStatus.completed, sort_order=1),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.surgery, label="Surgery Day", emoji="🏥", status=PhaseStatus.completed, date_label=surgery.strftime("%d %b %Y"), sort_order=2),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.inpatient, label="Inpatient Recovery", emoji="🩹", status=PhaseStatus.active, date_label="Days 1–7", subtitle="In progress", sort_order=3),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.rehab, label="Post-Discharge Rehab", emoji="🚶", status=PhaseStatus.upcoming, date_label="Week 2–8", sort_order=4),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.thriving, label="Thriving", emoji="⭐", status=PhaseStatus.upcoming, date_label="Week 9–12+", sort_order=5),
    ])

    tdy = today.isoformat()
    db.add_all([
        Task(user_id=user.id, title="Breathing Exercise", subtitle="Incentive spirometry – 10 breaths", icon="🫁", category=TaskCategory.breathing, scheduled_time="Morning", time_color="teal", is_done=True, priority=1, task_date=tdy),
        Task(user_id=user.id, title="Mobilisation", subtitle="Walk for 15–20 minutes", icon="🚶", category=TaskCategory.activity, scheduled_time="10:00", time_color="orange", is_done=False, priority=2, task_date=tdy),
        Task(user_id=user.id, title="Nutrition", subtitle="Protein-rich meal & 2 fruits", icon="🥗", category=TaskCategory.nutrition, scheduled_time="Lunch", time_color="teal", is_done=False, priority=3, task_date=tdy),
        Task(user_id=user.id, title="Hydration", subtitle="Drink 6–8 glasses of water", icon="💧", category=TaskCategory.hydration, scheduled_time="All day", time_color="teal", is_done=True, priority=4, task_date=tdy),
        Task(user_id=user.id, title="Medications", subtitle="2 scheduled medications", icon="💊", category=TaskCategory.medication, scheduled_time="14:00", time_color="teal", is_done=True, priority=5, task_date=tdy),
        Task(user_id=user.id, title="Wound Check", subtitle="Check dressing", icon="🩹", category=TaskCategory.wound, scheduled_time="20:00", time_color="teal", is_done=False, priority=6, task_date=tdy),
    ])

    db.add_all([
        Medication(user_id=user.id, name="Aspirin", dose="100 mg", schedule="1 tablet every morning", times="08:00", is_anticoagulant=True, purpose_de="Blutverdünnung"),
        Medication(user_id=user.id, name="Metoprolol", dose="25 mg", schedule="1 tablet twice daily", times="08:00,20:00", purpose_de="Senkt Herzfrequenz und Blutdruck"),
        Medication(user_id=user.id, name="Atorvastatin", dose="40 mg", schedule="1 tablet at bedtime", times="20:00", purpose_de="Senkt Cholesterin"),
        Medication(user_id=user.id, name="Ramipril", dose="5 mg", schedule="1 tablet every morning", times="08:00", purpose_de="Senkt den Blutdruck"),
    ])

    # Progress: 6 days of vitals trending the right way.
    db.add_all(_vitals_series(user.id, VitalType.pain_rest, 6, lambda i: max(1, 6 - i)))      # 6→1
    db.add_all(_vitals_series(user.id, VitalType.mood, 6, lambda i: min(5, 2 + i * 0.6)))      # rising
    db.add_all(_vitals_series(user.id, VitalType.bp_systolic, 6, lambda i: 138 - i * 2))
    db.add_all(_vitals_series(user.id, VitalType.bp_diastolic, 6, lambda i: 88 - i))
    db.add_all(_vitals_series(user.id, VitalType.heart_rate, 6, lambda i: 84 - i))
    db.add_all(_vitals_series(user.id, VitalType.weight, 6, lambda i: 82.0 - i * 0.2))
    db.add_all(_vitals_series(user.id, VitalType.steps, 6, lambda i: 300 + i * 220, source=VitalSource.wearable))

    # Recovery curve — slightly ahead of expected.
    for i in range(6):
        d = today - timedelta(days=5 - i)
        exp = 40 + i * 8
        act = exp + 4
        db.add(RecoverySnapshot(user_id=user.id, snapshot_date=d, actual_progress=float(act), expected_progress=float(exp), on_track_pct=float(min(100, round(act / exp * 100)))))

    db.add_all([
        ActivityLog(user_id=user.id, log_date=today - timedelta(days=i), steps=300 + (5 - i) * 220, active_minutes=10 + (5 - i) * 6, walk_duration_sec=600 + (5 - i) * 120)
        for i in range(6)
    ])
    db.add_all([
        CessationTracking(user_id=user.id, type=CessationType.smoking, start_date=surgery - timedelta(days=10), current_streak_days=15, goal="Stay smoke-free for life"),
        CessationTracking(user_id=user.id, type=CessationType.alcohol, start_date=surgery, current_streak_days=5, goal="No alcohol during recovery"),
    ])
    db.add_all([
        ClinicalScore(user_id=user.id, score_type=ScoreType.phq9, score=6, severity=Severity.mild, administered_at=now(), scheduled_week=1),
        ClinicalScore(user_id=user.id, score_type=ScoreType.gad7, score=4, severity=Severity.mild, administered_at=now(), scheduled_week=1),
    ])

    thread = MessageThread(patient_id=user.id, category=MessageCategory.care_team, subject="Wound review reminder", last_message_at=now())
    db.add(thread); db.flush()
    db.add(Message(thread_id=thread.id, sender_role="nurse", body="Hi Ahmet, reminder for your wound review on Friday at 10:30. Please bring your medication list.", is_read=False, sent_at=now()))

    db.add_all([
        Appointment(user_id=user.id, title="Follow-up with Surgeon", subtitle="Post-op Check", date=(today + timedelta(days=3)).isoformat(), time="10:30", location="HerzZentrum Hamburg", hospital_id=hospital.id, appointment_type=AppointmentType.followup),
        Appointment(user_id=user.id, title="Wound Review & Progress Check", date=(today + timedelta(days=14)).isoformat(), time="10:30", location="HerzZentrum Hamburg", hospital_id=hospital.id, appointment_type=AppointmentType.review),
    ])
    return user


def _seed_maria(db, hospital):
    """Valve patient, week 5 — home rehab, strong progress, ex-smoker."""
    surgery = today - timedelta(days=35)
    discharge = today - timedelta(days=28)
    user = User(
        name="Maria Schmidt", email="maria@example.com",
        password_hash=hash_password(DEMO_PASSWORD),
        role=UserRole.patient, locale="de", onboarding_complete=True,
        surgery_type=SurgeryType.valve, surgery_date=surgery, discharge_date=discharge,
        hospital_id=hospital.id, surgeon_name="Dr. Weber",
        nyha_class=NyhaClass.I, diagnosis="Aortic Valve Stenosis",
        current_phase=PhaseKey.rehab, journey_progress=78.0,
        date_of_birth=date(1959, 11, 2),
    )
    db.add(user); db.flush()

    db.add(ConsentLog(
        user_id=user.id, consent_type=ConsentType.privacy, consent_version="v1.0",
        text_shown="Privacy Policy v1.0", accepted_at=now(), created_at=now(),
    ))

    db.add_all([
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.diagnosis, label="Diagnosis", emoji="🫀", status=PhaseStatus.completed, sort_order=0),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.preop, label="Pre-op Preparation", emoji="🛡️", status=PhaseStatus.completed, sort_order=1),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.surgery, label="Surgery Day", emoji="🏥", status=PhaseStatus.completed, date_label=surgery.strftime("%d %b %Y"), sort_order=2),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.inpatient, label="Inpatient Recovery", emoji="🩹", status=PhaseStatus.completed, sort_order=3),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.rehab, label="Post-Discharge Rehab", emoji="🚶", status=PhaseStatus.active, date_label="Week 2–8", subtitle="In progress", sort_order=4),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.thriving, label="Thriving", emoji="⭐", status=PhaseStatus.upcoming, date_label="Week 9–12+", sort_order=5),
    ])

    tdy = today.isoformat()
    db.add_all([
        Task(user_id=user.id, title="Cardiac Rehab Session", subtitle="Supervised exercise – 45 min", icon="🏃", category=TaskCategory.activity, scheduled_time="09:00", time_color="orange", is_done=True, priority=1, task_date=tdy),
        Task(user_id=user.id, title="Daily Walk", subtitle="30 minutes brisk walk", icon="🚶", category=TaskCategory.activity, scheduled_time="Afternoon", time_color="teal", is_done=False, priority=2, task_date=tdy),
        Task(user_id=user.id, title="Medications", subtitle="Anticoagulant + 2 others", icon="💊", category=TaskCategory.medication, scheduled_time="08:00", time_color="teal", is_done=True, priority=3, task_date=tdy),
        Task(user_id=user.id, title="Mood Check-in", subtitle="How are you feeling today?", icon="💚", category=TaskCategory.emotional, scheduled_time="Evening", time_color="teal", is_done=False, priority=4, task_date=tdy),
    ])

    db.add_all([
        Medication(user_id=user.id, name="Warfarin", dose="5 mg", schedule="1 tablet daily (INR-adjusted)", times="18:00", is_anticoagulant=True, purpose_de="Blutverdünnung nach Klappenersatz"),
        Medication(user_id=user.id, name="Bisoprolol", dose="2.5 mg", schedule="1 tablet every morning", times="08:00", purpose_de="Senkt Herzfrequenz"),
        Medication(user_id=user.id, name="Furosemide", dose="20 mg", schedule="1 tablet every morning", times="08:00", purpose_de="Entwässerung"),
    ])

    db.add_all(_vitals_series(user.id, VitalType.pain_rest, 7, lambda i: max(0, 2 - i * 0.3)))
    db.add_all(_vitals_series(user.id, VitalType.mood, 7, lambda i: min(5, 4 + i * 0.1)))
    db.add_all(_vitals_series(user.id, VitalType.bp_systolic, 7, lambda i: 128 - i))
    db.add_all(_vitals_series(user.id, VitalType.bp_diastolic, 7, lambda i: 82 - i * 0.5))
    db.add_all(_vitals_series(user.id, VitalType.heart_rate, 7, lambda i: 72 - i * 0.3))
    db.add_all(_vitals_series(user.id, VitalType.weight, 7, lambda i: 68.0 - i * 0.1))
    db.add_all(_vitals_series(user.id, VitalType.steps, 7, lambda i: 3500 + i * 400, source=VitalSource.wearable))

    for i in range(7):
        d = today - timedelta(days=6 - i)
        exp = 60 + i * 3
        act = exp + 6
        db.add(RecoverySnapshot(user_id=user.id, snapshot_date=d, actual_progress=float(min(100, act)), expected_progress=float(exp), on_track_pct=float(min(100, round(act / exp * 100)))))

    db.add_all([
        ActivityLog(user_id=user.id, log_date=today - timedelta(days=i), steps=3500 + (6 - i) * 400, active_minutes=25 + (6 - i) * 4, walk_duration_sec=1500 + (6 - i) * 120)
        for i in range(7)
    ])
    db.add_all([
        CessationTracking(user_id=user.id, type=CessationType.smoking, start_date=surgery - timedelta(days=40), current_streak_days=75, goal="Smoke-free forever"),
        CessationTracking(user_id=user.id, type=CessationType.alcohol, start_date=surgery, current_streak_days=35, goal="Stay alcohol-free"),
    ])
    db.add_all([
        ClinicalScore(user_id=user.id, score_type=ScoreType.phq9, score=3, severity=Severity.minimal, administered_at=now(), scheduled_week=4),
        ClinicalScore(user_id=user.id, score_type=ScoreType.gad7, score=2, severity=Severity.minimal, administered_at=now(), scheduled_week=4),
    ])

    thread = MessageThread(patient_id=user.id, category=MessageCategory.care_team, subject="Rehab progress", last_message_at=now())
    db.add(thread); db.flush()
    db.add(Message(thread_id=thread.id, sender_role="physio", body="Great work this week, Maria! Your walking distance is up 20%. Keep it going. 💪", is_read=True, sent_at=now()))

    db.add_all([
        Appointment(user_id=user.id, title="Cardiac Rehab Session", date=(today + timedelta(days=2)).isoformat(), time="09:00", location="Reha-Zentrum Hamburg", hospital_id=hospital.id, appointment_type=AppointmentType.rehab),
        Appointment(user_id=user.id, title="INR Blood Test", subtitle="Warfarin monitoring", date=(today + timedelta(days=5)).isoformat(), time="08:30", location="HerzZentrum Hamburg", hospital_id=hospital.id, appointment_type=AppointmentType.review),
        Appointment(user_id=user.id, title="6-week Surgeon Review", date=(today + timedelta(days=7)).isoformat(), time="11:00", location="HerzZentrum Hamburg", hospital_id=hospital.id, appointment_type=AppointmentType.followup),
    ])
    return user


def _enrich_existing(db, user):
    """Fill gaps for a demo patient created by an older seed: set a login
    password and add a progress series if none exists yet."""
    touched = False
    if not user.password_hash:
        user.password_hash = hash_password(DEMO_PASSWORD)
        touched = True
    if db.query(RecoverySnapshot).filter(RecoverySnapshot.user_id == user.id).count() == 0:
        base = user.surgery_date or today
        db.add_all(_vitals_series(user.id, VitalType.pain_rest, 6, lambda i: max(1, 6 - i)))
        db.add_all(_vitals_series(user.id, VitalType.mood, 6, lambda i: min(5, 2 + i * 0.6)))
        db.add_all(_vitals_series(user.id, VitalType.bp_systolic, 6, lambda i: 138 - i * 2))
        db.add_all(_vitals_series(user.id, VitalType.bp_diastolic, 6, lambda i: 88 - i))
        db.add_all(_vitals_series(user.id, VitalType.heart_rate, 6, lambda i: 84 - i))
        db.add_all(_vitals_series(user.id, VitalType.weight, 6, lambda i: 82.0 - i * 0.2))
        db.add_all(_vitals_series(user.id, VitalType.steps, 6, lambda i: 300 + i * 220, source=VitalSource.wearable))
        for i in range(6):
            d = today - timedelta(days=5 - i)
            exp = 40 + i * 8
            db.add(RecoverySnapshot(user_id=user.id, snapshot_date=d, actual_progress=float(exp + 4), expected_progress=float(exp), on_track_pct=float(min(100, round((exp + 4) / exp * 100)))))
        db.add_all([
            ActivityLog(user_id=user.id, log_date=today - timedelta(days=i), steps=300 + (5 - i) * 220, active_minutes=10 + (5 - i) * 6, walk_duration_sec=600 + (5 - i) * 120)
            for i in range(6)
        ])
        if db.query(CessationTracking).filter(CessationTracking.user_id == user.id).count() == 0:
            db.add_all([
                CessationTracking(user_id=user.id, type=CessationType.smoking, start_date=base - timedelta(days=10), current_streak_days=15, goal="Stay smoke-free for life"),
                CessationTracking(user_id=user.id, type=CessationType.alcohol, start_date=base, current_streak_days=5, goal="No alcohol during recovery"),
            ])
        db.add_all([
            ClinicalScore(user_id=user.id, score_type=ScoreType.phq9, score=6, severity=Severity.mild, administered_at=now(), scheduled_week=1),
            ClinicalScore(user_id=user.id, score_type=ScoreType.gad7, score=4, severity=Severity.mild, administered_at=now(), scheduled_week=1),
        ])
        touched = True
    return touched


def _seed_clinician(db, hospital):
    db.add(User(
        name="Nurse Petra Klein", email="nurse@example.com",
        password_hash=hash_password(DEMO_PASSWORD),
        role=UserRole.clinician, clinician_specialty=ClinicianRole.nurse,
        locale="de", onboarding_complete=True, hospital_id=hospital.id,
    ))


def _seed_omar(db, hospital):
    """Pre-surgery patient still in the Diagnosis stage — covers the early journey."""
    surgery = today + timedelta(days=21)
    user = User(
        name="Omar Haddad", email="omar@example.com",
        password_hash=hash_password(DEMO_PASSWORD),
        role=UserRole.patient, locale="de", onboarding_complete=True,
        surgery_type=SurgeryType.valve, surgery_date=surgery,
        hospital_id=hospital.id, surgeon_name="Dr. Weber",
        nyha_class=NyhaClass.II, diagnosis="Aortic Valve Stenosis",
        current_phase=PhaseKey.diagnosis, journey_progress=8.0,
        date_of_birth=date(1972, 7, 9),
    )
    db.add(user); db.flush()
    db.add(ConsentLog(user_id=user.id, consent_type=ConsentType.privacy, consent_version="v1.0",
                      text_shown="Privacy Policy v1.0", accepted_at=now(), created_at=now()))
    db.add_all([
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.diagnosis, label="Diagnosis", emoji="🫀", status=PhaseStatus.active, subtitle="In progress", sort_order=0),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.preop, label="Pre-op Preparation", emoji="🛡️", status=PhaseStatus.upcoming, sort_order=1),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.surgery, label="Surgery Day", emoji="🏥", status=PhaseStatus.upcoming, date_label=surgery.strftime("%d %b %Y"), sort_order=2),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.inpatient, label="Inpatient Recovery", emoji="🩹", status=PhaseStatus.upcoming, sort_order=3),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.rehab, label="Post-Discharge Rehab", emoji="🚶", status=PhaseStatus.upcoming, sort_order=4),
        JourneyPhase(user_id=user.id, phase_key=PhaseKey.thriving, label="Thriving", emoji="⭐", status=PhaseStatus.upcoming, sort_order=5),
    ])
    db.add_all([
        Medication(user_id=user.id, name="Bisoprolol", dose="2.5 mg", schedule="1 tablet every morning", times="08:00", purpose_de="Senkt Herzfrequenz"),
        Medication(user_id=user.id, name="Aspirin", dose="100 mg", schedule="1 tablet every morning", times="08:00", is_anticoagulant=True, purpose_de="Blutverdünnung"),
    ])
    db.add_all(_vitals_series(user.id, VitalType.mood, 5, lambda i: min(5, 3 + i * 0.3)))
    db.add_all(_vitals_series(user.id, VitalType.bp_systolic, 5, lambda i: 142 - i))
    db.add_all([CessationTracking(user_id=user.id, type=CessationType.smoking, start_date=today - timedelta(days=4), current_streak_days=4, goal="Quit before surgery")])
    thread = MessageThread(patient_id=user.id, category=MessageCategory.care_team, subject="Welcome to MioHeart", last_message_at=now())
    db.add(thread); db.flush()
    db.add(Message(thread_id=thread.id, sender_role="nurse", body="Welcome Omar. We'll guide you through every step before your valve surgery. Ask us anything.", is_read=False, sent_at=now()))
    db.add(Appointment(user_id=user.id, title="Pre-operative Assessment", date=(today + timedelta(days=10)).isoformat(), time="09:00", location="HerzZentrum Hamburg", hospital_id=hospital.id, appointment_type=AppointmentType.followup))
    return user


def _seed_admin(db, hospital):
    db.add(User(
        name="Platform Admin", email="admin@example.com",
        password_hash=hash_password(DEMO_PASSWORD),
        role=UserRole.admin, locale="en", onboarding_complete=True, hospital_id=hospital.id,
    ))


def seed():
    db = SessionLocal()
    created = []
    try:
        hospital = _get_or_create_hospital(db)
        existing = {e for (e,) in db.query(User.email).all()}
        if "admin@example.com" not in existing:
            _seed_admin(db, hospital); created.append("admin@example.com (admin)")
        if "omar@example.com" not in existing:
            _seed_omar(db, hospital); created.append("omar@example.com")
        if "ahmet@example.com" not in existing:
            _seed_ahmet(db, hospital); created.append("ahmet@example.com")
        else:
            ahmet = db.query(User).filter(User.email == "ahmet@example.com").first()
            if _enrich_existing(db, ahmet):
                created.append("ahmet@example.com (enriched)")
        if "maria@example.com" not in existing:
            _seed_maria(db, hospital); created.append("maria@example.com")
        if "nurse@example.com" not in existing:
            _seed_clinician(db, hospital); created.append("nurse@example.com")
        db.commit()
        if created:
            print(f"Seeded demo accounts: {', '.join(created)} (password: {DEMO_PASSWORD})")
        else:
            print("Demo accounts already present. Nothing to add.")
    except Exception as e:
        db.rollback()
        print(f"Seeding failed: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed()
