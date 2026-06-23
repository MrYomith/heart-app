import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';

class PostDischargeRehabScreen extends StatelessWidget {
  const PostDischargeRehabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PhaseLayout(
      title: 'Post-Discharge Rehab',
      subtitle: 'Home recovery & cardiac rehabilitation',
      iconEmoji: '🏠',
      heroBg: const Color(0xFFF0FDF9),
      mioVariant: MioVariant.happy,
      heroMsg: "You're home! This is where\nyour real recovery begins. 🌟",
      heroSub: 'Week 2 post-surgery · Home Recovery',
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
          PhaseSection(
            title: '🏥 A. Cardiac Rehab Centre',
            child: Column(
              children: [
                _InfoRow('Centre', 'St. George Cardiac Rehab'),
                _InfoRow('Address', '123 Health St, Kogarah'),
                _InfoRow('Schedule', 'Mon/Wed/Fri 9:00–11:00 AM'),
                _InfoRow('Next session', 'Monday, 3 June 2024'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _ActionBtn('Get Directions', AppColors.teal)),
                    const SizedBox(width: 8),
                    Expanded(child: _ActionBtn('Call Centre', AppColors.primary)),
                  ],
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
                _RuleRow('✅', 'Use pillow when coughing or sneezing'),
                _RuleRow('✅', 'Let others carry heavy items (>2kg)'),
                _RuleRow('❌', 'Do NOT push/pull with arms'),
                _RuleRow('❌', 'Do NOT drive for 4–6 weeks'),
                _RuleRow('❌', 'Do NOT lift arms above shoulders'),
                const SizedBox(height: 6),
                const PhaseActionRow(icon: '📺', label: 'Watch: Sternal Precautions Video'),
              ],
            ),
          ),

          PhaseSection(
            title: '🏠 C. Home Recovery Guide',
            child: Column(
              children: const [
                PhaseActionRow(icon: '🛀', label: 'Showering & wound care at home'),
                PhaseActionRow(icon: '😴', label: 'Sleep positions for comfort'),
                PhaseActionRow(icon: '🚗', label: 'When you can resume driving'),
                PhaseActionRow(icon: '✈️', label: 'Travel restrictions & clearance'),
                PhaseActionRow(icon: '📞', label: 'When to call your doctor'),
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
                    Expanded(child: _CounterCard('🚭', 'Smoke Free', '36 Days', AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _CounterCard('🍷', 'Alcohol Free', '36 Days', AppColors.teal)),
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
                const PhaseActionRow(icon: '📄', label: 'Download: Intimacy After Heart Surgery'),
              ],
            ),
          ),

          PhaseSection(
            title: '💊 F. Medications at Home',
            child: Column(
              children: [
                _MedRow('Aspirin', '100mg', 'Daily', '🌅'),
                _MedRow('Metoprolol', '25mg', 'Twice daily', '🕗'),
                _MedRow('Atorvastatin', '40mg', 'Nightly', '🌙'),
                _MedRow('Ramipril', '5mg', 'Morning', '🌅'),
                const SizedBox(height: 8),
                const PhaseActionRow(icon: '🔔', label: 'Set Medication Reminders'),
              ],
            ),
          ),

          PhaseSection(
            title: '💼 G. Return to Work',
            child: Column(
              children: [
                _InfoRow('Desk job', '4–6 weeks'),
                _InfoRow('Light physical', '6–8 weeks'),
                _InfoRow('Heavy physical', '3–6 months'),
                const SizedBox(height: 6),
                const PhaseActionRow(icon: '📄', label: 'Medical Certificate Request'),
                const PhaseActionRow(icon: '👔', label: 'Graduated Return-to-Work Plan'),
              ],
            ),
          ),

          PhaseSection(
            title: '💚 H. Emotional Support',
            background: const Color(0xFFF0FDF4),
            child: Column(
              children: const [
                PhaseActionRow(icon: '🧠', label: 'Post-cardiac depression screening'),
                PhaseActionRow(icon: '💬', label: 'Chat with psychologist'),
                PhaseActionRow(icon: '📞', label: 'Lifeline: 13 11 14'),
              ],
            ),
          ),

          PhaseSection(
            title: '👥 I. Patient Community',
            child: Column(
              children: const [
                PhaseActionRow(icon: '💬', label: 'Join Heart Recovery Forum'),
                PhaseActionRow(icon: '📅', label: 'Local cardiac support group'),
                PhaseActionRow(icon: '🤝', label: 'Connect with a recovery buddy'),
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
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
