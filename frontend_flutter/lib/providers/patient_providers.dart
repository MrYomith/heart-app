import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment.dart';
import '../models/journey_phase.dart';
import '../models/medication.dart';
import '../models/message.dart';
import '../models/task.dart';
import '../services/patient_repository.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) => PatientRepository());

/// Today's tasks, with an optimistic toggle that persists to the backend.
class TodayTasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  TodayTasksNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }
  final PatientRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.todayTasks());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggle(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = [
      for (final t in current) t.id == id ? t.copyWith(done: !t.done) : t
    ];
    state = AsyncValue.data(updated); // optimistic
    try {
      final newDone = updated.firstWhere((t) => t.id == id).done;
      await _repo.toggleTask(id, newDone);
    } catch (_) {
      state = AsyncValue.data(current); // revert on failure
    }
  }

  int get doneCount => state.valueOrNull?.where((t) => t.done).length ?? 0;
  int get totalCount => state.valueOrNull?.length ?? 0;
}

final todayTasksProvider =
    StateNotifierProvider<TodayTasksNotifier, AsyncValue<List<Task>>>((ref) {
  return TodayTasksNotifier(ref.watch(patientRepositoryProvider));
});

final journeyProvider = FutureProvider<List<JourneyPhase>>((ref) {
  return ref.watch(patientRepositoryProvider).journey();
});

final messagesProvider = FutureProvider<List<ChatMessage>>((ref) {
  return ref.watch(patientRepositoryProvider).messages();
});

final appointmentsProvider = FutureProvider<List<Appointment>>((ref) {
  return ref.watch(patientRepositoryProvider).appointments();
});

/// Medications, with an optimistic "mark taken" that persists to the backend.
class MedicationsNotifier extends StateNotifier<AsyncValue<List<Medication>>> {
  MedicationsNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }
  final PatientRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.medications());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markTaken(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data([
      for (final m in current) m.id == id ? m.copyWith(takenToday: true) : m
    ]);
    try {
      await _repo.markMedicationTaken(id);
    } catch (_) {
      state = AsyncValue.data(current);
    }
  }
}

final medicationsProvider =
    StateNotifierProvider<MedicationsNotifier, AsyncValue<List<Medication>>>((ref) {
  return MedicationsNotifier(ref.watch(patientRepositoryProvider));
});

// ── Providers for the platform features ──────────────────────────────────
final educationProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, topic) {
  return ref.watch(patientRepositoryProvider).education(topic: topic);
});

final wearableSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(patientRepositoryProvider).wearableSummary();
});

final wearableConnectionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(patientRepositoryProvider).wearableConnections();
});

final recoveryPredictionProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(patientRepositoryProvider).recoveryPrediction();
});

final habitsTodayProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(patientRepositoryProvider).habitsToday();
});

final cessationProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(patientRepositoryProvider).cessation();
});

final journalProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, type) {
  return ref.watch(patientRepositoryProvider).journal(type: type);
});

final screeningsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(patientRepositoryProvider).screenings();
});

final weeklyGoalProvider = FutureProvider<({int minutes, int goal, int percent})>((ref) {
  return ref.watch(patientRepositoryProvider).weeklyActivityGoal();
});

/// Admin-managed content by (category, stage).
final contentProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String category, String? stage})>((ref, args) {
  return ref.watch(patientRepositoryProvider).content(args.category, stage: args.stage);
});

/// Latest value per vital type (clinician-entered labs + patient/wearable readings).
final latestVitalsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(patientRepositoryProvider).latestVitals();
});
