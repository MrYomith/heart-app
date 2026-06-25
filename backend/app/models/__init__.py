"""Model registry — importing this package registers every table on Base.metadata.

Grouped by the 12 domains of the MioHeart schema.
"""
from app.models.identity import (
    AuditLog,
    CarerLink,
    ClinicianAssignment,
    ConsentLog,
    DataRequest,
    Device,
    Hospital,
    NotificationPreference,
    User,
)
from app.models.onboarding import (
    Goal,
    Medication,
    MedicationLog,
    OnboardingProgress,
    PatientAllergy,
    PatientCondition,
)
from app.models.journey import JourneyPhase, StageTransition
from app.models.enrollment import EnrollmentCode, HospitalEnrollment
from app.models.plan import ErasProgress, SurgeryChecklist, Task
from app.models.clinical import (
    Alert,
    ClinicalScore,
    RecoveryCheckin,
    RecoverySnapshot,
    SymptomReport,
    Vital,
    WoundPhoto,
)
from app.models.lifestyle import (
    ActivityLog,
    BreathingSession,
    CessationTracking,
    HabitLog,
    JournalEntry,
    MobilisationMilestoneLog,
    NutritionLog,
    ReturnToWorkPlan,
)
from app.models.wearables import WearableConnection, WearableReading
from app.models.content import (
    AppContent,
    Badge,
    ContentProgress,
    EducationContent,
    Quiz,
    QuizAttempt,
    QuizQuestion,
    UserBadge,
)
from app.models.messaging import Message, MessageTemplate, MessageThread
from app.models.care import Appointment, RehabEnrollment, Recording, TheatreStatusEvent
from app.models.notifications import Notification
from app.models.clinician import PeerMatch, Referral, Report

__all__ = [
    # identity
    "User", "Hospital", "Device", "ConsentLog", "AuditLog", "CarerLink",
    "ClinicianAssignment", "NotificationPreference", "DataRequest",
    # onboarding
    "OnboardingProgress", "PatientCondition", "PatientAllergy", "Medication",
    "MedicationLog", "Goal",
    # journey
    "JourneyPhase", "StageTransition",
    # enrollment
    "EnrollmentCode", "HospitalEnrollment",
    # plan
    "Task", "ErasProgress", "SurgeryChecklist",
    # clinical
    "Vital", "ClinicalScore", "Alert", "SymptomReport", "WoundPhoto",
    "RecoveryCheckin", "RecoverySnapshot",
    # lifestyle
    "NutritionLog", "ActivityLog", "BreathingSession", "MobilisationMilestoneLog",
    "HabitLog", "CessationTracking", "JournalEntry", "ReturnToWorkPlan",
    # wearables
    "WearableConnection", "WearableReading",
    # content
    "AppContent", "EducationContent", "ContentProgress", "Quiz", "QuizQuestion", "QuizAttempt",
    "Badge", "UserBadge",
    # messaging
    "MessageThread", "Message", "MessageTemplate",
    # care
    "Appointment", "RehabEnrollment", "Recording", "TheatreStatusEvent",
    # notifications
    "Notification",
    # clinician
    "Referral", "Report", "PeerMatch",
]
