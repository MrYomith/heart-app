import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';
import '../../widgets/stage_guides.dart';
import '../return_to_work_screen.dart';
import '../screening_screen.dart';
import '../medications_screen.dart';
import '../messages_screen.dart';
import '../learn_screen.dart';

void _push(BuildContext c, Widget s) => Navigator.push(c, MaterialPageRoute(builder: (_) => s));

class PostDischargeRehabScreen extends ConsumerWidget {
  const PostDischargeRehabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final cessation = ref.watch(cessationProvider).valueOrNull ?? const [];
    final meds = ref.watch(medicationsProvider).valueOrNull ?? const [];
    int streak(String type) {
      final c = cessation.cast<Map<String, dynamic>?>().firstWhere(
          (e) => e?['type'] == type, orElse: () => null);
      return (c?['current_streak_days'] as num?)?.toInt() ?? 0;
    }
    final day = user?.dayPostOp;
    final weekLabel = (day == null || day < 0) ? 'Home Recovery' : 'Day $day · Home Recovery';
    return PhaseLayout(
      title: 'Post-Discharge Rehab',
      subtitle: 'Home recovery & cardiac rehabilitation',
      iconEmoji: '🏠',
      heroBg: const Color(0xFFF0FDF9),
      mioVariant: MioVariant.happy,
      heroMsg: "You're home! This is where\nyour real recovery begins. 🌟",
      heroSub: weekLabel,
      mottoMsg: 'Every day you get a little stronger. 💚',
      focusItems: const [
        FocusItem('🛡️', 'Sternal care'),
        FocusItem('🚶', 'Daily walk'),
        FocusItem('💊', 'Take meds'),
      ],
      sideNav: const [
        SideNavItem('🏥', 'Rehab\nCentre'),
        SideNavItem('🛡️', 'Sternal\nProtect.'),
        SideNavItem('🏠', 'Home\nRecovery'),
        SideNavItem('🚭', 'Smoking &\nAlcohol'),
        SideNavItem('❤️', 'Sexual\nHealth'),
        SideNavItem('💊', 'Medications'),
        SideNavItem('💼', 'Return to\nWork'),
        SideNavItem('💚', 'Emotional'),
        SideNavItem('👥', 'Community'),
      ],
      sections: Column(
        children: [
          const PhaseSection(
            title: '📚 Learn about this stage',
            subtitle: 'Tap any guide to read more',
            child: StageGuides(stage: 'rehab'),
          ),
          PhaseSection(
            title: '🏥 A. Cardiac Rehab Centre',
            child: Column(
              children: [
                _InfoRow('Centre', user?.hospitalName ?? 'To be confirmed'),
                const _InfoRow('Programme', 'Anschlussheilbehandlung (AHB)'),
                const _InfoRow('Schedule', 'Your centre will confirm your sessions'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _push(context, const MessagesScreen()),
                  child: const _ActionBtn('Contact rehab team', AppColors.teal),
                ),
              ],
            ),
          ),

          PhaseSection(
            title: '🛡️ B. Sternal Protection',
            background: const Color(0xFFFFF7ED),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your sternum takes 6–12 weeks to heal.', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 6),
                const _RuleRow('✅', 'Use pillow when coughing or sneezing'),
                const _RuleRow('✅', 'Let others carry heavy items (>2kg)'),
                const _RuleRow('❌', 'Do NOT push/pull with arms'),
                const _RuleRow('❌', 'Do NOT drive for 4–6 weeks'),
                const _RuleRow('❌', 'Do NOT lift arms above shoulders'),
                const SizedBox(height: 6),
                PhaseActionRow(icon: '📺', label: 'Watch: Sternal Precautions Video', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🏠 C. Home Recovery Guide',
            child: Column(
              children: [
                PhaseActionRow(icon: '🛀', label: 'Showering & wound care at home', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '😴', label: 'Sleep positions for comfort', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '🚗', label: 'When you can resume driving', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '✈️', label: 'Travel restrictions & clearance', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '📞', label: 'When to call your doctor', onTap: () => _push(context, const MessagesScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🚭 D. Smoking & Alcohol (Day Counter)',
            background: const Color(0xFFF0FDF4),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _CounterCard('🚭', 'Smoke Free', '${streak('smoking')} Days', AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _CounterCard('🍷', 'Alcohol Free', '${streak('alcohol')} Days', AppColors.teal)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Every smoke-free day reduces your re-event risk.', style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.teal), textAlign: TextAlign.center),
              ],
            ),
          ),

          PhaseSection(
            title: '❤️ E. Sexual Health',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('When can I resume sexual activity?', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text('Most patients can resume at 4–6 weeks when they can walk briskly up two flights of stairs without chest pain or shortness of breath.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium, height: 1.5)),
                const SizedBox(height: 6),
                PhaseActionRow(icon: '📄', label: 'Download: Intimacy After Heart Surgery', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '💊 F. Medications at Home',
            child: Column(
              children: [
                if (meds.isEmpty)
                  Text('Your discharge medications will appear here once your care team adds them.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium))
                else
                  for (final m in meds)
                    _MedRow(m.name, m.dose, m.schedule, m.isAnticoagulant ? '⚠️' : '💊'),
                const SizedBox(height: 8),
                PhaseActionRow(icon: '🔔', label: 'Set Medication Reminders', onTap: () => _push(context, const MedicationsScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '💼 G. Return to Work',
            child: Column(
              children: [
                const _InfoRow('Desk job', '4–6 weeks'),
                const _InfoRow('Light physical', '6–8 weeks'),
                const _InfoRow('Heavy physical', '3–6 months'),
                const SizedBox(height: 6),
                PhaseActionRow(icon: '📄', label: 'Medical Certificate Request', onTap: () => _push(context, const MessagesScreen())),
                PhaseActionRow(icon: '👔', label: 'Graduated Return-to-Work Plan', onTap: () => _push(context, const ReturnToWorkScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '💚 H. Emotional Support',
            background: const Color(0xFFF0FDF4),
            child: Column(
              children: [
                PhaseActionRow(icon: '🧠', label: 'Post-cardiac depression screening', onTap: () => _push(context, const ScreeningScreen(type: 'phq9'))),
                PhaseActionRow(icon: '💬', label: 'Chat with psychologist', onTap: () => _push(context, const MessagesScreen())),
                const PhaseActionRow(icon: '📞', label: 'Lifeline: 13 11 14'),
              ],
            ),
          ),

          PhaseSection(
            title: '👥 I. Patient Community',
            child: Column(
              children: [
                PhaseActionRow(icon: '💬', label: 'Join Heart Recovery Forum', onTap: () => _push(context, const MessagesScreen())),
                PhaseActionRow(icon: '📅', label: 'Local cardiac support group', onTap: () => _push(context, const MessagesScreen())),
                PhaseActionRow(icon: '🤝', label: 'Connect with a recovery buddy', onTap: () => _push(context, const MessagesScreen())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium))),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  const _ActionBtn(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String icon;
  final String label;
  const _RuleRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark))),
        ],
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _CounterCard(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMedium)),
        ],
      ),
    );
  }
}

class _MedRow extends StatelessWidget {
  final String name;
  final String dose;
  final String schedule;
  final String timeIcon;
  const _MedRow(this.name, this.dose, this.schedule, this.timeIcon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Text(timeIcon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name $dose', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(schedule, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMedium)),
              ],
            ),
          ),
          const Icon(Icons.notifications_outlined, size: 16, color: AppColors.teal),
        ],
      ),
    );
  }
}
