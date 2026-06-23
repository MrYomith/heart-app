"""
Run this script once to populate the database with demo data for patient Ahmet.
Usage: python -m app.seed_data
"""
from app.database import SessionLocal, engine, Base
from app.models.user import User
from app.models.task import Task
from app.models.journey import JourneyPhase
from app.models.medication import Medication
from app.models.message import Message
from app.models.appointment import Appointment

# Ensure tables exist
Base.metadata.create_all(bind=engine)


def seed():
    db = SessionLocal()
    try:
        # Skip if already seeded
        if db.query(User).count() > 0:
            print("Database already seeded. Skipping.")
            return

        # --- User ---
        user = User(
            name="Ahmet",
            email="ahmet@example.com",
            surgery_date="2024-05-28",
            current_phase="inpatient",
            journey_progress=60.0,
            hospital="HerzZentrum Hamburg",
            surgeon="Dr. Müller",
            diagnosis="Coronary Artery Disease",
        )
        db.add(user)
        db.flush()

        # --- Journey phases ---
        phases = [
            JourneyPhase(user_id=user.id, phase_key="diagnosis", label="Diagnosis", emoji="🫀", status="completed", order=0),
            JourneyPhase(user_id=user.id, phase_key="preop", label="Pre-op Preparation", emoji="🛡️", status="completed", order=1),
            JourneyPhase(user_id=user.id, phase_key="surgery", label="Surgery Day", emoji="🏥", status="completed", date_label="28 May 2024", order=2),
            JourneyPhase(user_id=user.id, phase_key="inpatient", label="Inpatient Recovery", emoji="🩹", status="active", date_label="Days 1–7", subtitle="In progress", order=3),
            JourneyPhase(user_id=user.id, phase_key="rehab", label="Post-Discharge Rehab", emoji="🚶", status="upcoming", date_label="Week 2–8", order=4),
            JourneyPhase(user_id=user.id, phase_key="thriving", label="Thriving", emoji="⭐", status="upcoming", date_label="Week 9–12+", order=5),
        ]
        db.add_all(phases)

        # --- Today's tasks ---
        tasks = [
            Task(user_id=user.id, title="Breathing Exercise", subtitle="Incentive spirometry – 10 breaths", icon="🫁", category="breathing", scheduled_time="Morning", time_color="teal", is_done=True, priority=1, task_date="2024-05-31"),
            Task(user_id=user.id, title="Mobilisation", subtitle="Walk for 15–20 minutes", icon="🚶", category="activity", scheduled_time="10:00", time_color="orange", is_done=False, priority=2, task_date="2024-05-31"),
            Task(user_id=user.id, title="Nutrition", subtitle="Eat a protein-rich meal & 2 fruits", icon="🥗", category="nutrition", scheduled_time="Lunch", time_color="teal", is_done=False, priority=3, task_date="2024-05-31"),
            Task(user_id=user.id, title="Hydration", subtitle="Drink 6–8 glasses of water", icon="💧", category="hydration", scheduled_time="Throughout day", time_color="teal", is_done=True, priority=4, task_date="2024-05-31"),
            Task(user_id=user.id, title="Medications", subtitle="2 scheduled medications", icon="💊", category="medication", scheduled_time="14:00", time_color="teal", is_done=True, priority=5, task_date="2024-05-31"),
            Task(user_id=user.id, title="Sleep Plan", subtitle="Aim for 7–8 hours of sleep", icon="🌙", category="sleep", scheduled_time="Tonight", time_color="teal", is_done=False, priority=6, task_date="2024-05-31"),
            Task(user_id=user.id, title="Emotional Check-in", subtitle="How are you feeling today?", icon="❤️", category="emotional", scheduled_time="Evening", time_color="orange", is_done=False, priority=7, task_date="2024-05-31"),
            Task(user_id=user.id, title="Learn", subtitle="Watch today's short video", icon="📖", category="education", scheduled_time="Evening", time_color="teal", is_done=False, priority=8, task_date="2024-05-31"),
            Task(user_id=user.id, title="Wound Check Reminder", subtitle="Check dressing (do not open before Day 3)", icon="🩹", category="wound", scheduled_time="20:00", time_color="teal", is_done=False, priority=9, task_date="2024-05-31"),
            Task(user_id=user.id, title="Appointment", subtitle="Cardiology follow-up", icon="📅", category="appointment", scheduled_time="Tomorrow 09:30", time_color="orange", is_done=False, priority=10, task_date="2024-05-31"),
        ]
        db.add_all(tasks)

        # --- Medications ---
        meds = [
            Medication(user_id=user.id, name="Aspirin", dose="100 mg", schedule="1 tablet every morning", times="08:00"),
            Medication(user_id=user.id, name="Metoprolol", dose="25 mg", schedule="1 tablet twice daily", times="08:00,20:00"),
            Medication(user_id=user.id, name="Atorvastatin", dose="40 mg", schedule="1 tablet at bedtime", times="20:00"),
            Medication(user_id=user.id, name="Ramipril", dose="5 mg", schedule="1 tablet every morning", times="08:00"),
        ]
        db.add_all(meds)

        # --- Messages ---
        msgs = [
            Message(user_id=user.id, sender="Dr. Anna Müller", sender_avatar="👩‍⚕️", subject="Wound review reminder",
                    preview="Hi Ahmet, this is a reminder for your wound...",
                    body="Hi Ahmet,\n\nThis is a reminder for your wound review appointment.\n\nFriday, 31 May 2024 – 10:30 AM\nHerzZentrum Hamburg\nMartinistraße 52, 20246 Hamburg\n\nPlease bring your medication list and report any new symptoms.\n\nWe look forward to seeing you.\n\n– Your Care Team",
                    category="care_team", is_read=False, sent_at="10:30 AM"),
            Message(user_id=user.id, sender="Physiotherapist Team", sender_avatar="🏃", subject="Great progress this week!",
                    preview="Your walking distance has improved...",
                    body="Hi Ahmet, your walking distance has improved significantly this week. Keep it up!",
                    category="physiotherapy", is_read=False, sent_at="Yesterday"),
            Message(user_id=user.id, sender="Care Team", sender_avatar="🛡️", subject="Medication update",
                    preview="Please continue taking your medications...",
                    body="Please continue taking your medications as prescribed.", category="care_team", is_read=True, sent_at="2 days ago"),
            Message(user_id=user.id, sender="MioHart Support", sender_avatar="❤️", subject="You're doing great!",
                    preview="Small steps every day lead to big changes...",
                    body="Small steps every day lead to big changes. We're so proud of you, Ahmet!", category="emotional_support", is_read=True, sent_at="3 days ago"),
        ]
        db.add_all(msgs)

        # --- Appointments ---
        appointments = [
            Appointment(user_id=user.id, title="Follow-up with Surgeon", subtitle="Post-op Check", date="07 Jun 2024", time="10:30 AM", location="HerzZentrum Hamburg", appointment_type="followup"),
            Appointment(user_id=user.id, title="Follow-up with Cardiologist", date="14 Jun 2024", time="11:00 AM", location="HerzZentrum Hamburg", appointment_type="followup"),
            Appointment(user_id=user.id, title="Wound Review & Progress Check", date="21 Jun 2024", time="10:30 AM", location="HerzZentrum Hamburg", appointment_type="review"),
            Appointment(user_id=user.id, title="Post-discharge Review", date="05 Jul 2024", time="10:30 AM", location="HerzZentrum Hamburg", appointment_type="review"),
        ]
        db.add_all(appointments)

        db.commit()
        print("Database seeded successfully with demo patient Ahmet.")

    except Exception as e:
        db.rollback()
        print(f"Seeding failed: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed()
