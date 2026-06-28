class Task {
  final String id;
  final String icon;
  final String title;
  final String subtitle;
  final String time;
  final String timeColor; // 'teal' | 'orange' | 'red'
  final bool done;
  final String category;
  final String? reasoning; // "Why this?" — clinical reasoning (FR-160)

  const Task({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.timeColor = 'teal',
    this.done = false,
    required this.category,
    this.reasoning,
  });

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'].toString(),
        icon: (j['icon'] as String?) ?? '•',
        title: j['title'] as String,
        subtitle: (j['subtitle'] as String?) ?? '',
        time: (j['scheduled_time'] as String?) ?? '',
        timeColor: (j['time_color'] as String?) ?? 'teal',
        done: (j['is_done'] as bool?) ?? false,
        category: (j['category'] as String?) ?? '',
        reasoning: j['reasoning'] as String?,
      );

  Task copyWith({bool? done}) => Task(
        id: id,
        icon: icon,
        title: title,
        subtitle: subtitle,
        time: time,
        timeColor: timeColor,
        done: done ?? this.done,
        category: category,
        reasoning: reasoning,
      );
}
