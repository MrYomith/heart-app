class Task {
  final int id;
  final String icon;
  final String title;
  final String subtitle;
  final String time;
  final String timeColor; // 'teal' | 'orange' | 'red'
  final bool done;
  final String category;

  const Task({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.timeColor = 'teal',
    this.done = false,
    required this.category,
  });

  Task copyWith({bool? done}) => Task(
        id: id,
        icon: icon,
        title: title,
        subtitle: subtitle,
        time: time,
        timeColor: timeColor,
        done: done ?? this.done,
        category: category,
      );
}
