import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';

class DiagnosisScreen extends StatelessWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PhaseLayout(
      title: 'Diagnosis Phase',
      subtitle: 'Understanding your heart condition',
      iconEmoji: '🔍',
      heroBg: const Color(0xFFFFEDEB),
      mioVariant: MioVariant.calm,
      heroMsg: 'Mio is here with you through this.\nYou are not alone.',
      heroSub: 'This is the beginning of your healing journey.',
      mottoMsg: 'Knowledge is power. 💙',
      focusItems: const [
        FocusItem('📖', 'Read diagnosis'),
        FocusItem('💚', 'Check in emotionally'),
        FocusItem('💊', 'Review meds'),
      ],
      sideNav: const [
        SideNavItem('🫀', 'Understand\nCondition'),
        SideNavItem('💚', 'Emotional\nCheck-in'),
        SideNavItem('🧠', 'Psych\nSupport'),
        SideNavItem('💊', 'Medications'),
        SideNavItem('🥗', 'Nutrition'),
        SideNavItem('🏃', 'Physical\nActivity'),
        SideNavItem('🚭', 'Smoking &\nAlcohol'),
        SideNavItem('👨‍👩‍👧', 'Family &\nCaregiver'),
        SideNavItem('📅', 'Surgery\nTimeline'),
      ],
      sections: Column(
        children: [
          PhaseSection(
            title: '🫀 A. Understand Your Condition',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your diagnosis: Coronary Artery Disease (CAD)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 6),
                Text('Coronary artery disease occurs when the coronary arteries that supply blood to the heart become narrowed or blocked.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium, height: 1.5)),
                const SizedBox(height: 8),
                const PhaseActionRow(icon: '📄', label: 'View Your Full Diagnosis Report'),
                const PhaseActionRow(icon: '🎬', label: 'Watch: What is Open-Heart Surgery?'),
                const PhaseActionRow(icon: '❓', label: 'Ask Mio a Question'),
              ],
            ),
          ),

          PhaseSection(
            title: '💚 B. Emotional Check-In',
            subtitle: 'How are you feeling right now?',
            background: const Color(0xFFF0FDF4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['😢', '😟', '😐', '🙂', '😊'].map((e) => _EmojiBtn(emoji: e)).toList(),
                ),
                const SizedBox(height: 8),
                Text("It's okay to feel scared or uncertain. Your feelings are valid.", style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.teal, height: 1.5), textAlign: TextAlign.center),
              ],
            ),
          ),

          PhaseSection(
            title: '🧠 C. Psychological Support',
            child: Column(
              children: const [
                PhaseActionRow(icon: '💬', label: 'Chat with a Counsellor'),
                PhaseActionRow(icon: '📖', label: 'Anxiety Management Guide'),
                PhaseActionRow(icon: '🧘', label: 'Guided Breathing Exercise'),
              ],
            ),
          ),

          PhaseSection(
            title: '💊 D. Current Medications',
            child: Column(
              children: [
                _MedRow('Aspirin', '100mg', 'Once daily with food'),
                _MedRow('Metoprolol', '25mg', 'Twice daily'),
                _MedRow('Atorvastatin', '40mg', 'Once at night'),
                _MedRow('Ramipril', '5mg', 'Once daily'),
              ],
            ),
          ),

          PhaseSection(
            title: '🥗 E. Nutrition',
            subtitle: 'Heart-healthy diet to prepare for surgery',
            child: Column(
              children: const [
                PhaseActionRow(icon: '🍎', label: 'Heart-Healthy Meal Plan'),
                PhaseActionRow(icon: '🚫', label: 'Foods to Avoid'),
                PhaseActionRow(icon: '📊', label: 'Track Your Daily Intake'),
              ],
            ),
          ),

          PhaseSection(
            title: '🏃 F. Physical Activity',
            child: Column(
              children: [
                Text('Aim for 30 minutes of walking daily.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 6),
                const PhaseActionRow(icon: '🎯', label: 'Set Activity Goals'),
                const PhaseActionRow(icon: '📋', label: 'Safe Exercises for Heart Patients'),
              ],
            ),
          ),

          PhaseSection(
            title: '🚭 G. Smoking & Alcohol',
            background: const Color(0xFFFFF7ED),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stopping smoking reduces surgery risk by 40%.', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 6),
                const PhaseActionRow(icon: '🛑', label: 'Quit Smoking Support'),
                const PhaseActionRow(icon: '📞', label: 'Quitline: 137 848'),
              ],
            ),
          ),

          PhaseSection(
            title: '👨‍👩‍👧 H. Family & Caregiver',
            child: Column(
              children: const [
                PhaseActionRow(icon: '📋', label: 'Caregiver Guide'),
                PhaseActionRow(icon: '📞', label: 'Family Communication Tips'),
                PhaseActionRow(icon: '❤️', label: 'Invite a Family Member'),
              ],
            ),
          ),

          PhaseSection(
            title: '📅 I. Surgery Timeline',
            child: Column(
              children: [
                _TimelineRow('Today', 'Diagnosis confirmed', true),
                _TimelineRow('Week 2', 'Pre-op assessments', false),
                _TimelineRow('Week 4', 'Surgery Day', false),
                _TimelineRow('Week 5-8', 'Hospital recovery', false),
                _TimelineRow('Months 3-6', 'Cardiac rehabilitation', false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiBtn extends StatelessWidget {
  final String emoji;
  const _EmojiBtn({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
      ),
    );
  }
}

class _MedRow extends StatelessWidget {
  final String name;
  final String dose;
  final String schedule;
  const _MedRow(this.name, this.dose, this.schedule);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          const Text('💊', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name $dose', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(schedule, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String time;
  final String label;
  final bool done;
  const _TimelineRow(this.time, this.label, this.done);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: done ? AppColors.success : AppColors.border),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 60, child: Text(time, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMedium))),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark))),
        ],
      ),
    );
  }
}
