"""Shared enumerations used across the MioHeart data model.

Stored as native PostgreSQL ENUM types on Neon; fall back to VARCHAR on SQLite.
"""
import enum


class UserRole(str, enum.Enum):
    patient = "patient"
    carer = "carer"
    clinician = "clinician"
    admin = "admin"


class ClinicianRole(str, enum.Enum):
    surgeon = "surgeon"
    nurse = "nurse"
    physio = "physio"
    psychokardiologist = "psychokardiologist"
    admin = "admin"


class SurgeryType(str, enum.Enum):
    cabg = "cabg"
    valve = "valve"
    tavi = "tavi"
    aortic = "aortic"
    combined = "combined"
    none = "none"


class NyhaClass(str, enum.Enum):
    I = "I"
    II = "II"
    III = "III"
    IV = "IV"


class PhaseKey(str, enum.Enum):
    diagnosis = "diagnosis"
    preop = "preop"
    surgery = "surgery"
    inpatient = "inpatient"
    rehab = "rehab"
    thriving = "thriving"


class PhaseStatus(str, enum.Enum):
    completed = "completed"
    active = "active"
    upcoming = "upcoming"


class ActivatedBy(str, enum.Enum):
    auto = "auto"
    clinician = "clinician"


class TransitionTrigger(str, enum.Enum):
    auto_date = "auto_date"
    clinician = "clinician"


class HospitalType(str, enum.Enum):
    hospital = "hospital"
    rehab_centre = "rehab_centre"


class Platform(str, enum.Enum):
    ios = "ios"
    android = "android"


class ConsentType(str, enum.Enum):
    terms = "terms"
    privacy = "privacy"
    data_sharing = "data_sharing"
    carer_visibility = "carer_visibility"


class CarerLinkStatus(str, enum.Enum):
    pending = "pending"
    active = "active"
    revoked = "revoked"


class DataRequestType(str, enum.Enum):
    export = "export"
    deletion = "deletion"


class DataRequestStatus(str, enum.Enum):
    requested = "requested"
    processing = "processing"
    complete = "complete"


class ConditionSource(str, enum.Enum):
    onboarding = "onboarding"
    clinician = "clinician"


class EnrollmentStatus(str, enum.Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"


class EnrollmentInitiatedBy(str, enum.Enum):
    patient = "patient"
    code = "code"
    hospital = "hospital"


class MedicationLogStatus(str, enum.Enum):
    taken = "taken"
    missed = "missed"
    skipped = "skipped"


class GoalType(str, enum.Enum):
    activity = "activity"
    recovery = "recovery"
    return_to_work = "return_to_work"
    custom = "custom"


class TaskCategory(str, enum.Enum):
    breathing = "breathing"
    activity = "activity"
    nutrition = "nutrition"
    hydration = "hydration"
    medication = "medication"
    sleep = "sleep"
    emotional = "emotional"
    education = "education"
    wound = "wound"
    appointment = "appointment"


class ErasItem(str, enum.Enum):
    smoking = "smoking"
    nutrition = "nutrition"
    exercise = "exercise"
    breathing = "breathing"
    medications = "medications"
    skin_prep = "skin_prep"
    education = "education"


class SurgeryChecklistCategory(str, enum.Enum):
    fasting = "fasting"
    cho = "cho"
    preparation = "preparation"


class VitalType(str, enum.Enum):
    pain_rest = "pain_rest"
    pain_cough = "pain_cough"
    pain_move = "pain_move"
    mood = "mood"
    spo2 = "spo2"
    heart_rate = "heart_rate"
    bp_systolic = "bp_systolic"
    bp_diastolic = "bp_diastolic"
    weight = "weight"
    temperature = "temperature"
    steps = "steps"
    ldl = "ldl"
    hba1c = "hba1c"
    bmi = "bmi"


class VitalSource(str, enum.Enum):
    manual = "manual"
    wearable = "wearable"


class ScoreType(str, enum.Enum):
    gad7 = "gad7"
    phq9 = "phq9"
    pcl5 = "pcl5"
    delirium = "delirium"


class Severity(str, enum.Enum):
    minimal = "minimal"
    mild = "mild"
    moderate = "moderate"
    severe = "severe"


class AlertType(str, enum.Enum):
    pain_high = "pain_high"
    mood_low_3day = "mood_low_3day"
    fever = "fever"
    delirium = "delirium"
    missed_dressing = "missed_dressing"
    missed_meds = "missed_meds"
    wound_concern = "wound_concern"
    symptom_report = "symptom_report"
    abnormal_vital = "abnormal_vital"


class AlertSeverity(str, enum.Enum):
    critical = "critical"
    warning = "warning"
    info = "info"


class SymptomType(str, enum.Enum):
    incision_redness = "incision_redness"
    fever = "fever"
    increased_pain = "increased_pain"
    breathlessness = "breathlessness"
    wound_oozing = "wound_oozing"


class BreathingSessionType(str, enum.Enum):
    spirometry = "spirometry"
    breathing = "breathing"
    cough = "cough"


class MobilisationMilestone(str, enum.Enum):
    sitting = "sitting"
    standing = "standing"
    first_walk = "first_walk"
    session = "session"


class HabitType(str, enum.Enum):
    medications = "medications"
    meals = "meals"
    activity = "activity"
    stress = "stress"
    sleep = "sleep"


class CessationType(str, enum.Enum):
    smoking = "smoking"
    alcohol = "alcohol"


class JournalType(str, enum.Enum):
    decision_goal = "decision_goal"
    decision_concern = "decision_concern"
    surgeon_question = "surgeon_question"
    gratitude = "gratitude"


class JobType(str, enum.Enum):
    desk = "desk"
    light_physical = "light_physical"
    heavy_physical = "heavy_physical"


class WearableProvider(str, enum.Enum):
    apple_health = "apple_health"
    google_health = "google_health"
    fitbit = "fitbit"
    garmin = "garmin"


class WearableStatus(str, enum.Enum):
    connected = "connected"
    disconnected = "disconnected"


class WearableMetric(str, enum.Enum):
    heart_rate = "heart_rate"
    steps = "steps"
    sleep = "sleep"
    spo2 = "spo2"
    hrv = "hrv"
    ecg = "ecg"
    active_energy = "active_energy"


class ContentType(str, enum.Enum):
    video = "video"
    audio = "audio"
    guide = "guide"
    infographic = "infographic"


class ContentTopic(str, enum.Enum):
    understanding_heart = "understanding_heart"
    before_surgery = "before_surgery"
    surgery_stay = "surgery_stay"
    recovery = "recovery"
    living_well = "living_well"


class MessageCategory(str, enum.Enum):
    care_team = "care_team"
    physiotherapy = "physiotherapy"
    education = "education"
    emotional_support = "emotional_support"
    alerts = "alerts"
    family = "family"


class AppointmentType(str, enum.Enum):
    followup = "followup"
    review = "review"
    rehab = "rehab"
    physio = "physio"
    telemedicine = "telemedicine"


class RecordingType(str, enum.Enum):
    audio = "audio"
    video = "video"


class TheatreEvent(str, enum.Enum):
    checked_in = "checked_in"
    anaesthesia = "anaesthesia"
    surgery_start = "surgery_start"
    surgery_complete = "surgery_complete"
    recovery = "recovery"
    on_ward = "on_ward"


class NotificationCategory(str, enum.Enum):
    reminder = "reminder"
    education = "education"
    motivation = "motivation"
    social = "social"
    alert = "alert"
    critical = "critical"


class ReferralStatus(str, enum.Enum):
    pending = "pending"
    accepted = "accepted"
    scheduled = "scheduled"


class ReportType(str, enum.Enum):
    discharge_summary = "discharge_summary"
    recovery = "recovery"
    compliance = "compliance"
    pain_mood = "pain_mood"
    audit_export = "audit_export"


class PeerMatchType(str, enum.Enum):
    heart_buddy = "heart_buddy"
    mentor = "mentor"


class PeerMatchStatus(str, enum.Enum):
    opted_in = "opted_in"
    matched = "matched"
    left = "left"
