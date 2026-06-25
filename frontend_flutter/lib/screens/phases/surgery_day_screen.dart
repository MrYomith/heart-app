import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';
import '../breathing_screen.dart';
import '../messages_screen.dart';
import '../../widgets/stage_guides.dart';

void _push(BuildContext c, Widget s) => Navigator.push(c, MaterialPageRoute(builder: (_) => s));

class SurgeryDayScreen extends ConsumerWidget {
  const SurgeryDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final fasting = ref.watch(contentProvider((category: 'fasting_step', stage: 'surgery'))).valueOrNull ?? const [];
    final reminders = ref.watch(contentProvider((category: 'surgery_reminder', stage: 'surgery'))).valueOrNull ?? const [];
    final day = user?.dayPostOp;
    final daysUntil = day == null ? null : -day;
    final countdownLabel = daysUntil == null
        ? 'Your surgery date will appear here'
        : daysUntil > 0
            ? 'Surgery in $daysUntil ${daysUntil == 1 ? "day" : "days"}'
            : daysUntil == 0
                ? 'Today is the day'
                : 'Surgery completed';
    final surgeryType = user?.surgeryType?.toUpperCase() ?? 'your procedure';
    final firstName = user?.firstName ?? 'there';
    final surgeonMsg = (user?.surgeonMessage?.isNotEmpty ?? false)
        ? user!.surgeonMessage!
        : 'Dear $firstName, you have come so far. Today you take the biggest step toward your healthy future. We are all here for you. You\'ve got this. 🤍';

    return PhaseLayout(
      title: 'Surgery Day',
      subtitle: 'We are with you every step',
      iconEmoji: '🏥',
      heroBg: const Color(0xFFFFF0F0),
      mioVariant: MioVariant.calm,
      heroMsg: '${daysUntil == 0 ? "Today is the day." : "Almost there."}\nYou are in safe hands. 🤍',
      heroSub: 'Your surgical team is ready. Trust the process.',
      mottoMsg: 'Courage is moving forward despite fear. 💙',
      sideNav: const [
        SideNavItem('⏰', 'Surgery\nCountdown'),
        SideNavItem('🍽️', 'Fasting\nSchedule'),
        SideNavItem('👨‍👩‍👧', 'Family\nContact'),
        SideNavItem('🧘', 'Calm &\nBreathing'),
        SideNavItem('➡️', 'What\nHappens'),
        SideNavItem('💌', 'Personal\nMessage'),
        SideNavItem('📋', 'Reminders'),
      ],
      sections: Column(
        children: [
          const PhaseSection(
            title: '📚 Learn about this stage',
            subtitle: 'Tap any guide to read more',
            child: StageGuides(stage: 'surgery'),
          ),
          // Countdown — from the patient's real surgery date
          PhaseSection(
            title: '⏰ A. Surgery Countdown',
            background: const Color(0xFFFFF0F0),
            child: Column(
              children: [
                Text(countdownLabel, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                const SizedBox(height: 6),
                Text(user?.surgeryDate != null ? 'Surgery date: ${user!.surgeryDate}' : 'No surgery date set yet',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
              ],
            ),
          ),

          PhaseSection(
            title: '🍽️ B. Fasting Schedule (ERAS)',
            child: fasting.isEmpty
                ? Text('Your fasting schedule will be confirmed by your care team.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium))
                : Column(children: [
                    for (final f in fasting) _FastingRow((f['emoji'] as String?) ?? '🍽️', f['title'] as String? ?? ''),
                  ]),
          ),

          PhaseSection(
            title: '👨‍👩‍👧 C. Family & Care Team',
            background: const Color(0xFFF0FDF9),
            child: Column(
              children: [
                PhaseActionRow(icon: '💬', label: 'Message your care team', onTap: () => _push(context, const MessagesScreen())),
                if (user?.hospitalName != null) PhaseActionRow(icon: '🏥', label: user!.hospitalName!),
              ],
            ),
          ),

          PhaseSection(
            title: '🧘 E. Calm & Breathing',
            background: const Color(0xFFF8F6FF),
            child: Column(
              children: [
                const Text('🌬️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text('4-7-8 Breathing', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text('Inhale 4s → Hold 7s → Exhale 8s', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _push(context, const BreathingScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(24)),
                    child: Text('Start Breathing Exercise', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          PhaseSection(
            title: '➡️ F. What Happens Next',
            child: Column(
              children: [
                const _WhatHappensRow('1', 'Pre-op preparation & IV line', '45 min'),
                const _WhatHappensRow('2', 'Anaesthesia induction', '20 min'),
                _WhatHappensRow('3', 'Surgery ($surgeryType)', '—'),
                const _WhatHappensRow('4', 'Transfer to ICU', '1 hr'),
                const _WhatHappensRow('5', 'ICU recovery & monitoring', '24-48 hrs'),
                const _WhatHappensRow('6', 'Move to cardiac ward', 'Day 3'),
              ],
            ),
          ),

          PhaseSection(
            title: '💌 G. Personal Message',
            background: const Color(0xFFFFF0F0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"$surgeonMsg"', style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textDark, height: 1.6)),
                const SizedBox(height: 8),
                Text('— ${user?.surgeonName ?? "Your Care Team"}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),

          PhaseSection(
            title: '📋 H. Important Reminders',
            child: reminders.isEmpty
                ? Text('Your care team will add any surgery-day reminders here.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium))
                : Column(children: [for (final r in reminders) CheckRow(label: r['title'] as String? ?? '')]),
          ),
        ],
      ),
    );
  }
}

class _FastingRow extends StatelessWidget {
  final String emoji;
  final String label;
  const _FastingRow(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        ],
      ),
    );
  }
}

class _WhatHappensRow extends StatelessWidget {
  final String step;
  final String label;
  final String duration;
  const _WhatHappensRow(this.step, this.label, this.duration);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.teal),
            child: Center(child: Text(step, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark))),
          Text(duration, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.teal)),
        ],
      ),
    );
  }
}

