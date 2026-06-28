import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';
import '../learn_screen.dart';
import '../food_ai_screen.dart';
import '../habits_screen.dart';
import '../journal_screen.dart';
import '../messages_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/patient_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stage_guides.dart';

void _push(BuildContext c, Widget s) => Navigator.push(c, MaterialPageRoute(builder: (_) => s));

class ThrivingScreen extends ConsumerWidget {
  const ThrivingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitals = ref.watch(latestVitalsProvider).valueOrNull ?? const {};
    final goal = ref.watch(weeklyGoalProvider).valueOrNull;
    final user = ref.watch(authControllerProvider).user;
    String v(String key, {String unit = ''}) {
      final m = vitals[key] as Map?;
      if (m == null) return '—';
      final val = m['value'] as num;
      final n = val == val.roundToDouble() ? val.toInt().toString() : val.toStringAsFixed(1);
      return '$n$unit';
    }
    final bp = (vitals['bp_systolic'] != null && vitals['bp_diastolic'] != null)
        ? '${(vitals['bp_systolic']['value'] as num).toInt()}/${(vitals['bp_diastolic']['value'] as num).toInt()}'
        : 'Not recorded yet';
    return PhaseLayout(
      title: 'Thriving Phase',
      subtitle: 'Living your best heart-healthy life',
      iconEmoji: '🌟',
      heroBg: const Color(0xFFF0FDF4),
      mioVariant: MioVariant.thriving,
      heroMsg: 'Look how far you\'ve come!\nYou are thriving. 🌟',
      heroSub: '6+ months post-surgery · Living fully',
      mottoMsg: "Your heart is stronger than ever. 💚",
      focusItems: const [
        FocusItem('🏃', '150 min/wk'),
        FocusItem('🥗', 'Med diet'),
        FocusItem('😴', '8h sleep'),
      ],
      sideNav: const [
        SideNavItem('❤️', 'Long-term\nHealth'),
        SideNavItem('🏃', 'Fitness'),
        SideNavItem('🥗', 'Nutrition'),
        SideNavItem('🧠', 'Mental\nWell.'),
        SideNavItem('👥', 'Relationships'),
        SideNavItem('💼', 'Work &\nPurpose'),
        SideNavItem('✈️', 'Travel'),
        SideNavItem('🩺', 'Check-ups'),
        SideNavItem('🤝', 'Give Back'),
        SideNavItem('🏅', 'Journey\nHighlights'),
      ],
      sections: Column(
        children: [
          const PhaseSection(
            title: '📚 Learn about this stage',
            subtitle: 'Tap any guide to read more',
            child: StageGuides(stage: 'thriving'),
          ),
          // Celebration banner
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4A7C79), Color(0xFF6BA39D)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const MioMascot(variant: MioVariant.thriving, size: 60),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Congratulations! 🎉', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text("You've completed your heart surgery journey and you're now thriving!", style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.9), height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          PhaseSection(
            title: '❤️ A. Long-term Heart Health',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ongoing management goals:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 6),
                _GoalRow('Blood pressure', '< 130/80 mmHg', bp, vitals['bp_systolic'] != null),
                _GoalRow('LDL Cholesterol', '< 1.8 mmol/L', v('ldl'), vitals['ldl'] != null),
                _GoalRow('HbA1c (diabetes)', '< 7%', v('hba1c', unit: '%'), vitals['hba1c'] != null),
                _GoalRow('BMI', '18.5–24.9', v('bmi'), vitals['bmi'] != null),
              ],
            ),
          ),

          PhaseSection(
            title: '🏃 B. Physical Fitness',
            background: const Color(0xFFF0FDF9),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _FitnessCard('🚶', 'Steps', v('steps'), 'latest')),
                    const SizedBox(width: 8),
                    Expanded(child: _FitnessCard('⏱️', 'Active Mins', '${goal?.minutes ?? 0}', '/ ${goal?.goal ?? 150}')),
                    const SizedBox(width: 8),
                    Expanded(child: _FitnessCard('❤️', 'Heart Rate', v('heart_rate'), 'bpm')),
                  ],
                ),
                const SizedBox(height: 10),
                PhaseActionRow(icon: '📋', label: 'View Full Exercise Plan', onTap: () => _push(context, const HabitsScreen())),
                PhaseActionRow(icon: '🏅', label: 'Cardiac Rehab Graduation', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🥗 C. Nutrition',
            child: Column(
              children: [
                PhaseActionRow(icon: '🫒', label: 'Mediterranean Diet Guide', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '📊', label: 'Weekly Nutrition Tracking', onTap: () => _push(context, const FoodAiScreen())),
                PhaseActionRow(icon: '👩‍🍳', label: 'Heart-Healthy Recipes', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🧠 D. Mental Wellbeing',
            background: const Color(0xFFF8F6FF),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _WellbeingCard('😊', 'Mood', v('mood'))),
                    const SizedBox(width: 8),
                    Expanded(child: _WellbeingCard('😴', 'Sleep', v('sleep_hours', unit: 'h'))),
                    const SizedBox(width: 8),
                    Expanded(child: _WellbeingCard('🧘', 'Stress', v('stress'))),
                  ],
                ),
                const SizedBox(height: 8),
                PhaseActionRow(icon: '🎧', label: 'Daily Mindfulness (10 min)', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '👥 E. Relationships & Social',
            child: Column(
              children: [
                PhaseActionRow(icon: '💑', label: 'Intimacy & recovery guide', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '👨‍👩‍👧', label: 'Family communication resources', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '🤝', label: 'Support group connections', onTap: () => _push(context, const MessagesScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '💼 F. Work & Purpose',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _InfoRow('Desk job', '4–6 weeks after surgery'),
                const _InfoRow('Light physical', '6–8 weeks after surgery'),
                const _InfoRow('Heavy physical', '3–6 months after surgery'),
                const SizedBox(height: 6),
                PhaseActionRow(icon: '🎯', label: 'Set new life goals', onTap: () => _push(context, const JournalScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '✈️ G. Travel',
            background: const Color(0xFFF0FDF9),
            child: Column(
              children: [
                PhaseActionRow(icon: '✈️', label: 'Travel clearance: All clear', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '💊', label: 'Travelling with medications guide', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '🌏', label: 'International travel tips', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          const PhaseSection(
            title: '🩺 H. Ongoing Check-ups',
            child: Column(
              children: [
                _CheckupRow('Cardiology review', 'Every 3 months', false),
                _CheckupRow('Echo & stress test', 'At 6 months', false),
                _CheckupRow('Full cardiac review', 'Annually', false),
                _CheckupRow('Flu vaccination', 'Each season', false),
              ],
            ),
          ),

          PhaseSection(
            title: '🤝 I. Give Back',
            background: const Color(0xFFF0FDF9),
            child: Column(
              children: [
                PhaseActionRow(icon: '🌱', label: 'Share your story with new patients', onTap: () => _push(context, const MessagesScreen())),
                PhaseActionRow(icon: '🤝', label: 'Become a peer recovery mentor', onTap: () => _push(context, const MessagesScreen())),
                const PhaseActionRow(icon: '💝', label: 'Donate to cardiac research'),
              ],
            ),
          ),

          PhaseSection(
            title: '🏅 J. Journey Highlights',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your remarkable journey:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                _MilestoneRow('🏥', 'Surgery', user?.surgeryDate ?? '—'),
                _MilestoneRow('🏠', 'Discharged home', user?.dischargeDate ?? '—'),
                const _MilestoneRow('🌟', 'Thriving today!', 'Ongoing'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4A7C79), Color(0xFF6BA39D)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('Download My Recovery Story', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final String metric;
  final String target;
  final String current;
  final bool achieved;
  const _GoalRow(this.metric, this.target, this.current, this.achieved);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(child: Text(metric, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark))),
          Text(current, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: achieved ? AppColors.success : AppColors.primary)),
          const SizedBox(width: 6),
          Icon(achieved ? Icons.check_circle : Icons.arrow_forward, size: 14, color: achieved ? AppColors.success : AppColors.primary),
        ],
      ),
    );
  }
}

class _FitnessCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String sub;
  const _FitnessCard(this.icon, this.label, this.value, this.sub);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMedium), textAlign: TextAlign.center),
          Text(sub, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _WellbeingCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _WellbeingCard(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMedium)),
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
          SizedBox(width: 80, child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMedium))),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        ],
      ),
    );
  }
}

class _CheckupRow extends StatelessWidget {
  final String label;
  final String date;
  final bool done;
  const _CheckupRow(this.label, this.date, this.done);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.schedule, size: 16, color: done ? AppColors.success : AppColors.textLight),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark))),
          Text(date, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.teal)),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final String icon;
  final String label;
  final String date;
  const _MilestoneRow(this.icon, this.label, this.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark))),
          Text(date, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
