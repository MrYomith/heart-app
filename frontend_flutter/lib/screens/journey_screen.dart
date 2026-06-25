import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/journey_phase.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_providers.dart';
import '../utils/responsive.dart';
import '../widgets/mio_mascot.dart';
import 'phases/diagnosis_screen.dart';
import 'phases/preop_screen.dart';
import 'phases/surgery_day_screen.dart';
import 'phases/inpatient_recovery_screen.dart';
import 'phases/post_discharge_rehab_screen.dart';
import 'phases/thriving_screen.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  Widget? _dest(String key) {
    switch (key) {
      case 'diagnosis': return const DiagnosisScreen();
      case 'preop':     return const PreopScreen();
      case 'surgery':   return const SurgeryDayScreen();
      case 'inpatient': return const InpatientRecoveryScreen();
      case 'rehab':     return const PostDischargeRehabScreen();
      case 'thriving':  return const ThrivingScreen();
      default: return null;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed': return AppColors.success;
      case 'active':    return AppColors.primary;
      default:          return AppColors.border;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'completed': return 'Completed';
      case 'active':    return 'In Progress';
      default:          return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = Responsive.hp(context);
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
    final fs = Responsive.fontScale(context);
    final user = ref.watch(authControllerProvider).user;
    final journeyAsync = ref.watch(journeyProvider);
    // Blend phase milestone with today's task completion (mirrors the home ring).
    final base = (user?.journeyProgress ?? 0).toDouble();
    final tasks = ref.watch(todayTasksProvider).valueOrNull ?? const [];
    final total = tasks.length;
    final doneToday = tasks.where((t) => t.done == true).length;
    final step = (user?.nextPhaseLabel ?? '').isNotEmpty ? 20.0 : 0.0;
    final frac = total > 0 ? doneToday / total : 0.0;
    final progress = (base + step * frac * 0.9).round().clamp(0, 100);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Heart Surgery Journey', style: GoogleFonts.inter(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text('Your recovery roadmap', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress banner
          Container(
            color: AppColors.bgBanner,
            padding: EdgeInsets.symmetric(horizontal: pad, vertical: 14),
            child: Row(
              children: [
                MioMascot(variant: MioVariant.calm, size: isWide ? 72.0 : 60.0),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your Journey Progress', style: GoogleFonts.inter(fontSize: 15 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: AppColors.border,
                        color: AppColors.teal,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('$progress% complete — ${user?.phaseLabel ?? ''}', style: GoogleFonts.inter(fontSize: 11 * fs, color: AppColors.textMedium)),
                  ]),
                ),
              ],
            ),
          ),

          // Phase list — single column on phone, 2-column grid on tablet
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
                child: journeyAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.teal)),
                  error: (e, _) => Center(child: Text("Couldn't load your journey", style: GoogleFonts.inter(color: AppColors.textMedium))),
                  data: (phases) => isWide
                      ? _buildGridList(context, phases, pad, fs)
                      : _buildTimelineList(context, phases, pad, fs),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Phone: vertical timeline ─────────────────────────────
  Widget _buildTimelineList(BuildContext context, List<JourneyPhase> phases, double pad, double fs) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(pad, 14, pad, 16),
      itemCount: phases.length,
      itemBuilder: (context, i) {
        final phase = phases[i];
        final dest = _dest(phase.id);
        final isLast = i == phases.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimelineColumn(phase: phase, isLast: isLast, statusColor: _statusColor(phase.status)),
              const SizedBox(width: 10),
              Expanded(child: _PhaseCard(phase: phase, dest: dest, statusColor: _statusColor(phase.status), statusLabel: _statusLabel(phase.status), fs: fs)),
            ],
          ),
        );
      },
    );
  }

  // ── Tablet: 2-column card grid ───────────────────────────
  Widget _buildGridList(BuildContext context, List<JourneyPhase> phases, double pad, double fs) {
    final cols = Responsive.isLarge(context) ? 3 : 2;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(pad, 16, pad, 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemCount: phases.length,
      itemBuilder: (context, i) {
        final phase = phases[i];
        final dest = _dest(phase.id);
        return _PhaseCardGrid(phase: phase, dest: dest, statusColor: _statusColor(phase.status), statusLabel: _statusLabel(phase.status), fs: fs);
      },
    );
  }
}

class _TimelineColumn extends StatelessWidget {
  final dynamic phase;
  final bool isLast;
  final Color statusColor;
  const _TimelineColumn({required this.phase, required this.isLast, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor.withValues(alpha: 0.15), border: Border.all(color: statusColor, width: 2)),
          child: Center(child: Text(phase.emoji, style: const TextStyle(fontSize: 16))),
        ),
        if (!isLast)
          Expanded(child: Container(width: 2, color: phase.status == 'completed' ? AppColors.success.withValues(alpha: 0.4) : AppColors.border)),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final dynamic phase;
  final Widget? dest;
  final Color statusColor;
  final String statusLabel;
  final double fs;
  const _PhaseCard({required this.phase, required this.dest, required this.statusColor, required this.statusLabel, required this.fs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dest != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => dest!)) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: phase.status == 'active' ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: _PhaseCardContent(phase: phase, dest: dest, statusColor: statusColor, statusLabel: statusLabel, fs: fs),
      ),
    );
  }
}

class _PhaseCardGrid extends StatelessWidget {
  final dynamic phase;
  final Widget? dest;
  final Color statusColor;
  final String statusLabel;
  final double fs;
  const _PhaseCardGrid({required this.phase, required this.dest, required this.statusColor, required this.statusLabel, required this.fs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dest != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => dest!)) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: phase.status == 'active' ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2) : Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(phase.emoji, style: const TextStyle(fontSize: 28)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(statusLabel, style: GoogleFonts.inter(fontSize: 10 * fs, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(phase.label, style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            if (phase.subtitle != null) Text(phase.subtitle!, style: GoogleFonts.inter(fontSize: 11 * fs, color: AppColors.textMedium)),
            if (phase.date != null) Text(phase.date!, style: GoogleFonts.inter(fontSize: 10 * fs, color: AppColors.textLight)),
            const Spacer(),
            if (phase.mioMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.bgTeal, borderRadius: BorderRadius.circular(8)),
                child: Text(phase.mioMessage, style: GoogleFonts.inter(fontSize: 10 * fs, fontStyle: FontStyle.italic, color: AppColors.teal), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            if (dest != null) ...[
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('Open →', style: GoogleFonts.inter(fontSize: 11 * fs, fontWeight: FontWeight.w700, color: AppColors.teal)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhaseCardContent extends StatelessWidget {
  final dynamic phase;
  final Widget? dest;
  final Color statusColor;
  final String statusLabel;
  final double fs;
  const _PhaseCardContent({required this.phase, required this.dest, required this.statusColor, required this.statusLabel, required this.fs});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(phase.label, style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(statusLabel, style: GoogleFonts.inter(fontSize: 10 * fs, fontWeight: FontWeight.w700, color: statusColor)),
        ),
      ]),
      const SizedBox(height: 4),
      if (phase.subtitle != null) Text(phase.subtitle!, style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
      if (phase.date != null) Text(phase.date!, style: GoogleFonts.inter(fontSize: 11 * fs, color: AppColors.textLight)),
      if (phase.mioMessage.isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.bgTeal, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            const Text('🫀', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(child: Text(phase.mioMessage, style: GoogleFonts.inter(fontSize: 11 * fs, fontStyle: FontStyle.italic, color: AppColors.teal))),
          ]),
        ),
      ],
      if (dest != null) ...[
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('Open phase', style: GoogleFonts.inter(fontSize: 11 * fs, fontWeight: FontWeight.w700, color: AppColors.teal)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.teal),
        ]),
      ],
    ]);
  }
}
