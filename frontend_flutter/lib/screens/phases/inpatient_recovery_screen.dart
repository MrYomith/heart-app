import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/mood_checkin.dart';
import '../../widgets/phase_layout.dart';
import '../pain_tracking_screen.dart';
import '../breathing_screen.dart';
import '../delirium_screen.dart';
import '../nutrition_screen.dart';
import '../emotional_checkin_screen.dart';
import '../mobilisation_screen.dart';
import '../wound_screen.dart';
import '../learn_screen.dart';
import '../../widgets/stage_guides.dart';

void _go(BuildContext context, Widget screen) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

class InpatientRecoveryScreen extends ConsumerStatefulWidget {
  const InpatientRecoveryScreen({super.key});

  @override
  ConsumerState<InpatientRecoveryScreen> createState() => _InpatientRecoveryScreenState();
}

class _InpatientRecoveryScreenState extends ConsumerState<InpatientRecoveryScreen> {
  double _painLevel = 3;

  Future<void> _logBreathing(bool done) async {
    if (!done) return; // checking off records a completed session
    await ref.read(patientRepositoryProvider).logBreathing(type: 'breathing');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Breathing session logged 🫁'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(authControllerProvider).user?.dayPostOp;
    final dayLabel = (day == null || day < 0) ? 'Recovering in hospital' : 'Day $day post-surgery';
    return PhaseLayout(
      title: 'Inpatient Recovery',
      subtitle: 'Hospital recovery — days 1 to 7',
      iconEmoji: '🛏️',
      heroBg: const Color(0xFFF0FDF9),
      mioVariant: MioVariant.calm,
      heroMsg: 'Surgery is done. You did it!\nNow let your body heal. 🌿',
      heroSub: '$dayLabel · ICU → Cardiac Ward',
      mottoMsg: 'Rest is recovery. 💚',
      focusItems: const [
        FocusItem('😌', 'Log your pain'),
        FocusItem('🫁', 'Breathing ex'),
        FocusItem('🚶', 'First steps'),
      ],
      sideNav: const [
        SideNavItem('😣', 'Pain\nTracking'),
        SideNavItem('🫁', 'Breathing\nExercise'),
        SideNavItem('🚶', 'Mobilisation'),
        SideNavItem('🧠', 'Delirium\nCheck'),
        SideNavItem('🩹', 'Wound\nCare'),
        SideNavItem('💚', 'Emotional'),
        SideNavItem('🧘', 'Meditation'),
        SideNavItem('🥣', 'Nutrition'),
        SideNavItem('🎓', 'ICU\nEducation'),
      ],
      sections: _buildSections(context),
    );
  }

  Widget _buildSections(BuildContext context) {
    return Column(
      children: [
        const PhaseSection(
          title: '📚 Learn about this stage',
          subtitle: 'Tap any guide to read more',
          child: StageGuides(stage: 'inpatient'),
        ),
        // Pain tracking
        PhaseSection(
          title: '😣 A. Pain Tracking',
          subtitle: 'Rate your pain right now',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(11, (i) => Text('$i', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textLight))),
              ),
              SliderTheme(
                data: const SliderThemeData(thumbColor: AppColors.primary, activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.border, trackHeight: 4),
                child: Slider(value: _painLevel, min: 0, max: 10, divisions: 10, onChanged: (v) => setState(() => _painLevel = v)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_painLevel.toInt()}/10 pain', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  GestureDetector(
                    onTap: () => _go(context, const PainTrackingScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                      child: Text('Log Pain', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Tap below to log your pain — your nurse is alerted if it is 7 or higher.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
            ],
          ),
        ),

        // Breathing exercises
        PhaseSection(
          title: '🫁 B. Breathing Exercises',
          background: const Color(0xFFF0FDF9),
          child: Column(
            children: [
              CheckRow(label: 'Spirometer practice', sublabel: '10 reps × 3 sets', onChanged: _logBreathing),
              CheckRow(label: 'Deep breathing', sublabel: '5 min × 4 times/day', onChanged: _logBreathing),
              CheckRow(label: 'Cough assist technique', sublabel: 'As needed', onChanged: _logBreathing),
              PhaseActionRow(icon: '🫁', label: 'Open guided breathing coach', onTap: () => _go(context, const BreathingScreen())),
            ],
          ),
        ),

        // Mobilisation
        PhaseSection(
          title: '🚶 C. Mobilisation',
          child: Column(
            children: [
              const _MobiRow('Day 1', 'Sit on edge of bed', false),
              const _MobiRow('Day 2', 'Stand & walk in room', false),
              const _MobiRow('Day 3', 'Walk in corridor', false),
              const _MobiRow('Day 5', 'Walk 2× daily (50m)', false),
              const _MobiRow('Day 7', 'Stair practice before discharge', false),
              PhaseActionRow(icon: '🚶', label: 'Track my mobilisation milestones', onTap: () => _go(context, const MobilisationScreen())),
            ],
          ),
        ),

        // Delirium monitoring
        PhaseSection(
          title: '🧠 D. Delirium Monitoring',
          background: const Color(0xFFFFF7ED),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Complete your daily check to screen for confusion.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
              const SizedBox(height: 6),
              Text('No delirium signs detected.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
              const SizedBox(height: 6),
              PhaseActionRow(icon: '📋', label: 'Start Orientation Check', onTap: () => _go(context, const DeliriumScreen())),
              PhaseActionRow(icon: '🔔', label: 'Report Confusion to Nurse', onTap: () => _go(context, const DeliriumScreen())),
            ],
          ),
        ),

        // Wound care
        PhaseSection(
          title: '🩹 E. Wound Care',
          child: Column(
            children: [
              PhaseActionRow(icon: '📷', label: 'Open wound photo log', onTap: () => _go(context, const WoundScreen())),
              PhaseActionRow(icon: '⚠️', label: 'Warning signs to report', onTap: () => _go(context, const LearnScreen())),
              PhaseActionRow(icon: '🚿', label: 'Showering instructions', onTap: () => _go(context, const LearnScreen())),
            ],
          ),
        ),

        // Emotional wellbeing
        PhaseSection(
          title: '💚 F. Emotional Wellbeing',
          subtitle: 'How are you feeling right now?',
          background: const Color(0xFFF0FDF4),
          child: Column(
            children: [
              const MoodCheckIn(),
              const SizedBox(height: 8),
              Text("Post-cardiac surgery blues are normal. You're not alone.", style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.teal, height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              PhaseActionRow(icon: '💚', label: 'Open full mood check-in', onTap: () => _go(context, const EmotionalCheckinScreen())),
            ],
          ),
        ),

        // Meditation
        PhaseSection(
          title: '🧘 G. Meditation & Relaxation',
          child: Column(
            children: [
              PhaseActionRow(icon: '🎧', label: 'Body Scan Meditation (10 min)', onTap: () => _go(context, const BreathingScreen())),
              PhaseActionRow(icon: '🌊', label: 'Ocean Sounds Sleep Aid', onTap: () => _go(context, const BreathingScreen())),
              PhaseActionRow(icon: '🧘', label: 'Mindful Breathing (5 min)', onTap: () => _go(context, const BreathingScreen())),
            ],
          ),
        ),

        // Nutrition
        PhaseSection(
          title: '🥣 H. Nutrition',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Follow the diet your care team has set for this stage of recovery.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
              const SizedBox(height: 6),
              PhaseActionRow(icon: '🥣', label: 'Log nutrition (protein, fluids, meals)', onTap: () => _go(context, const NutritionScreen())),
              PhaseActionRow(icon: '📞', label: 'Speak with dietitian', onTap: () => _go(context, const NutritionScreen())),
            ],
          ),
        ),

        // ICU education
        PhaseSection(
          title: '🎓 I. ICU Education',
          background: const Color(0xFFF0FDF9),
          child: Column(
            children: [
              PhaseActionRow(icon: '📺', label: 'Understanding your ICU equipment', onTap: () => _go(context, const LearnScreen())),
              PhaseActionRow(icon: '📖', label: 'ICU Recovery Guide (PDF)', onTap: () => _go(context, const LearnScreen())),
              PhaseActionRow(icon: '❓', label: 'Common ICU FAQs', onTap: () => _go(context, const LearnScreen())),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobiRow extends StatelessWidget {
  final String day;
  final String label;
  final bool done;
  const _MobiRow(this.day, this.label, this.done);

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
          SizedBox(width: 44, child: Text(day, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMedium))),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark))),
          if (done) const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
        ],
      ),
    );
  }
}
