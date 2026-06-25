class Medication {
  final String id;
  final String name;
  final String dose;
  final String schedule;
  final List<String> times;
  final bool isAnticoagulant;
  final String? purpose;
  final bool takenToday;

  const Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.schedule,
    required this.times,
    this.isAnticoagulant = false,
    this.purpose,
    this.takenToday = false,
  });

  factory Medication.fromJson(Map<String, dynamic> j) => Medication(
        id: j['id'].toString(),
        name: j['name'] as String,
        dose: (j['dose'] as String?) ?? '',
        schedule: (j['schedule'] as String?) ?? '',
        times: (j['times'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        isAnticoagulant: (j['is_anticoagulant'] as bool?) ?? false,
        purpose: j['purpose'] as String?,
        takenToday: (j['taken_today'] as bool?) ?? false,
      );

  Medication copyWith({bool? takenToday}) => Medication(
        id: id, name: name, dose: dose, schedule: schedule, times: times,
        isAnticoagulant: isAnticoagulant, purpose: purpose, takenToday: takenToday ?? this.takenToday,
      );
}
