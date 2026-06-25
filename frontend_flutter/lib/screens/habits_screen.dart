import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// Daily habits (FR-140) + smoking/alcohol cessation streaks (FR-046).
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  static const _habitLabels = {
    'medications': '💊 Took medications', 'meals': '🥗 Ate well', 'activity': '🚶 Stayed active',
    'stress': '🧘 Managed stress', 'sleep': '😴 Slept well',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsTodayProvider);
    final cessation = ref.watch(cessationProvider);
    final goal = ref.watch(weeklyGoalProvider);
    final repo = ref.read(patientRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bgCard, title: Text('Healthy Habits', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Weekly activity goal
        goal.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (g) => Container(
            padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16), decoration: AppDecorations.card,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Weekly activity goal', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: g.percent / 100, minHeight: 10, backgroundColor: AppColors.bg, color: AppColors.teal)),
              const SizedBox(height: 6),
              Text('${g.minutes} / ${g.goal} active minutes', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
            ]),
          ),
        ),
        Text("Today's habits", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        habits.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Could not load habits.', style: GoogleFonts.inter(color: AppColors.textMedium)),
          data: (list) => Column(children: [
            for (final h in list)
              Container(
                margin: const EdgeInsets.only(bottom: 8), decoration: AppDecorations.card,
                child: CheckboxListTile(
                  value: (h['done'] as bool?) ?? false,
                  activeColor: AppColors.teal,
                  title: Text(_habitLabels[h['habit']] ?? (h['habit'] as String), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  onChanged: (v) async {
                    await repo.logHabit(h['habit'] as String, v ?? false);
                    ref.invalidate(habitsTodayProvider);
                  },
                ),
              ),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Cessation streaks', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        cessation.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (list) {
            final byType = {for (final c in list) c['type'] as String: c};
            Widget tile(String type, String emoji, String label) {
              final c = byType[type];
              final days = c == null ? null : (c['current_streak_days'] as num?)?.toInt();
              return Container(
                margin: const EdgeInsets.only(bottom: 8), decoration: AppDecorations.card,
                child: ListTile(
                  leading: Text(emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  subtitle: days != null ? Text('$days days free 🎉', style: GoogleFonts.inter(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w700)) : null,
                  trailing: days == null
                      ? OutlinedButton(onPressed: () async { await repo.setCessation(type); ref.invalidate(cessationProvider); }, child: const Text('Start'))
                      : null,
                ),
              );
            }
            return Column(children: [tile('smoking', '🚭', 'Smoke-free'), tile('alcohol', '🍷', 'Alcohol-free')]);
          },
        ),
      ]),
    );
  }
}
