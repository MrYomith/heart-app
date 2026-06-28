import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../../widgets/phase_layout.dart';
import '../../widgets/stage_guides.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_providers.dart';
import '../learn_screen.dart';
import '../messages_screen.dart';
import '../breathing_screen.dart';

void _push(BuildContext c, Widget s) => Navigator.push(c, MaterialPageRoute(builder: (_) => s));
String _orNot(String? v) => (v == null || v.isEmpty) ? 'Not recorded yet' : v;

class PreopScreen extends ConsumerWidget {
  const PreopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final day = user?.dayPostOp;
    final daysUntil = day == null ? null : -day;
    final heroSub = daysUntil == null
        ? 'Your surgery date will appear here once set'
        : daysUntil > 0
            ? 'Surgery in $daysUntil ${daysUntil == 1 ? "day" : "days"}'
            : 'Surgery scheduled';
    return PhaseLayout(
      title: 'Pre-operative Preparation',
      subtitle: 'Getting ready for your surgery',
      iconEmoji: '📋',
      heroBg: const Color(0xFFF0FDF9),
      mioVariant: MioVariant.defaultMio,
      heroMsg: "Let's prepare you for the\nbest possible surgery outcome.",
      heroSub: heroSub,
      mottoMsg: 'Prepared patients recover faster. 💪',
      focusItems: const [
        FocusItem('✅', 'ERAS checklist'),
        FocusItem('🍽️', 'Fasting plan'),
        FocusItem('💊', 'Medication pause'),
      ],
      sideNav: const [
        SideNavItem('✅', 'ERAS\nChecklist'),
        SideNavItem('📹', 'Telemedicine\n& Contact'),
        SideNavItem('🏋️', 'Physical\nOptim.'),
        SideNavItem('🫁', 'Respiratory\nPrehab'),
        SideNavItem('🥦', 'Nutrition &\nHydration'),
        SideNavItem('😴', 'Sleep'),
        SideNavItem('📚', 'Surgical\nEducation'),
        SideNavItem('🤝', 'Shared\nDecisions'),
        SideNavItem('🗓️', 'Surgery\nPlan'),
      ],
      sections: Column(
        children: [
          const PhaseSection(
            title: '📚 Learn about this stage',
            subtitle: 'Tap any guide to read more',
            child: StageGuides(stage: 'preop'),
          ),
          const PhaseSection(
            title: '✅ A. ERAS Checklist',
            subtitle: 'Enhanced Recovery After Surgery Protocol',
            child: _ErasChecklist(),
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
                          Text(user?.surgeonName ?? 'Your care team', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          Text('Message available', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMedium)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _push(context, const MessagesScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(20)),
                        child: Text('Join Call', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
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
                const _ProgressRow('Spirometry Practice', 0),
                const _ProgressRow('Daily Walks', 0),
                const _ProgressRow('Breathing Exercises', 0),
                const SizedBox(height: 4),
                PhaseActionRow(icon: '▶️', label: 'Watch: Prehab Exercises', onTap: () => _push(context, const BreathingScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🫁 D. Respiratory Prehabilitation',
            background: const Color(0xFFEFF6FF),
            child: Column(
              children: [
                const PhaseActionRow(icon: '🫁', label: 'Incentive spirometry — 3× per day'),
                const PhaseActionRow(icon: '🌬️', label: 'Breathing control — 10 min per day'),
                const PhaseActionRow(icon: '😤', label: 'Cough training — twice daily'),
                const SizedBox(height: 4),
                PhaseActionRow(icon: '▶️', label: 'Open breathing coach', onTap: () => _push(context, const BreathingScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🥦 E. Nutrition & Hydration',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pre-surgery nutrition plan:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 6),
                const PhaseActionRow(icon: '🥤', label: 'Carbohydrate drink tonight (10pm)'),
                const PhaseActionRow(icon: '🍽️', label: 'Light dinner only (by 8pm)'),
                const PhaseActionRow(icon: '🚫', label: 'Nothing by mouth after midnight'),
                const PhaseActionRow(icon: '📋', label: 'Download full fasting schedule'),
              ],
            ),
          ),

          PhaseSection(
            title: '😴 F. Sleep Optimisation',
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
                          Text('Aim for 7–8h', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          Text('Good sleep before surgery aids recovery', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMedium)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                PhaseActionRow(icon: '🎧', label: 'Sleep Meditation (12 min)', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '📚 G. Surgical Education',
            child: Column(
              children: [
                PhaseActionRow(icon: '🎬', label: 'What happens on surgery day', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '🏥', label: 'ICU & recovery explained', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '🩺', label: 'Tubes, lines & drains', onTap: () => _push(context, const LearnScreen())),
                PhaseActionRow(icon: '💊', label: 'Pain management', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🤝 H. Shared Decision-Making',
            background: const Color(0xFFF8F6FF),
            child: Column(
              children: [
                PhaseActionRow(icon: '🎯', label: 'My goals & concerns', onTap: () => _push(context, const MessagesScreen())),
                PhaseActionRow(icon: '❓', label: 'Questions for my surgeon', onTap: () => _push(context, const MessagesScreen())),
                PhaseActionRow(icon: '⚖️', label: 'Understanding risks & benefits', onTap: () => _push(context, const LearnScreen())),
              ],
            ),
          ),

          PhaseSection(
            title: '🗓️ I. Surgery Plan Overview',
            child: Column(
              children: [
                _InfoRow('Hospital', _orNot(user?.hospitalName)),
                _InfoRow('Surgeon', _orNot(user?.surgeonName)),
                _InfoRow('Surgery date', _orNot(user?.surgeryDate)),
                _InfoRow('Procedure', _orNot(user?.surgeryType?.toUpperCase())),
                _InfoRow('NYHA class', _orNot(user?.nyhaClass)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _push(context, const LearnScreen()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text('Download Surgery Pack', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Real ERAS prehab checklist — ticking persists to the backend (eras_progress)
/// and moves the same rings shown on the full ERAS screen (interconnected).
class _ErasChecklist extends ConsumerStatefulWidget {
  const _ErasChecklist();
  @override
  ConsumerState<_ErasChecklist> createState() => _ErasChecklistState();
}

class _ErasChecklistState extends ConsumerState<_ErasChecklist> {
  // key → patient-facing label
  static const _items = <(String, String)>[
    ('smoking', 'Stop smoking (if applicable)'),
    ('nutrition', 'Optimise nutrition & protein intake'),
    ('exercise', 'Daily prehab walks'),
    ('breathing', 'Breathing / spirometry practice'),
    ('medications', 'Review medications with your team'),
    ('skin_prep', 'Antiseptic skin prep'),
    ('education', 'Complete pre-surgery education'),
  ];

  late final Future<Map<String, int>> _future = _load();

  Future<Map<String, int>> _load() async {
    final summary = await ref.read(patientRepositoryProvider).erasSummary();
    return {
      for (final it in summary.items) (it['item_key'] as String): (it['progress'] as num?)?.toInt() ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(padding: EdgeInsets.all(8), child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))));
        }
        final progress = snap.data!;
        return Column(
          children: [
            for (final (key, label) in _items)
              CheckRow(
                label: label,
                initialDone: (progress[key] ?? 0) >= 100,
                onChanged: (done) async {
                  await ref.read(patientRepositoryProvider).updateEras(key, done ? 100 : 0);
                },
              ),
          ],
        );
      },
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
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark)),
              Text('$percent%', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)),
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
          SizedBox(width: 100, child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMedium))),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        ],
      ),
    );
  }
}
