"""Seed REAL shared content that the admin CMS manages and every patient reads.

Populates two connected tables (both admin-editable, both patient-readable):
  • app_content        — symptoms, phase resources, fasting steps, surgery
                         reminders, emergency contacts, support resources
                         (rendered in the patient phase screens via /api/content)
  • education_content  — the Education Hub library (/api/education)

Content is drawn from the MioHeart product spec (ERAS protocol, German cardiac
pathway). Idempotent: each item is keyed and skipped if already present, so it
is safe to re-run and safe alongside admin edits.

Run:  python -m app.seed_content
"""
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.enums import ContentTopic, ContentType
from app.models import AppContent, EducationContent

V, G, A = ContentType.video, ContentType.guide, ContentType.audio
UH, BS, SS, RC, LW = (
    ContentTopic.understanding_heart, ContentTopic.before_surgery,
    ContentTopic.surgery_stay, ContentTopic.recovery, ContentTopic.living_well,
)

# ── app_content: (category, item_key, title, body, emoji, severity, stage, section, payload, sort) ──
APP_CONTENT: list[dict] = []


def _ac(category, item_key, title, body=None, emoji=None, severity=None, stage=None, section=None, payload=None, sort=0):
    APP_CONTENT.append(dict(category=category, item_key=item_key, title=title, body=body,
                            emoji=emoji, severity=severity, stage=stage, section=section,
                            payload=payload, sort_order=sort))


# Red-flag symptoms (Messages → symptom escalation; severity drives the alert)
_ac("symptom", "chest_pain", "Chest pain or pressure", "New or severe chest pain, tightness or pressure — especially with sweating or breathlessness. Call emergency services (112) immediately.", "❗", "critical", sort=0)
_ac("symptom", "breathlessness", "Sudden breathlessness", "Shortness of breath at rest or that is getting worse. Contact your care team urgently; call 112 if severe.", "🫁", "critical", sort=1)
_ac("symptom", "wound_oozing", "Wound discharge or opening", "Your sternotomy wound is leaking fluid/pus, opening, or the edges are separating. Contact your care team today.", "🩹", "critical", sort=2)
_ac("symptom", "fever", "Fever ≥ 38°C", "A temperature of 38°C or higher can be a sign of infection. Record it and contact your care team.", "🌡️", "warning", sort=3)
_ac("symptom", "wound_redness", "Increasing wound redness", "Spreading redness, warmth or swelling around the wound. Take a photo and report it to your care team.", "🔴", "warning", sort=4)
_ac("symptom", "palpitations", "Palpitations", "A racing, pounding or irregular heartbeat that won't settle. Note when it happens and tell your care team.", "💓", "warning", sort=5)
_ac("symptom", "increased_pain", "Increasing pain", "Pain that is getting worse rather than better, or not controlled by your medication. Let your care team know.", "😣", "warning", sort=6)
_ac("symptom", "swollen_legs", "Swollen legs or ankles", "New or worsening swelling, or sudden weight gain, can signal fluid retention. Report it to your care team.", "🦵", "warning", sort=7)

# Fasting & carbohydrate loading (Surgery Day) — payload carries the ERAS offset
_ac("fasting_step", "solids_stop", "Stop eating solid food", "No solid food from 8 hours before your surgery time (ERAS protocol).", "🍽️", stage="surgery", payload={"offset_hours": -8}, sort=0)
_ac("fasting_step", "cho_drink", "Carbohydrate drink", "Drink your 400 ml carbohydrate drink as instructed — it reduces stress and supports recovery.", "🥤", stage="surgery", payload={"offset_hours": -2, "volume_ml": 400}, sort=1)
_ac("fasting_step", "fluids_stop", "Stop clear fluids", "Stop all clear fluids 2 hours before your surgery time.", "💧", stage="surgery", payload={"offset_hours": -2}, sort=2)

# Surgery-day reminders (checklist)
_ac("surgery_reminder", "meds", "Take your allowed medications", "Take the medications your team approved with a small sip of water.", "💊", stage="surgery", sort=0)
_ac("surgery_reminder", "antiseptic", "Shower with antiseptic soap", "Shower with the antiseptic soap provided the night before and the morning of surgery.", "🚿", stage="surgery", sort=1)
_ac("surgery_reminder", "clothes", "Wear comfortable clothes", "Loose, comfortable clothing makes dressing easier after surgery.", "👕", stage="surgery", sort=2)
_ac("surgery_reminder", "documents", "Bring ID & insurance", "Bring your ID, insurance card and any documents your hospital requested.", "🪪", stage="surgery", sort=3)
_ac("surgery_reminder", "jewellery", "Remove jewellery & piercings", "Leave jewellery, piercings and valuables at home.", "💍", stage="surgery", sort=4)
_ac("surgery_reminder", "no_varnish", "No nail varnish or make-up", "Remove nail varnish and make-up so monitoring equipment reads correctly.", "💅", stage="surgery", sort=5)

# Phase educational resources (readable in-app; one section per stage)
def _res(stage, key, title, body, emoji, sort):
    _ac("phase_resource", f"{stage}_{key}", title, body, emoji, stage=stage, section="education", sort=sort)

_res("diagnosis", "condition", "Understanding your condition", "Your heart condition and the recommended surgery, explained in plain language. Knowing what lies ahead helps turn worry into confidence.", "🫀", 0)
_res("diagnosis", "openheart", "What is open-heart surgery?", "An overview of what happens during cardiac surgery, why it's needed and what the team does to keep you safe.", "🎬", 1)
_res("diagnosis", "anxiety", "Managing anxiety before surgery", "It's normal to feel scared. Breathing exercises, talking to your team and good information all reduce anxiety.", "💚", 2)
_res("preop", "eras", "Your ERAS preparation explained", "Enhanced Recovery After Surgery: small daily steps — breathing, walking, nutrition, not smoking — that measurably speed recovery.", "✅", 0)
_res("preop", "prehab", "Why prehab matters", "Getting fitter before surgery (\"prehabilitation\") improves your strength and lowers complications.", "🏋️", 1)
_res("preop", "pack", "What to bring to hospital", "Comfortable clothes, toiletries, your medication list, ID and insurance, phone charger, and slip-on shoes.", "🧳", 2)
_res("surgery", "day", "What happens on surgery day", "From check-in to the anaesthetic room, theatre, and ICU recovery — a step-by-step of your day.", "🏥", 0)
_res("surgery", "icu", "Tubes, lines & drains explained", "The tubes and monitors you'll wake up with are normal and temporary. Here's what each one does.", "🔌", 1)
_res("inpatient", "breathing", "Breathing exercises after surgery", "Using your incentive spirometer hourly keeps your lungs clear and prevents chest infections.", "🫁", 0)
_res("inpatient", "mobilise", "Why early mobilisation matters", "Sitting up and walking soon after surgery reduces clots, improves breathing and speeds recovery.", "🚶", 1)
_res("inpatient", "wound", "Caring for your sternotomy wound", "Keep the dressing dry and intact. Do not remove it before day 3. Report redness, discharge or opening.", "🩹", 2)
_res("inpatient", "delirium", "Understanding post-op confusion", "Short-lived confusion after heart surgery is common and usually passes. Tell your nurse if it happens.", "🧠", 3)
_res("rehab", "sternal", "Sternal precautions (heart hug)", "For 6–12 weeks: no pushing/pulling/lifting over ~2 kg, hug a pillow when coughing, and don't drive until cleared.", "🛡️", 0)
_res("rehab", "ahb", "Cardiac rehab (AHB) explained", "The Anschlussheilbehandlung is your structured rehab programme. It builds strength safely with supervised exercise and education.", "🏥", 1)
_res("rehab", "driving", "When can I drive again?", "Most people resume driving 4–6 weeks after surgery, once cleared by their team and able to perform an emergency stop comfortably.", "🚗", 2)
_res("rehab", "intimacy", "Resuming intimacy", "Most patients can resume sexual activity at 4–6 weeks, when they can climb two flights of stairs without symptoms.", "❤️", 3)
_res("rehab", "work", "Returning to work", "Desk work: ~4–6 weeks. Light physical: 6–8 weeks. Heavy physical: 3–6 months. Plan a graduated return.", "💼", 4)
_res("thriving", "diet", "Heart-healthy Mediterranean eating", "Vegetables, whole grains, fish, olive oil and nuts; limit salt, sugar and processed food. Small consistent changes last.", "🥗", 0)
_res("thriving", "activity", "150 minutes a week", "Aim for the WHO target of 150 minutes of moderate activity weekly — walking counts. Build up gradually.", "🏃", 1)
_res("thriving", "meds", "Long-term medication adherence", "Taking your medications consistently protects your heart. Use reminders and never stop without advice.", "💊", 2)
_res("thriving", "mind", "Looking after your mental health", "Mood dips are common after surgery. Mindfulness, connection and professional support all help.", "🧘", 3)

# Emergency contacts
_ac("emergency_contact", "emergency", "Emergency services", "Call 112 for chest pain, severe breathlessness or collapse.", "🚑", payload={"phone": "112"}, sort=0)
_ac("emergency_contact", "care_team", "Your care team", "Message your care team in the app for non-urgent questions.", "🩺", payload={"route": "messages"}, sort=1)
_ac("emergency_contact", "quitline", "Smoking quitline (Telefonberatung)", "Free German quitline support to stay smoke-free.", "🚭", payload={"phone": "0800 8 313131"}, sort=2)
_ac("emergency_contact", "crisis", "Crisis & emotional support", "If you're struggling emotionally, talk to someone now.", "💬", payload={"phone": "0800 111 0 111"}, sort=3)

# Support resources
_ac("support_resource", "cessation", "Stop smoking support", "Cessation coaching, craving tools and a smoke-free day counter.", "🚭", sort=0)
_ac("support_resource", "psych", "Psychological support (Psychokardiologie)", "Referral pathway for depression/anxiety screening and cardiac psychology.", "🧠", payload={"route": "screening"}, sort=1)
_ac("support_resource", "community", "Patient community", "Real recovery stories, a moderated forum and \"heart buddy\" peer matching.", "👥", sort=2)
_ac("support_resource", "carer", "Carer & family support", "Guidance and education for the people supporting your recovery.", "👨‍👩‍👧", sort=3)


# ── education_content: (title, type, topic, stage, duration_min, category, sort) ──
EDU: list[tuple] = [
    ("How your heart works", V, UH, "diagnosis", 4, "Heart basics", 0),
    ("Coronary artery disease explained", V, UH, "diagnosis", 5, "Your condition", 1),
    ("Heart valve conditions explained", V, UH, "diagnosis", 4, "Your condition", 2),
    ("Managing anxiety before surgery", A, UH, "diagnosis", 8, "Wellbeing", 3),
    ("How to do breathing exercises correctly", V, BS, "preop", 3, "Prehab", 0),
    ("Preparing your body and mind for surgery", V, BS, "preop", 5, "Prehab", 1),
    ("Carbohydrate loading explained", G, BS, "preop", None, "Nutrition", 2),
    ("What happens on surgery day", V, BS, "preop", 6, "Surgery day", 3),
    ("Your theatre journey, step by step", V, SS, "surgery", 4, "Surgery & stay", 0),
    ("Tubes, lines and drains explained", V, SS, "inpatient", 4, "ICU", 1),
    ("Pain management after surgery", V, SS, "inpatient", 5, "ICU", 2),
    ("What's normal after heart surgery", G, SS, "inpatient", None, "ICU", 3),
    ("Walking after surgery: a step-by-step guide", V, RC, "inpatient", 4, "Mobilisation", 0),
    ("Caring for your wound at home", V, RC, "rehab", 5, "Wound care", 1),
    ("Sternal precautions: the heart-hug technique", V, RC, "rehab", 3, "Safe movement", 2),
    ("Sleep better, recover faster", A, RC, "rehab", 10, "Wellbeing", 3),
    ("Your medications: why and when", G, RC, "rehab", None, "Medications", 4),
    ("Red flags: when to call your team", G, RC, "rehab", None, "Safety", 5),
    ("Heart-healthy eating made simple", V, LW, "thriving", 5, "Nutrition", 0),
    ("Staying active for life", V, LW, "thriving", 4, "Fitness", 1),
    ("Returning to work after heart surgery", G, LW, "thriving", None, "Work", 2),
    ("Looking after your mental health", A, LW, "thriving", 9, "Wellbeing", 3),
]


def seed():
    db: Session = SessionLocal()
    added_ac = added_edu = 0
    try:
        # app_content — keyed by (category, item_key), global (hospital_id null)
        existing_ac = {(c.category, c.item_key) for c in db.query(AppContent.category, AppContent.item_key).all()}
        for it in APP_CONTENT:
            if (it["category"], it["item_key"]) in existing_ac:
                continue
            db.add(AppContent(locale="en", published=True, hospital_id=None, **it))
            added_ac += 1

        # education_content — keyed by title
        existing_edu = {t for (t,) in db.query(EducationContent.title).all()}
        for title, ctype, topic, stage, mins, cat, sort in EDU:
            if title in existing_edu:
                continue
            db.add(EducationContent(
                title=title, type=ctype, topic=topic, stage=stage,
                duration_sec=(mins * 60 if mins else None), category=cat,
                surgery_types=None, has_german_subtitles=True, sort_order=sort, published=True,
            ))
            added_edu += 1

        db.commit()
        print(f"Seeded content: +{added_ac} app_content items, +{added_edu} education items.")
    except Exception as e:
        db.rollback()
        print(f"Content seeding failed: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed()
