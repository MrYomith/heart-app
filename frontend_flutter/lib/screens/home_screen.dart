import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_providers.dart';
import '../utils/responsive.dart';
import '../widgets/mio_mascot.dart';
import '../widgets/progress_ring.dart';
import 'today_plan_screen.dart';
import 'journey_screen.dart';
import 'messages_screen.dart';
import 'calendar_screen.dart';
import 'emotional_checkin_screen.dart';
import 'pain_tracking_screen.dart';
import 'medications_screen.dart';
import 'breathing_screen.dart';
import 'eras_screen.dart';
import 'wearables_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hp(context);
    final fs = Responsive.fontScale(context);
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero ─────────────────────────────────────
                  Container(
                    color: AppColors.bgBanner,
                    padding: EdgeInsets.fromLTRB(pad, isWide ? 24 : 20, pad, isWide ? 24 : 20),
                    child: isWide
                        ? _HeroWide(fs: fs)
                        : _HeroPhone(fs: fs),
                  ),

                  // ── Quote ────────────────────────────────────
                  Container(
                    margin: EdgeInsets.fromLTRB(pad, 12, pad, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Text('"', style: GoogleFonts.inter(fontSize: 24 * fs, color: AppColors.primary, height: 0.8)),
                        const SizedBox(width: 4),
                        Expanded(child: Text('Small steps today, stronger heart tomorrow. 🤍', style: GoogleFonts.inter(fontSize: 13 * fs, fontStyle: FontStyle.italic, color: AppColors.textDark))),
                      ],
                    ),
                  ),

                  SizedBox(height: isWide ? 20 : 16),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: isWide
                        // ── Tablet: 3-column top section ──────────
                        ? _WideTopSection(fs: fs)
                        // ── Phone: 2-column top section ───────────
                        : _PhoneTopSection(fs: fs),
                  ),

                  SizedBox(height: isWide ? 20 : 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: Text('Quick Access', style: GoogleFonts.inter(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: _QuickActionsGrid(fs: fs),
                  ),

                  SizedBox(height: isWide ? 20 : 16),
                  // ── Motivational banner ───────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Icon(Icons.shield_rounded, size: 28 * fs, color: AppColors.tealDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Every action you take now', style: GoogleFonts.inter(fontSize: 13 * fs, color: AppColors.tealDark)),
                                Text('is building your stronger tomorrow.', style: GoogleFonts.inter(fontSize: 13 * fs, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
                              ],
                            ),
                          ),
                          MioMascot(variant: MioVariant.celebrate, size: Responsive.value(context, phone: 54.0, tablet: 70.0)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero variants ────────────────────────────────────────────────────────────

class _HeroPhone extends StatelessWidget {
  final double fs;
  const _HeroPhone({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MioMascot(variant: MioVariant.happy, size: 84),
        const SizedBox(width: 12),
        Expanded(child: _HeroText(fs: fs)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(20)),
          child: Text('☀️ 15°C', style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ),
      ],
    );
  }
}

class _HeroWide extends StatelessWidget {
  final double fs;
  const _HeroWide({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MioMascot(variant: MioVariant.happy, size: Responsive.isLarge(context) ? 120 : 96),
        const SizedBox(width: 20),
        Expanded(child: _HeroText(fs: fs)),
        const SizedBox(width: 16),
        // Extra wearable stat cards on wide screens
        const Column(
          children: [
            _WeatherStatCard('☀️ 15°C', 'Weather'),
            SizedBox(height: 8),
            _WeatherStatCard('❤️ 72bpm', 'Heart Rate'),
          ],
        ),
      ],
    );
  }
}

class _HeroText extends ConsumerWidget {
  final double fs;
  const _HeroText({required this.fs});

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final name = user?.firstName ?? 'there';
    final phaseLabel = user?.phaseLabel ?? 'Getting Started';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_greeting(), style: GoogleFonts.inter(fontSize: 13 * fs, color: AppColors.textMedium)),
        Row(children: [
          Flexible(
            child: Text(name,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 22 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ),
          const SizedBox(width: 4),
          const Text('🤍', style: TextStyle(fontSize: 16)),
        ]),
        const SizedBox(height: 6),
        Text("You're doing something amazing for your heart. We're in this together.", style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium, height: 1.5)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
          child: Text('🌱 $phaseLabel', style: GoogleFonts.inter(fontSize: 11 * fs, fontWeight: FontWeight.w600, color: AppColors.teal)),
        ),
      ],
    );
  }
}

class _WeatherStatCard extends StatelessWidget {
  final String value;
  final String label;
  const _WeatherStatCard(this.value, this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMedium)),
      ]),
    );
  }
}

// ─── Top section variants ─────────────────────────────────────────────────────

class _PhoneTopSection extends StatelessWidget {
  final double fs;
  const _PhoneTopSection({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _TodayPlanCard(fs: fs)),
        const SizedBox(width: 12),
        Expanded(child: _ProgressCard(fs: fs)),
      ],
    );
  }
}

class _WideTopSection extends StatelessWidget {
  final double fs;
  const _WideTopSection({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _TodayPlanCard(fs: fs)),
        const SizedBox(width: 14),
        Expanded(child: _ProgressCard(fs: fs)),
        const SizedBox(width: 14),
        Expanded(child: _WearableCard(fs: fs)),
      ],
    );
  }
}

class _TodayPlanCard extends ConsumerWidget {
  final double fs;
  const _TodayPlanCard({required this.fs});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(todayTasksProvider).valueOrNull ?? const [];
    final preview = all.take(3).toList();
    final doneCount = all.where((t) => t.done == true).length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(all.isEmpty ? "Today's Plan" : "Today's Plan · $doneCount/${all.length}",
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TodayPlanScreen())),
                child: Text('View all', style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: AppColors.teal)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (preview.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No tasks yet', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textLight)),
            )
          else
            ...preview.map((t) => _MiniTaskRow(task: t, fs: fs)),
        ],
      ),
    );
  }
}

class _ProgressCard extends ConsumerWidget {
  final double fs;
  const _ProgressCard({required this.fs});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final base = (user?.journeyProgress ?? 0).toDouble();
    final phaseLabel = user?.phaseLabel ?? 'Getting Started';
    final nextLabel = user?.nextPhaseLabel ?? '';
    // Blend the phase milestone with today's task completion so the ring climbs
    // as the patient ticks tasks. Capped at 90% of the step to the next phase so
    // it never falsely reaches the next milestone (that only happens on transition).
    final tasks = ref.watch(todayTasksProvider).valueOrNull ?? const [];
    final total = tasks.length;
    final doneToday = tasks.where((t) => t.done == true).length;
    final step = nextLabel.isNotEmpty ? 20.0 : 0.0;
    final frac = total > 0 ? doneToday / total : 0.0;
    final progress = (base + step * frac * 0.9).round().clamp(0, 100);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('📈 Progress',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JourneyScreen())),
                child: Text('Journey', style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: AppColors.teal)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressRing(value: progress.toDouble(), max: 100, size: Responsive.value(context, phone: 80.0, tablet: 90.0), label: '$progress%', sublabel: 'of journey'),
          const SizedBox(height: 8),
          Text(phaseLabel, style: GoogleFonts.inter(fontSize: 11 * fs, fontWeight: FontWeight.w700, color: AppColors.teal), textAlign: TextAlign.center),
          if (nextLabel.isNotEmpty)
            Text('Next: $nextLabel', style: GoogleFonts.inter(fontSize: 10 * fs, color: AppColors.textMedium), textAlign: TextAlign.center),
          if (total > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('$doneToday/$total tasks done today', style: GoogleFonts.inter(fontSize: 9.5 * fs, color: AppColors.textLight), textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}

class _WearableCard extends ConsumerWidget {
  final double fs;
  const _WearableCard({required this.fs});

  String _fmt(Map s, String key, String unit) {
    final m = s[key] as Map?;
    if (m == null) return '—';
    final v = (m['value'] as num);
    final n = v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
    return '$n $unit';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(wearableSummaryProvider);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WearablesScreen())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⌚ Wearables', style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 10),
            summary.when(
              loading: () => const Padding(padding: EdgeInsets.all(8), child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))),
              error: (e, _) => Text('Tap to connect a device', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
              data: (s) => s.isEmpty
                  ? Text('No readings yet — tap to add', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium))
                  : Column(children: [
                      _StatRow(Icons.favorite_rounded, AppColors.primary, 'Heart Rate', _fmt(s, 'heart_rate', 'bpm')),
                      _StatRow(Icons.directions_walk_rounded, AppColors.teal, 'Steps', _fmt(s, 'steps', '')),
                      _StatRow(Icons.water_drop_rounded, AppColors.teal, 'SpO₂', _fmt(s, 'spo2', '%')),
                      _StatRow(Icons.bedtime_rounded, AppColors.teal, 'Sleep', _fmt(s, 'sleep', 'h')),
                    ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatRow(this.icon, this.color, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium))),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ]),
    );
  }
}

class _MiniTaskRow extends ConsumerWidget {
  final dynamic task;
  final double fs;
  const _MiniTaskRow({required this.task, required this.fs});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => ref.read(todayTasksProvider.notifier).toggle(task.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Text(task.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: GoogleFonts.inter(fontSize: 11 * fs, fontWeight: FontWeight.w600, color: AppColors.textDark), overflow: TextOverflow.ellipsis),
              Text(task.subtitle, style: GoogleFonts.inter(fontSize: 10 * fs, color: AppColors.textMedium), overflow: TextOverflow.ellipsis),
            ],
          )),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.done ? AppColors.teal : Colors.transparent,
              border: Border.all(color: task.done ? AppColors.teal : AppColors.border, width: 1.5),
            ),
            child: task.done ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }
}

// ─── Quick Actions Grid ────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  final double fs;
  const _QuickActionsGrid({required this.fs});

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.gridCols(context, phone: 4, fold: 6, tablet: 8);
    final actions = <(IconData, Color, String, String, Widget)>[
      (Icons.sentiment_satisfied_rounded, AppColors.teal, 'Emotional\nCheck-in', 'How are you\nfeeling?', const EmotionalCheckinScreen()),
      (Icons.medication_rounded, AppColors.primary, 'Medications', 'Tap to view\n& mark taken', const MedicationsScreen()),
      (Icons.calendar_month_rounded, AppColors.teal, 'Calendar', 'Appointments\n& plan', const CalendarScreen()),
      (Icons.monitor_heart_rounded, AppColors.primary, 'Pain Check', 'Log how you\nfeel', const PainTrackingScreen()),
      (Icons.checklist_rounded, AppColors.teal, 'Surgery Prep', 'ERAS\nchecklist', const ErasScreen()),
      (Icons.watch_rounded, AppColors.teal, 'Wearables', 'Devices &\nreadings', const WearablesScreen()),
      (Icons.air_rounded, AppColors.teal, 'Breathing', 'Guided\ncoach', const BreathingScreen()),
      (Icons.headset_mic_rounded, AppColors.primary, 'Contact\nTeam', "We're here", const MessagesScreen()),
    ];

    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: cols > 5 ? 0.80 : 0.74,
      children: actions.map((a) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => a.$5)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40 * fs, height: 40 * fs,
              decoration: BoxDecoration(color: a.$2.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(a.$1, size: 21 * fs, color: a.$2),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(a.$3, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 10 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.15), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(a.$4, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 9 * fs, color: AppColors.textMedium, height: 1.15), textAlign: TextAlign.center),
            ),
          ]),
        ),
      )).toList(),
    );
  }
}
