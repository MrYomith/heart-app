class JourneyPhase {
  final String id;
  final String label;
  final String emoji;
  final String status; // 'completed' | 'active' | 'upcoming'
  final String? date;
  final String? subtitle;
  final String mioMessage;

  const JourneyPhase({
    required this.id,
    required this.label,
    required this.emoji,
    required this.status,
    this.date,
    this.subtitle,
    required this.mioMessage,
  });

  factory JourneyPhase.fromJson(Map<String, dynamic> j) => JourneyPhase(
        id: (j['phase_key'] as String?) ?? j['id'].toString(),
        label: j['label'] as String,
        emoji: (j['emoji'] as String?) ?? '🫀',
        status: (j['status'] as String?) ?? 'upcoming',
        date: j['date_label'] as String?,
        subtitle: j['subtitle'] as String?,
        mioMessage: '',
      );
}
