import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../utils/responsive.dart';
import '../widgets/mio_mascot.dart';
import '../widgets/progress_ring.dart';
import 'today_plan_screen.dart';
import 'journey_screen.dart';
import 'messages_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hp(context);
    final fs = Responsive.fontScale(context);
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
    final previewTasks = todayTasks.take(3).toList();

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
                        ? _WideTopSection(previewTasks: previewTasks, fs: fs)
                        // ── Phone: 2-column top section ───────────
                        : _PhoneTopSection(previewTasks: previewTasks, fs: fs),
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
                          Text('🛡️', style: TextStyle(fontSize: 28 * fs)),
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
        Column(
          children: [
            _WeatherStatCard('☀️ 15°C', 'Weather'),
            const SizedBox(height: 8),
            _WeatherStatCard('❤️ 72bpm', 'Heart Rate'),
          ],
        ),
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  final double fs;
  const _HeroText({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good morning,', style: GoogleFonts.inter(fontSize: 13 * fs, color: AppColors.textMedium)),
        Row(children: [
          Text(userName, style: GoogleFonts.inter(fontSize: 22 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(width: 4),
          const Text('🤍', style: TextStyle(fontSize: 16)),
        ]),
        const SizedBox(height: 6),
        Text("You're doing something amazing for your heart. We're in this together.", style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium, height: 1.5)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
          child: Text('🌱 Pre-op Preparation', style: GoogleFonts.inter(fontSize: 11 * fs, fontWeight: FontWeight.w600, color: AppColors.teal)),
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
  final List previewTasks;
  final double fs;
  const _PhoneTopSection({required this.previewTasks, required this.fs});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _TodayPlanCard(previewTasks: previewTasks, fs: fs)),
        const SizedBox(width: 12),
        Expanded(child: _ProgressCard(fs: fs)),
      ],
    );
  }
}

class _WideTopSection extends StatelessWidget {
  final List previewTasks;
  final double fs;
  const _WideTopSection({required this.previewTasks, required this.fs});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _TodayPlanCard(previewTasks: previewTasks, fs: fs)),
        const SizedBox(width: 14),
        Expanded(child: _ProgressCard(fs: fs)),
        const SizedBox(width: 14),
        Expanded(child: _WearableCard(fs: fs)),
      ],
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  final List previewTasks;
  final double fs;
  const _TodayPlanCard({required this.previewTasks, required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("📋 Today's Plan", style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TodayPlanScreen())),
                child: Text('View all', style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: AppColors.teal)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...previewTasks.map((t) => _MiniTaskRow(task: t, fs: fs)),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double fs;
  const _ProgressCard({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📈 Progress', style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JourneyScreen())),
                child: Text('Journey', style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w600, color: AppColors.teal)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressRing(value: journeyProgress.toDouble(), max: 100, size: Responsive.value(context, phone: 80.0, tablet: 90.0), label: '$journeyProgress%', sublabel: 'of journey'),
          const SizedBox(height: 8),
          Text('Pre-op Preparation', style: GoogleFonts.inter(fontSize: 11 * fs, fontWeight: FontWeight.w700, color: AppColors.teal), textAlign: TextAlign.center),
          Text('Next: Surgery Day', style: GoogleFonts.inter(fontSize: 10 * fs, color: AppColors.textMedium), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _WearableCard extends StatelessWidget {
  final double fs;
  const _WearableCard({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⌚ Wearables', style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          _StatRow('❤️', 'Heart Rate', '72 bpm'),
          _StatRow('🦶', 'Steps', '5,240'),
          _StatRow('💧', 'SpO₂', '98%'),
          _StatRow('😴', 'Sleep', '7h 15m'),
          const SizedBox(height: 6),
          Text('Connected · Last sync: now', style: GoogleFonts.inter(fontSize: 10 * fs, color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _StatRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium))),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ]),
    );
  }
}

class _MiniTaskRow extends StatelessWidget {
  final dynamic task;
  final double fs;
  const _MiniTaskRow({required this.task, required this.fs});
  @override
  Widget build(BuildContext context) {
    return Padding(
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
    final actions = [
      ('💚', 'Emotional\nCheck-in', 'How are you\nfeeling?', null),
      ('💊', 'Medications', 'Next: 08:00\nAspirin', null),
      ('📅', 'Calendar', 'Next: Pre-op', const CalendarScreen()),
      ('❤️', 'Symptoms', 'No alerts\ntoday', null),
      ('🎯', 'Goals', 'Stay active,\neat well', null),
      ('⌚', 'Wearables', 'Connected\nGood sync', null),
      ('💧', 'Glucose', '112 mg/dL', null),
      ('🎧', 'Contact\nTeam', "We're here", const MessagesScreen()),
    ];

    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: cols > 5 ? 0.85 : 0.9,
      children: actions.map((a) => GestureDetector(
        onTap: a.$4 != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => a.$4!)) : null,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(a.$1, style: TextStyle(fontSize: 22 * fs)),
            const SizedBox(height: 3),
            Text(a.$2, style: GoogleFonts.inter(fontSize: 10 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark), textAlign: TextAlign.center),
            Text(a.$3, style: GoogleFonts.inter(fontSize: 9 * fs, color: AppColors.textMedium), textAlign: TextAlign.center),
          ]),
        ),
      )).toList(),
    );
  }
}
