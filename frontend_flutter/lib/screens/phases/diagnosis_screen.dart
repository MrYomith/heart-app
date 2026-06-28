import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/mood_checkin.dart';
import '../../widgets/phase_layout.dart';
import '../../widgets/stage_guides.dart';
import '../learn_screen.dart';
import '../messages_screen.dart';
import '../breathing_screen.dart';
import '../food_ai_screen.dart';
import '../habits_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_providers.dart';

void _push(BuildContext c, Widget s) => Navigator.push(c, MaterialPageRoute(builder: (_) => s));

class DiagnosisScreen extends ConsumerWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final diagnosis = (user?.diagnosis?.isNotEmpty ?? false) ? user!.diagnosis! : 'Your care team will confirm your diagnosis here';
    return PhaseLayout(
      title: 'Diagnosis Phase',
      subtitle: 'Understanding your heart condition',
      iconEmoji: '🔍',
      heroBg: const Color(0xFFFFEDEB),
      mioVariant: MioVariant.defaultMio,
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
          const PhaseSection(
            title: '📚 Learn about this stage',
            subtitle: 'Tap any guide to read more',
            child: StageGuides(stage: 'diagnosis'),
          ),
          PhaseSection(
            title: '🫀 A. Understand Your Condition',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your diagnosis: $diagnosis', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 6),
                Text('Your surgeon will walk you through what this means for you. Tap below to learn more or ask a question.', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium, height: 1.5)),
                const SizedBox(height: 8),
                PhaseActionRow(icon: '📄', label: 'View Your Full Diagnosis Report', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '🎬', label: 'Watch: What is Open-Heart Surgery?', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '❓', label: 'Ask Mio a Question', onTap: () => _push(context, const MessagesScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '💚 B. Emotional Check-In',
            subtitle: 'How are you feeling right now?',
            background: const Color(0xFFF0FDF4),
            child: Column(
              children: [
                const MoodCheckIn(),
                const SizedBox(height: 8),
                Text("It's okay to feel scared or uncertain. Your feelings are valid.", style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.teal, height: 1.5), textAlign: TextAlign.center),
              ],
            ),
          ),

          PhaseSection(
            title: '🧠 C. Psychological Support',
            child: Column(
              children: [
                PhaseActionRow(icon: '💬', label: 'Chat with a Counsellor', onTap: () => _push(context, const MessagesScreen())),
                PhaseActionRow(icon: '📖', label: 'Anxiety Management Guide', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '🧘', label: 'Guided Breathing Exercise', onTap: () => _push(context, const BreathingScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '💊 D. Current Medications',
            child: Column(
              children: [
                ref.watch(medicationsProvider).when(
                  loading: () => const Padding(padding: EdgeInsets.all(8), child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => Text('Could not load medications.', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
                  data: (meds) => meds.isEmpty
                      ? Text('No medications recorded yet — your care team will add them.', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium))
                      : Column(children: [for (final m in meds) _MedRow(m.name, m.dose, m.schedule)]),
                ),
              ],
            ),
          ),

          PhaseSection(
            title: '🥗 E. Nutrition',
            subtitle: 'Heart-healthy diet to prepare for surgery',
            child: Column(
              children: [
                PhaseActionRow(icon: '🍎', label: 'Heart-Healthy Meal Plan', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '🚫', label: 'Foods to Avoid', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '📊', label: 'Track Your Daily Intake', onTap: () => _push(context, const FoodAiScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🏃 F. Physical Activity',
            child: Column(
              children: [
                Text('Aim for 30 minutes of walking daily.', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 6),
                PhaseActionRow(icon: '🎯', label: 'Set Activity Goals', onTap: () => _push(context, const HabitsScreen())),
                PhaseActionRow(icon: '📋', label: 'Safe Exercises for Heart Patients', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🚭 G. Smoking & Alcohol',
            background: const Color(0xFFFFF7ED),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stopping smoking reduces surgery risk by 40%.', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 6),
                PhaseActionRow(icon: '🛑', label: 'Quit Smoking Support', onTap: () => _push(context, const HabitsScreen())),
                const PhaseActionRow(icon: '📞', label: 'Quitline: 137 848'),
              ],
            ),
          ),

          PhaseSection(
            title: '👨‍👩‍👧 H. Family & Caregiver',
            child: Column(
              children: [
                PhaseActionRow(icon: '📋', label: 'Caregiver Guide', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '📞', label: 'Family Communication Tips', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '❤️', label: 'Invite a Family Member', onTap: () => _push(context, const MessagesScreen())),
              ],
            ),
          ),

          const PhaseSection(
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

class _MedRow extends StatelessWidget {
  final String name;
  final String dose;
  final String schedule;
  const _MedRow(this.name, this.dose, this.schedule);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          const Text('💊', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name $dose', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(schedule, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMedium)),
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
          SizedBox(width: 60, child: Text(time, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMedium))),
          Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark))),
        ],
      ),
    );
  }
}
