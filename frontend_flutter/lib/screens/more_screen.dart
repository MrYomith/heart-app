import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_providers.dart';
import '../utils/responsive.dart';
import '../widgets/progress_ring.dart';
import '../widgets/mio_app_bar.dart';
import 'medications_screen.dart';
import 'messages_screen.dart';
import 'symptoms_screen.dart';
import 'wearables_screen.dart';
import 'food_ai_screen.dart';
import 'screening_screen.dart';
import 'habits_screen.dart';
import 'journal_screen.dart';
import 'return_to_work_screen.dart';
import 'settings_screens.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
    final pad = Responsive.hp(context);
    final fs = Responsive.fontScale(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        automaticallyImplyLeading: false,
        title: Text('More', style: GoogleFonts.poppins(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        actions: mioActions(context),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
          child: isWide
              ? _buildWideLayout(context, pad, fs)
              : _buildPhoneLayout(context, pad, fs),
        ),
      ),
    );
  }

  // ── Phone layout ─────────────────────────────────────────
  Widget _buildPhoneLayout(BuildContext context, double pad, double fs) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ProfileCard(fs: fs),
        const SizedBox(height: 14),
        ..._menuSections(context, fs),
        const SizedBox(height: 14),
        _signOut(fs),
        const SizedBox(height: 8),
        _footer(fs),
        const SizedBox(height: 16),
      ]),
    );
  }

  // ── Tablet layout (2-col) ─────────────────────────────────
  Widget _buildWideLayout(BuildContext context, double pad, double fs) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: profile + wearables
          Expanded(
            flex: 4,
            child: Column(children: [
              _ProfileCard(fs: fs),
              const SizedBox(height: 14),
              _WearableExpanded(fs: fs),
              const SizedBox(height: 14),
              _signOut(fs),
              const SizedBox(height: 8),
              _footer(fs),
            ]),
          ),
          const SizedBox(width: 20),
          // Right column: menu sections
          Expanded(
            flex: 5,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ..._menuSections(context, fs),
            ]),
          ),
        ],
      ),
    );
  }

  // (emoji, title, subtitle, screen-builder or null for "coming soon")
  List<Widget> _menuSections(BuildContext context, double fs) {
    final sections = <(String, List<(String, String, String, WidgetBuilder?)>)>[
      ('Health & Recovery', [
        ('💊', 'Medications', 'Your regimen & reminders', (_) => const MedicationsScreen()),
        ('🩺', 'Symptoms Tracker', 'Report how you feel', (_) => const SymptomsScreen()),
        ('🍽️', 'Log a Meal', 'AI nutrition analysis', (_) => const FoodAiScreen()),
        ('⌚', 'Wearables & Vitals', 'Devices & readings', (_) => const WearablesScreen()),
      ]),
      ('Wellbeing', [
        ('🧠', 'Mood Screening', 'PHQ-9 check-in', (_) => const ScreeningScreen(type: 'phq9')),
        ('✅', 'Healthy Habits', 'Daily habits & streaks', (_) => const HabitsScreen()),
        ('📔', 'My Journal', 'Gratitude & reflections', (_) => const JournalScreen()),
        ('💼', 'Return to Work', 'Your personalised plan', (_) => const ReturnToWorkScreen()),
      ]),
      ('Support', [
        ('🎧', 'Contact Care Team', 'Secure messaging', (_) => const MessagesScreen()),
        ('🔔', 'Notifications', 'Manage alerts', (_) => const NotificationsSettingsScreen()),
        ('🌐', 'Language', 'English / Deutsch', (_) => const LanguageScreen()),
        ('🔒', 'Privacy & Security', 'Manage your data', (_) => const PrivacySecurityScreen()),
        ('❓', 'Help & FAQ', 'Get support', (_) => const HelpFaqScreen()),
      ]),
    ];

    void open(BuildContext ctx, (String, String, String, WidgetBuilder?) t) {
      if (t.$4 != null) {
        Navigator.of(ctx).push(MaterialPageRoute(builder: t.$4!));
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${t.$2} is coming soon.')));
      }
    }

    return sections.map((section) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text(section.$1, style: GoogleFonts.poppins(fontSize: 13 * fs, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
        ),
        Container(
          decoration: AppDecorations.card,
          child: Column(
            children: section.$2.map<Widget>((t) {
              return Container(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  leading: Text(t.$1, style: TextStyle(fontSize: 20 * fs)),
                  title: Text(t.$2, style: GoogleFonts.poppins(fontSize: 13 * fs, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  subtitle: Text(t.$3, style: GoogleFonts.poppins(fontSize: 11 * fs, color: AppColors.textMedium)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textLight),
                  onTap: () => open(context, t),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
      ],
    )).toList();
  }

  Widget _signOut(double fs) => _SignOutButton(fs: fs);

  Widget _footer(double fs) {
    return Center(
      child: Text('MioHart v1.0.0 · Made with ❤️ for your heart', style: GoogleFonts.poppins(fontSize: 11 * fs, color: AppColors.textLight)),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  final double fs;
  const _ProfileCard({required this.fs});

  static const _surgeryLabels = {
    'cabg': 'CABG Surgery',
    'valve': 'Valve Surgery',
    'tavi': 'TAVI',
    'aortic': 'Aortic Surgery',
    'combined': 'Combined Surgery',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
    final user = ref.watch(authControllerProvider).user;
    final name = user?.name ?? 'Patient';
    final email = user?.email ?? '';
    final surgery = _surgeryLabels[user?.surgeryType] ?? 'Cardiac patient';
    final progress = (user?.journeyProgress ?? 0).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(children: [
        Row(children: [
          Container(
            width: isWide ? 76 : 64, height: isWide ? 76 : 64,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.tealLight),
            child: Center(child: Text('👤', style: TextStyle(fontSize: isWide ? 36 : 30))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text('$surgery · ${user?.phaseLabel ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textMedium)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
              child: Text(email.isEmpty ? '🏥 Not enrolled yet' : '✉️ $email', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 10 * fs, fontWeight: FontWeight.w600, color: AppColors.teal)),
            ),
          ])),
          ProgressRing(
            value: progress.toDouble(),
            max: 100,
            size: isWide ? 72 : 60,
            label: '$progress%',
            sublabel: 'Journey',
          ),
        ]),
        if (!Responsive.isTablet(context)) ...[
          const SizedBox(height: 14),
          Builder(builder: (context) {
            final w = ref.watch(wearableSummaryProvider).valueOrNull ?? const {};
            return Row(children: [
              Expanded(child: _StatChip('❤️', _wv(w, 'heart_rate', ' bpm'), 'Heart Rate', fs)),
              const SizedBox(width: 8),
              Expanded(child: _StatChip('🦶', _wv(w, 'steps', ''), 'Steps', fs)),
              const SizedBox(width: 8),
              Expanded(child: _StatChip('💨', _wv(w, 'spo2', '%'), 'SpO₂', fs)),
            ]);
          }),
        ],
      ]),
    );
  }
}

/// Format a wearable-summary value for display, or '—' when not recorded.
String _wv(Map w, String key, String unit) {
  final m = w[key] as Map?;
  if (m == null) return '—';
  final v = m['value'] as num;
  final n = v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  return '$n$unit';
}

class _WearableExpanded extends ConsumerWidget {
  final double fs;
  const _WearableExpanded({required this.fs});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(wearableSummaryProvider).valueOrNull ?? const {};
    final connected = w.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('⌚ Wearable Data', style: GoogleFonts.poppins(fontSize: 15 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 6),
        Text(connected ? 'Latest synced readings' : 'Connect a device to see your readings',
            style: GoogleFonts.poppins(fontSize: 11 * fs, color: AppColors.textMedium)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatChip('❤️', _wv(w, 'heart_rate', ' bpm'), 'Heart Rate', fs),
            _StatChip('🦶', _wv(w, 'steps', ''), 'Steps', fs),
            _StatChip('💨', _wv(w, 'spo2', '%'), 'SpO₂', fs),
            _StatChip('😴', _wv(w, 'sleep', 'h'), 'Sleep', fs),
            _StatChip('🧠', _wv(w, 'hrv', ' ms'), 'HRV', fs),
            _StatChip('🔥', _wv(w, 'active_energy', ''), 'Energy', fs),
          ],
        ),
      ]),
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  final double fs;
  const _SignOutButton({required this.fs});

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Sign out?', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: AppColors.textDark)),
        content: Text('You can log back in anytime with your email and password.',
            style: GoogleFonts.poppins(color: AppColors.textMedium, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textMedium)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign out', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authControllerProvider.notifier).logout();
      // AuthGate swaps back to the Login screen automatically.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _confirmAndLogout(context, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
        child: Center(child: Text('Sign Out', style: GoogleFonts.poppins(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.primary))),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon, value, label;
  final double fs;
  const _StatChip(this.icon, this.value, this.label, this.fs);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 3),
        Text(value, style: GoogleFonts.poppins(fontSize: 12 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text(label, style: GoogleFonts.poppins(fontSize: 9 * fs, color: AppColors.textMedium)),
      ]),
    );
  }
}
