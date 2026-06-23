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
}
