import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';

class ThrivingScreen extends StatelessWidget {
  const ThrivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      Text('Congratulations! 🎉', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text("You've completed your heart surgery journey and you're now thriving!", style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.9), height: 1.4)),
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
                Text('Ongoing management goals:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 6),
                _GoalRow('Blood pressure', '< 130/80 mmHg', '122/78', true),
                _GoalRow('LDL Cholesterol', '< 1.8 mmol/L', '1.6', true),
                _GoalRow('HbA1c (diabetes)', '< 7%', '6.4%', true),
                _GoalRow('BMI', '18.5–24.9', '26.1', false),
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
                    Expanded(child: _FitnessCard('🚶', 'Weekly Steps', '42,000', '/ 70,000')),
                    const SizedBox(width: 8),
                    Expanded(child: _FitnessCard('⏱️', 'Active Mins', '112', '/ 150')),
                    const SizedBox(width: 8),
                    Expanded(child: _FitnessCard('❤️', 'Resting HR', '62', 'BPM')),
                  ],
                ),
                const SizedBox(height: 10),
                const PhaseActionRow(icon: '📋', label: 'View Full Exercise Plan'),
                const PhaseActionRow(icon: '🏅', label: 'Cardiac Rehab Graduation'),
              ],
            ),
          ),

          PhaseSection(
            title: '🥗 C. Nutrition',
            child: Column(
              children: const [
                PhaseActionRow(icon: '🫒', label: 'Mediterranean Diet Guide'),
                PhaseActionRow(icon: '📊', label: 'Weekly Nutrition Tracking'),
                PhaseActionRow(icon: '👩‍🍳', label: 'Heart-Healthy Recipes'),
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
                    Expanded(child: _WellbeingCard('😊', 'Mood', 'Great')),
                    const SizedBox(width: 8),
                    Expanded(child: _WellbeingCard('😴', 'Sleep', '7.8h')),
                    const SizedBox(width: 8),
                    Expanded(child: _WellbeingCard('🧘', 'Stress', 'Low')),
                  ],
                ),
                const SizedBox(height: 8),
                const PhaseActionRow(icon: '🎧', label: 'Daily Mindfulness (10 min)'),
              ],
            ),
          ),

          PhaseSection(
            title: '👥 E. Relationships & Social',
            child: Column(
              children: const [
                PhaseActionRow(icon: '💑', label: 'Intimacy & recovery guide'),
                PhaseActionRow(icon: '👨‍👩‍👧', label: 'Family communication resources'),
                PhaseActionRow(icon: '🤝', label: 'Support group connections'),
              ],
            ),
          ),

          PhaseSection(
            title: '💼 F. Work & Purpose',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow('Work status', 'Full time (returned)'),
                _InfoRow('Clearance', 'All activities cleared'),
                _InfoRow('Next review', 'December 2024'),
                const SizedBox(height: 6),
                const PhaseActionRow(icon: '🎯', label: 'Set new life goals'),
              ],
            ),
          ),

          PhaseSection(
            title: '✈️ G. Travel',
            background: const Color(0xFFF0FDF9),
            child: Column(
              children: const [
                PhaseActionRow(icon: '✈️', label: 'Travel clearance: All clear'),
                PhaseActionRow(icon: '💊', label: 'Travelling with medications guide'),
                PhaseActionRow(icon: '🌏', label: 'International travel tips'),
              ],
            ),
          ),

          PhaseSection(
            title: '🩺 H. Ongoing Check-ups',
            child: Column(
              children: [
                _CheckupRow('3-month cardiology review', 'Jun 2024', true),
                _CheckupRow('6-month echo & stress test', 'Sep 2024', false),
                _CheckupRow('Annual full cardiac review', 'Mar 2025', false),
                _CheckupRow('Flu vaccination', 'Apr 2025', false),
              ],
            ),
          ),

          PhaseSection(
            title: '🤝 I. Give Back',
            background: const Color(0xFFF0FDF9),
            child: Column(
              children: const [
                PhaseActionRow(icon: '🌱', label: 'Share your story with new patients'),
                PhaseActionRow(icon: '🤝', label: 'Become a peer recovery mentor'),
                PhaseActionRow(icon: '💝', label: 'Donate to cardiac research'),
              ],
            ),
          ),

          PhaseSection(
            title: '🏅 J. Journey Highlights',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your remarkable journey:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                _MilestoneRow('🔍', 'Diagnosis received', 'March 2024'),
                _MilestoneRow('📋', 'Pre-op completed', 'May 2024'),
                _MilestoneRow('🏥', 'Surgery success', 'May 22, 2024'),
                _MilestoneRow('🚶', 'First steps post-op', 'May 24, 2024'),
                _MilestoneRow('🏠', 'Discharged home', 'May 28, 2024'),
                _MilestoneRow('🏃', 'First run (1km)', 'August 2024'),
                _MilestoneRow('🌟', 'Thriving today!', 'Ongoing'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4A7C79), Color(0xFF6BA39D)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('Download My Recovery Story', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
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
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(child: Text(metric, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark))),
          Text(current, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: achieved ? AppColors.success : AppColors.primary)),
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
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMedium), textAlign: TextAlign.center),
          Text(sub, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textLight)),
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
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMedium)),
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
          SizedBox(width: 80, child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium))),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark))),
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
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.schedule, size: 16, color: done ? AppColors.success : AppColors.textLight),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark))),
          Text(date, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.teal)),
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
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark))),
          Text(date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
