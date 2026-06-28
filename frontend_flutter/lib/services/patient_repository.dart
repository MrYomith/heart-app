import 'package:dio/dio.dart';

import '../models/appointment.dart';
import '../models/journey_phase.dart';
import '../models/medication.dart';
import '../models/message.dart';
import '../models/task.dart';
import 'api_client.dart';

/// Reads/writes the authenticated patient's plan, journey, and progress.
class PatientRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Task>> todayTasks() async {
    final r = await _dio.get('/api/tasks/today');
    if (r.statusCode == 200) {
      return (r.data as List).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Could not load your plan.');
  }

  Future<void> toggleTask(String id, bool done) async {
    await _dio.patch('/api/tasks/$id/toggle', data: {'is_done': done});
  }

  Future<List<JourneyPhase>> journey() async {
    final r = await _dio.get('/api/journey');
    if (r.statusCode == 200) {
      return (r.data as List).map((e) => JourneyPhase.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Could not load your journey.');
  }

  Future<({int total, int done, double percentage})> todayProgress() async {
    final r = await _dio.get('/api/progress/today');
    final d = r.data as Map<String, dynamic>;
    return (
      total: (d['total'] as num?)?.toInt() ?? 0,
      done: (d['done'] as num?)?.toInt() ?? 0,
      percentage: (d['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<List<ChatMessage>> messages() async {
    final r = await _dio.get('/api/messages');
    if (r.statusCode == 200) {
      return (r.data as List).map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Could not load your messages.');
  }

  Future<void> markMessageRead(String id) async {
    await _dio.patch('/api/messages/$id/read');
  }

  Future<List<Appointment>> appointments() async {
    final r = await _dio.get('/api/appointments');
    if (r.statusCode == 200) {
      return (r.data as List).map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Could not load your appointments.');
  }

  /// Logs a vital (e.g. mood) and returns (alertRaised, message).
  Future<({bool alertRaised, String? message})> logVital(String type, double value) async {
    final r = await _dio.post('/api/vitals', data: {'type': type, 'value': value});
    if (r.statusCode == 201) {
      return (alertRaised: (r.data['alert_raised'] as bool?) ?? false, message: r.data['message'] as String?);
    }
    throw Exception('Could not save your check-in.');
  }

  Future<List<Medication>> medications() async {
    final r = await _dio.get('/api/medications');
    if (r.statusCode == 200) {
      return (r.data as List).map((e) => Medication.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Could not load your medications.');
  }

  Future<void> markMedicationTaken(String id) async {
    await _dio.post('/api/medications/$id/taken');
  }

  Future<({int todayCount, int target})> breathingToday() async {
    final r = await _dio.get('/api/breathing/today');
    return (todayCount: (r.data['today_count'] as num).toInt(), target: (r.data['target'] as num).toInt());
  }

  Future<({int todayCount, int target})> logBreathing({String type = 'breathing', int count = 0}) async {
    final r = await _dio.post('/api/breathing', data: {'session_type': type, 'count': count});
    return (todayCount: (r.data['today_count'] as num).toInt(), target: (r.data['target'] as num).toInt());
  }

  Future<({int confusionScore, bool risk, String message})> submitDelirium(List<bool> answers) async {
    final r = await _dio.post('/api/delirium', data: {'answers': answers});
    return (
      confusionScore: (r.data['confusion_score'] as num).toInt(),
      risk: r.data['risk'] as bool,
      message: r.data['message'] as String,
    );
  }

  Future<Map<String, dynamic>> nutritionToday() async {
    final r = await _dio.get('/api/nutrition/today');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> logNutrition({int? protein, int? hydration, int? meals, bool bowel = false}) async {
    final r = await _dio.post('/api/nutrition', data: {
      'protein_grams': protein,
      'hydration_glasses': hydration,
      'meals_count': meals,
      'bowel_movement': bowel,
    });
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<({List<Map<String, dynamic>> items, int overall})> erasSummary() async {
    final r = await _dio.get('/api/eras');
    final items = (r.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return (items: items, overall: (r.data['overall'] as num).toInt());
  }

  Future<({List<Map<String, dynamic>> items, int overall})> updateEras(String key, int progress) async {
    final r = await _dio.patch('/api/eras/$key', data: {'progress': progress});
    final items = (r.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return (items: items, overall: (r.data['overall'] as num).toInt());
  }

  Future<List<Map<String, dynamic>>> mobilisation() async {
    final r = await _dio.get('/api/mobilisation');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> achieveMilestone(String id) async {
    await _dio.patch('/api/mobilisation/$id/achieve');
  }

  Future<({int? dayPostOp, bool locked, String message})> woundStatus() async {
    final r = await _dio.get('/api/wound-photos/status');
    return (
      dayPostOp: (r.data['day_post_op'] as num?)?.toInt(),
      locked: r.data['dressing_locked'] as bool? ?? false,
      message: r.data['message'] as String? ?? '',
    );
  }

  Future<List<Map<String, dynamic>>> woundPhotos() async {
    final r = await _dio.get('/api/wound-photos');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> uploadWoundPhoto(List<int> bytes, String filename) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    await _dio.post('/api/wound-photos', data: form);
  }

  /// Returns (date, value) points for a vital type over [days].
  Future<List<({DateTime date, double value})>> vitalTrend(String type, {int days = 30}) async {
    final r = await _dio.get('/api/vitals', queryParameters: {'type': type, 'days': days});
    if (r.statusCode == 200) {
      return (r.data as List).map((e) {
        final m = e as Map<String, dynamic>;
        return (date: DateTime.parse(m['recorded_at'] as String).toLocal(), value: (m['value'] as num).toDouble());
      }).toList();
    }
    throw Exception('Could not load your trend.');
  }

  // ── Symptom escalation (FR-202) ───────────────────────────────────────
  Future<({String severity})> reportSymptom(String symptom, {String? note}) async {
    final r = await _dio.post('/api/symptoms', data: {'symptom': symptom, 'note': note});
    return (severity: (r.data['alert_severity'] as String?) ?? '');
  }

  // ── Smart recovery check-in (FR-201) ──────────────────────────────────
  Future<({bool raisedAlert})> submitRecoveryCheckin({
    String? feeling, bool woundIssues = false, int? painLevel, String? sleepQuality, String? concerns,
  }) async {
    final r = await _dio.post('/api/recovery-checkin', data: {
      'feeling': feeling, 'wound_issues': woundIssues, 'pain_level': painLevel,
      'sleep_quality': sleepQuality, 'concerns': concerns,
    });
    return (raisedAlert: (r.data['raised_alert'] as bool?) ?? false);
  }

  // ── PHQ-9 / PCL-5 screening (FR-124) ──────────────────────────────────
  Future<({String severity, bool referral})> submitScreening(String scoreType, int score, {Map<String, dynamic>? answers}) async {
    final r = await _dio.post('/api/screening', data: {'score_type': scoreType, 'score': score, 'answers': answers});
    return (severity: (r.data['severity'] as String?) ?? 'minimal', referral: (r.data['referral_created'] as bool?) ?? false);
  }

  Future<List<Map<String, dynamic>>> screenings() async {
    final r = await _dio.get('/api/screening');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── AI food logging (FR-044 AI) ───────────────────────────────────────
  Future<Map<String, dynamic>> analyzeFood({String? description, List<int>? imageBytes, String? filename}) async {
    final map = <String, dynamic>{};
    if (description != null) map['description'] = description;
    if (imageBytes != null) map['file'] = MultipartFile.fromBytes(imageBytes, filename: filename ?? 'meal.jpg');
    final r = await _dio.post('/api/food/analyze', data: FormData.fromMap(map));
    return Map<String, dynamic>.from(r.data['analysis'] as Map);
  }

  // ── Wearables (FR-240–243) ────────────────────────────────────────────
  Future<Map<String, dynamic>> wearableSummary() async {
    final r = await _dio.get('/api/wearables/summary');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<List<Map<String, dynamic>>> wearableConnections() async {
    final r = await _dio.get('/api/wearables/connections');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> connectWearable(String provider) async {
    await _dio.post('/api/wearables/connect', data: {'provider': provider});
  }

  Future<({int stored, bool alertRaised})> ingestReadings(String provider, List<Map<String, dynamic>> readings) async {
    final r = await _dio.post('/api/wearables/readings', data: {'provider': provider, 'readings': readings});
    return (stored: (r.data['stored'] as num?)?.toInt() ?? 0, alertRaised: (r.data['alert_raised'] as bool?) ?? false);
  }

  // ── Activity + weekly goal (FR-045/141) ───────────────────────────────
  Future<void> logActivity({int? steps, int? activeMinutes, int? walkSeconds}) async {
    await _dio.post('/api/activity', data: {'steps': steps, 'active_minutes': activeMinutes, 'walk_duration_sec': walkSeconds});
  }

  Future<({int minutes, int goal, int percent})> weeklyActivityGoal() async {
    final r = await _dio.get('/api/activity/weekly-goal');
    return (minutes: (r.data['active_minutes'] as num?)?.toInt() ?? 0,
            goal: (r.data['goal_minutes'] as num?)?.toInt() ?? 150,
            percent: (r.data['percent'] as num?)?.toInt() ?? 0);
  }

  // ── Cessation streaks (FR-046) ────────────────────────────────────────
  Future<List<Map<String, dynamic>>> cessation() async {
    final r = await _dio.get('/api/cessation');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> setCessation(String type, {String? startDate, String? goal}) async {
    await _dio.post('/api/cessation', data: {'type': type, 'start_date': startDate, 'goal': goal});
  }

  // ── Journal + gratitude (FR-067/142) ──────────────────────────────────
  Future<List<Map<String, dynamic>>> journal({String? type}) async {
    final r = await _dio.get('/api/journal', queryParameters: type != null ? {'type': type} : null);
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> addJournal(String type, String body, {bool shareWithCareTeam = false}) async {
    await _dio.post('/api/journal', data: {'type': type, 'body': body, 'shared_with_care_team': shareWithCareTeam});
  }

  // ── Habits (FR-140) ───────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> habitsToday() async {
    final r = await _dio.get('/api/habits/today');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> logHabit(String habit, bool done) async {
    await _dio.post('/api/habits', data: {'habit': habit, 'done': done});
  }

  // ── Return-to-work (FR-123) ───────────────────────────────────────────
  Future<Map<String, dynamic>> returnToWork() async {
    final r = await _dio.get('/api/return-to-work');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> setReturnToWork(String jobType) async {
    final r = await _dio.post('/api/return-to-work', data: {'job_type': jobType});
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ── Rehab enrolment (FR-120) ──────────────────────────────────────────
  Future<Map<String, dynamic>> rehab() async {
    final r = await _dio.get('/api/rehab');
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ── Recovery prediction (FR-164) ──────────────────────────────────────
  Future<Map<String, dynamic>> recoveryPrediction() async {
    final r = await _dio.get('/api/recovery/prediction');
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ── Education hub (FR-180–184) ────────────────────────────────────────
  Future<List<Map<String, dynamic>>> education({String? topic}) async {
    final r = await _dio.get('/api/education', queryParameters: topic != null ? {'topic': topic} : null);
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> trackEducationProgress(String contentId, {int? resumeSec, bool? completed, bool? favourited}) async {
    await _dio.post('/api/education/$contentId/progress', data: {
      'resume_position_sec': resumeSec, 'completed': completed, 'favourited': favourited,
    });
  }

  // ── Outbound messaging (FR-200) ───────────────────────────────────────
  Future<void> sendMessage(String body) async {
    await _dio.post('/api/messages/send', data: {'body': body});
  }

  /// Latest value per vital type (BP, LDL, HbA1c, weight, etc.) for metric cards.
  Future<Map<String, dynamic>> latestVitals() async {
    final r = await _dio.get('/api/vitals/latest');
    if (r.statusCode == 200) return Map<String, dynamic>.from(r.data as Map);
    return {};
  }

  // ── Admin-managed content & catalogs (AppContent) ─────────────────────
  Future<List<Map<String, dynamic>>> content(String category, {String? stage}) async {
    final r = await _dio.get('/api/content', queryParameters: {'category': category, if (stage != null) 'stage': stage});
    if (r.statusCode == 200) {
      return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  // ── Quizzes & badges (FR-182/183) ─────────────────────────────────────
  Future<List<Map<String, dynamic>>> quizzes({String? topic}) async {
    final r = await _dio.get('/api/quizzes', queryParameters: topic != null ? {'topic': topic} : null);
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> quiz(String id) async {
    final r = await _dio.get('/api/quizzes/$id');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> submitQuiz(String id, Map<String, int> answers) async {
    final r = await _dio.post('/api/quizzes/$id/attempt', data: {'answers': answers});
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<List<Map<String, dynamic>>> badges() async {
    final r = await _dio.get('/api/badges');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Recovery guide + physiotherapy plan (FR-162/163) ──────────────────
  Future<List<Map<String, dynamic>>> recoveryGuide() async {
    final r = await _dio.get('/api/recovery/guide');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> physiotherapyPlan() async {
    final r = await _dio.get('/api/physiotherapy/plan');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Settings: notifications, language, privacy/data (FR-300/304/305) ───
  Future<Map<String, dynamic>> notificationPrefs() async {
    final r = await _dio.get('/api/settings/notifications');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> updateNotificationPrefs({
    required List<String> mutedCategories,
    required String quietStart,
    required String quietEnd,
  }) async {
    final r = await _dio.put('/api/settings/notifications', data: {
      'muted_categories': mutedCategories,
      'quiet_hours_start': quietStart,
      'quiet_hours_end': quietEnd,
    });
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<void> setLocale(String locale) async {
    await _dio.patch('/api/settings/locale', data: {'locale': locale});
  }

  Future<Map<String, dynamic>> exportMyData() async {
    final r = await _dio.post('/api/settings/data-export');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<void> deleteMyAccount() async {
    await _dio.post('/api/settings/data-deletion', data: {'confirm': true});
  }
}
