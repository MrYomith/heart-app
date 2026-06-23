import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';

class InpatientRecoveryScreen extends StatefulWidget {
  const InpatientRecoveryScreen({super.key});

  @override
  State<InpatientRecoveryScreen> createState() => _InpatientRecoveryScreenState();
}

class _InpatientRecoveryScreenState extends State<InpatientRecoveryScreen> {
  double _painLevel = 3;
  String _emotionEmoji = '😐';

  @override
  Widget build(BuildContext context) {
    return PhaseLayout(
      title: 'Inpatient Recovery',
      subtitle: 'Hospital recovery — days 1 to 7',
      iconEmoji: '🛏️',
      heroBg: const Color(0xFFF0FDF9),
      mioVariant: MioVariant.calm,
      heroMsg: 'Surgery is done. You did it!\nNow let your body heal. 🌿',
      heroSub: 'Day 2 post-surgery · ICU → Cardiac Ward',
      mottoMsg: 'Rest is recovery. 💚',
      focusItems: const [
        FocusItem('😌', 'Pain: 3/10'),
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
                data: SliderThemeData(thumbColor: AppColors.primary, activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.border, trackHeight: 4),
                child: Slider(value: _painLevel, min: 0, max: 10, divisions: 10, onChanged: (v) => setState(() => _painLevel = v)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_painLevel.toInt()}/10 pain', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: Text('Log Pain', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Last medication: Morphine 4mg at 08:00', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
            ],
          ),
        ),

        // Breathing exercises
        PhaseSection(
          title: '🫁 B. Breathing Exercises',
          background: const Color(0xFFF0FDF9),
          child: Column(
            children: [
              _BreathingItem('Spirometer practice', '10 reps × 3 sets', false),
              _BreathingItem('Deep breathing', '5 min × 4 times/day', true),
              _BreathingItem('Cough assist technique', 'As needed', true),
            ],
          ),
        ),

        // Mobilisation
        PhaseSection(
          title: '🚶 C. Mobilisation',
          child: Column(
            children: [
              _MobiRow('Day 1', 'Sit on edge of bed', true),
              _MobiRow('Day 2', 'Stand & walk in room', true),
              _MobiRow('Day 3', 'Walk in corridor', false),
              _MobiRow('Day 5', 'Walk 2× daily (50m)', false),
              _MobiRow('Day 7', 'Stair practice before discharge', false),
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
              Text('CAM-ICU Score: Negative ✅', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
              const SizedBox(height: 6),
              Text('No delirium signs detected.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
              const SizedBox(height: 6),
              const PhaseActionRow(icon: '📋', label: 'View Orientation Quiz'),
              const PhaseActionRow(icon: '🔔', label: 'Report Confusion to Nurse'),
            ],
          ),
        ),

        // Wound care
        PhaseSection(
          title: '🩹 E. Wound Care',
          child: Column(
            children: const [
              PhaseActionRow(icon: '🔍', label: 'Daily wound check guide'),
              PhaseActionRow(icon: '⚠️', label: 'Warning signs to report'),
              PhaseActionRow(icon: '🚿', label: 'Showering instructions'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['😢', '😟', '😐', '🙂', '😊'].map((e) => GestureDetector(
                  onTap: () => setState(() => _emotionEmoji = e),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _emotionEmoji == e ? AppColors.tealLight : AppColors.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: _emotionEmoji == e ? Border.all(color: AppColors.teal, width: 2) : null,
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
              Text("Post-cardiac surgery blues are normal. You're not alone.", style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.teal, height: 1.5), textAlign: TextAlign.center),
            ],
          ),
        ),

        // Meditation
        PhaseSection(
          title: '🧘 G. Meditation & Relaxation',
          child: Column(
            children: const [
              PhaseActionRow(icon: '🎧', label: 'Body Scan Meditation (10 min)'),
              PhaseActionRow(icon: '🌊', label: 'Ocean Sounds Sleep Aid'),
              PhaseActionRow(icon: '🧘', label: 'Mindful Breathing (5 min)'),
            ],
          ),
        ),

        // Nutrition
        PhaseSection(
          title: '🥣 H. Nutrition',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current diet: Soft cardiac diet', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal)),
              const SizedBox(height: 6),
              const PhaseActionRow(icon: '📋', label: 'View today\'s meal plan'),
              const PhaseActionRow(icon: '📞', label: 'Speak with dietitian'),
            ],
          ),
        ),

        // ICU education
        PhaseSection(
          title: '🎓 I. ICU Education',
          background: const Color(0xFFF0FDF9),
          child: Column(
            children: const [
              PhaseActionRow(icon: '📺', label: 'Understanding your ICU equipment'),
              PhaseActionRow(icon: '📖', label: 'ICU Recovery Guide (PDF)'),
              PhaseActionRow(icon: '❓', label: 'Common ICU FAQs'),
            ],
          ),
        ),
      ],
    );
  }
}

class _BreathingItem extends StatelessWidget {
  final String title;
  final String instruction;
  final bool done;
  const _BreathingItem(this.title, this.instruction, this.done);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: done ? AppColors.success : AppColors.border),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(instruction, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMedium)),
              ],
            ),
          ),
        ],
      ),
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
