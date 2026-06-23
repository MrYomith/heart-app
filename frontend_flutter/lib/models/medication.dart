class Medication {
  final int id;
  final String name;
  final String dose;
  final String schedule;
  final List<String> times;

  const Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.schedule,
    required this.times,
  });
}
