import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';

class PreopScreen extends StatelessWidget {
  const PreopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PhaseLayout(
      title: 'Pre-operative Preparation',
      subtitle: 'Getting ready for your surgery',
      iconEmoji: '📋',
      heroBg: const Color(0xFFF0FDF9),
      mioVariant: MioVariant.medical,
      heroMsg: "Let's prepare you for the\nbest possible surgery outcome.",
      heroSub: 'Surgery in 6 days · All systems green ✅',
      mottoMsg: 'Prepared patients recover faster. 💪',
      focusItems: const [
        FocusItem('✅', 'ERAS checklist'),
        FocusItem('🍽️', 'Fasting plan'),
        FocusItem('💊', 'Medication pause'),
      ],
      sideNav: const [
        SideNavItem('✅', 'ERAS\nChecklist'),
        SideNavItem('📹', 'Telemedicine'),
        SideNavItem('🏋️', 'Physical\nOptim.'),
        SideNavItem('🥦', 'Nutrition &\nHydration'),
        SideNavItem('😴', 'Sleep'),
        SideNavItem('🗓️', 'Surgery\nPlan'),
      ],
      sections: Column(
        children: [
          PhaseSection(
            title: '✅ A. ERAS Checklist',
            subtitle: 'Enhanced Recovery After Surgery Protocol',
            child: Column(
              children: [
                _ErasItem('Stop blood thinners 5 days before', true),
                _ErasItem('Carbohydrate drink the night before', true),
                _ErasItem('No food 6h before surgery', false),
                _ErasItem('No clear fluids 2h before surgery', false),
                _ErasItem('Anti-DVT stockings packed', true),
                _ErasItem('Shower with antiseptic soap tonight', false),
                _ErasItem('Bowel prep completed', true),
              ],
            ),
          ),

          PhaseSection(
            title: '📹 B. Telemedicine Check-in',
            background: const Color(0xFFF0FDF9),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('👩‍⚕️', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dr. Cardiac Surgeon', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          Text('Video consult available', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(20)),
                      child: Text('Join Call', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          PhaseSection(
            title: '🏋️ C. Physical Optimisation',
            child: Column(
              children: [
                _ProgressRow('Spirometry Practice', 80),
                _ProgressRow('Daily Walks', 60),
                _ProgressRow('Breathing Exercises', 90),
                const SizedBox(height: 4),
                const PhaseActionRow(icon: '▶️', label: 'Watch: Prehab Exercises'),
              ],
            ),
          ),

          PhaseSection(
            title: '🥦 D. Nutrition & Hydration',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pre-surgery nutrition plan:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 6),
                const PhaseActionRow(icon: '🥤', label: 'Carbohydrate drink tonight (10pm)'),
                const PhaseActionRow(icon: '🍽️', label: 'Light dinner only (by 8pm)'),
                const PhaseActionRow(icon: '🚫', label: 'Nothing by mouth after midnight'),
                const PhaseActionRow(icon: '📋', label: 'Download full fasting schedule'),
              ],
            ),
          ),

          PhaseSection(
            title: '😴 E. Sleep & Rest',
            background: const Color(0xFFF8F6FF),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('7.2h average', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          Text('Last 7 nights · Target: 8h', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const PhaseActionRow(icon: '🎧', label: 'Sleep Meditation (12 min)'),
              ],
            ),
          ),

          PhaseSection(
            title: '🗓️ F. Surgery Plan Overview',
            child: Column(
              children: [
                _InfoRow('Surgeon', 'Dr. Cardiac Surgeon'),
                _InfoRow('Hospital', 'St. George Hospital'),
                _InfoRow('Surgery date', 'Wednesday, 22 May 2024'),
                _InfoRow('Procedure', 'CABG (3-vessel bypass)'),
                _InfoRow('Est. duration', '4-6 hours'),
                _InfoRow('Arrival time', '06:00 AM'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text('Download Surgery Pack', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErasItem extends StatelessWidget {
  final String label;
  final bool done;
  const _ErasItem(this.label, this.done);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: done ? AppColors.success : AppColors.border),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: done ? AppColors.textMedium : AppColors.textDark, decoration: done ? TextDecoration.lineThrough : null))),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int percent;
  const _ProgressRow(this.label, this.percent);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark)),
              Text('$percent%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: percent / 100, backgroundColor: AppColors.bg, color: AppColors.teal, minHeight: 6),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium))),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        ],
      ),
    );
  }
}
