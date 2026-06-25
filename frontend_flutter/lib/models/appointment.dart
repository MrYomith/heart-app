class Appointment {
  final String id;
  final String title;
  final String? subtitle;
  final String date;
  final String? time;
  final String? location;
  final String type;
  final bool isConfirmed;

  const Appointment({
    required this.id,
    required this.title,
    this.subtitle,
    required this.date,
    this.time,
    this.location,
    this.type = 'followup',
    this.isConfirmed = true,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: j['id'].toString(),
        title: j['title'] as String,
        subtitle: j['subtitle'] as String?,
        date: (j['date'] as String?) ?? '',
        time: j['time'] as String?,
        location: j['location'] as String?,
        type: (j['appointment_type'] as String?) ?? 'followup',
        isConfirmed: (j['is_confirmed'] as bool?) ?? true,
      );

  String get icon {
    switch (type) {
      case 'review':
        return '🩸';
      case 'rehab':
        return '🚶';
      case 'physio':
        return '🏃';
      case 'telemedicine':
        return '💻';
      default:
        return '🏥';
    }
  }
}
