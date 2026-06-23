import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';

class SurgeryDayScreen extends StatelessWidget {
  const SurgeryDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PhaseLayout(
      title: 'Surgery Day',
      subtitle: 'We are with you every step',
      iconEmoji: '🏥',
      heroBg: const Color(0xFFFFF0F0),
      mioVariant: MioVariant.calm,
      heroMsg: 'Today is the day.\nYou are in safe hands. 🤍',
      heroSub: 'Your surgical team is ready. Trust the process.',
      mottoMsg: 'Courage is moving forward despite fear. 💙',
      sideNav: const [
        SideNavItem('⏰', 'Surgery\nCountdown'),
        SideNavItem('🍽️', 'Fasting\nSchedule'),
        SideNavItem('👨‍👩‍👧', 'Family\nContact'),
        SideNavItem('🎙️', 'Voice\nMemo'),
        SideNavItem('🧘', 'Calm &\nBreathing'),
        SideNavItem('➡️', 'What\nHappens'),
        SideNavItem('💌', 'Personal\nMessage'),
        SideNavItem('📋', 'Reminders'),
      ],
      sections: Column(
        children: [
          // Countdown
          PhaseSection(
            title: '⏰ A. Surgery Countdown',
            background: const Color(0xFFFFF0F0),
            child: Column(
              children: [
                Text('Surgery begins in:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CountdownBox('02', 'Hours'),
                    _Colon(),
                    _CountdownBox('34', 'Minutes'),
                    _Colon(),
                    _CountdownBox('15', 'Seconds'),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Wednesday, 22 May 2024 · 07:00 AM', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
              ],
            ),
          ),

          PhaseSection(
            title: '🍽️ B. Fasting Schedule (ERAS)',
            child: Column(
              children: [
                _FastingRow('22 May, 10:00 PM', 'Last solid food', true),
                _FastingRow('23 May, 12:00 AM', 'Carbohydrate drink (last)', true),
                _FastingRow('23 May, 05:00 AM', 'Nothing by mouth from here', false),
                _FastingRow('23 May, 07:00 AM', 'Surgery begins', false),
              ],
            ),
          ),

          PhaseSection(
            title: '👨‍👩‍👧 C. Family Contact',
            background: const Color(0xFFF0FDF9),
            child: Column(
              children: const [
                PhaseActionRow(icon: '📞', label: 'Family waiting area: Level 2, Grey'),
                PhaseActionRow(icon: '📱', label: 'ICU family liaison: 0400 000 001'),
                PhaseActionRow(icon: '📋', label: 'Download family guide'),
              ],
            ),
          ),

          PhaseSection(
            title: '🎙️ D. Voice Memo to Family',
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _RecordBtn(Icons.fiber_manual_record, 'Record', AppColors.primary),
                      _RecordBtn(Icons.stop_circle, 'Stop', AppColors.textMedium),
                      _RecordBtn(Icons.play_circle, 'Play', AppColors.teal),
                      _RecordBtn(Icons.send, 'Send', AppColors.success),
                    ],
                  ),
                ),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(24)),
                  child: Text('Start Breathing Exercise', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
          ),

          PhaseSection(
            title: '➡️ F. What Happens Next',
            child: Column(
              children: [
                _WhatHappensRow('1', 'Pre-op preparation & IV line', '45 min'),
                _WhatHappensRow('2', 'Anaesthesia induction', '20 min'),
                _WhatHappensRow('3', 'Surgery (CABG)', '4-6 hrs'),
                _WhatHappensRow('4', 'Transfer to ICU', '1 hr'),
                _WhatHappensRow('5', 'ICU recovery & monitoring', '24-48 hrs'),
                _WhatHappensRow('6', 'Move to cardiac ward', 'Day 3'),
              ],
            ),
          ),

          PhaseSection(
            title: '💌 G. Personal Message',
            background: const Color(0xFFFFF0F0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"Dear Ahmet, you have come so far. Today you take the biggest step toward your healthy future. We are all here for you, cheering you on. You\'ve got this. 🤍"', style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textDark, height: 1.6)),
                const SizedBox(height: 8),
                Text('— Mio & Your Care Team', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),

          PhaseSection(
            title: '📋 H. Important Reminders',
            child: Column(
              children: [
                _CheckItem('Shower with antiseptic soap this morning'),
                _CheckItem('No jewellery, nail polish, or makeup'),
                _CheckItem('Bring ID and insurance card'),
                _CheckItem('Phone charged & given to family'),
                _CheckItem('Advance directive form signed'),
                _CheckItem('Anti-DVT stockings on'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  final String label;
  const _CountdownBox(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(value, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary))),
        ),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMedium)),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
    child: Text(':', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
  );
}

class _FastingRow extends StatelessWidget {
  final String time;
  final String label;
  final bool done;
  const _FastingRow(this.time, this.label, this.done);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.access_time_rounded, size: 16, color: done ? AppColors.success : AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(time, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _RecordBtn(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMedium)),
      ],
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal),
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

class _CheckItem extends StatelessWidget {
  final String label;
  const _CheckItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank, size: 18, color: AppColors.border),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark))),
        ],
      ),
    );
  }
}
