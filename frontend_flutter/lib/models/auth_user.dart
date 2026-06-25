/// The authenticated user as returned by the backend (`UserPublic`).
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool onboardingComplete;
  final String? currentPhase;
  final double journeyProgress;
  final String? surgeryType;
  final String? surgeryDate;
  final String? dischargeDate;
  final String? surgeonName;
  final String? diagnosis;
  final String? nyhaClass;
  final String? hospitalName;
  final String? surgeonMessage;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.onboardingComplete,
    this.currentPhase,
    this.journeyProgress = 0.0,
    this.surgeryType,
    this.surgeryDate,
    this.dischargeDate,
    this.surgeonName,
    this.diagnosis,
    this.nyhaClass,
    this.hospitalName,
    this.surgeonMessage,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        role: json['role'] as String? ?? 'patient',
        onboardingComplete: json['onboarding_complete'] as bool? ?? false,
        currentPhase: json['current_phase'] as String?,
        journeyProgress: (json['journey_progress'] as num?)?.toDouble() ?? 0.0,
        surgeryType: json['surgery_type'] as String?,
        surgeryDate: json['surgery_date'] as String?,
        dischargeDate: json['discharge_date'] as String?,
        surgeonName: json['surgeon_name'] as String?,
        diagnosis: json['diagnosis'] as String?,
        nyhaClass: json['nyha_class'] as String?,
        hospitalName: json['hospital_name'] as String?,
        surgeonMessage: json['surgeon_message'] as String?,
      );

  /// Days since surgery (negative = days until). Null when no surgery date.
  int? get dayPostOp {
    if (surgeryDate == null) return null;
    final d = DateTime.tryParse(surgeryDate!);
    if (d == null) return null;
    return DateTime.now().difference(DateTime(d.year, d.month, d.day)).inDays;
  }

  String get firstName => name.trim().isEmpty ? 'there' : name.trim().split(' ').first;

  /// Plain-language label for the current journey stage.
  String get phaseLabel {
    switch (currentPhase) {
      case 'diagnosis':
        return 'Diagnosis';
      case 'preop':
        return 'Pre-op Preparation';
      case 'surgery':
        return 'Surgery Day';
      case 'inpatient':
        return 'Inpatient Recovery';
      case 'rehab':
        return 'Post-Discharge Rehab';
      case 'thriving':
        return 'Thriving';
      default:
        return 'Getting Started';
    }
  }

  /// The stage that comes after the current one (for "Next: …").
  String get nextPhaseLabel {
    const order = ['diagnosis', 'preop', 'surgery', 'inpatient', 'rehab', 'thriving'];
    const labels = {
      'preop': 'Pre-op Preparation',
      'surgery': 'Surgery Day',
      'inpatient': 'Inpatient Recovery',
      'rehab': 'Post-Discharge Rehab',
      'thriving': 'Thriving',
    };
    final i = order.indexOf(currentPhase ?? 'diagnosis');
    if (i < 0 || i >= order.length - 1) return 'Thriving';
    return labels[order[i + 1]] ?? '';
  }
}
