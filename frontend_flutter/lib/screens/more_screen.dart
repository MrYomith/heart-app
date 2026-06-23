import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../utils/responsive.dart';
import '../widgets/progress_ring.dart';

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
        title: Text('More', style: GoogleFonts.inter(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12), child: Icon(Icons.settings_rounded, color: AppColors.textDark, size: 22)),
        ],
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

  List<Widget> _menuSections(BuildContext context, double fs) {
    final sections = [
      {
        'title': 'Health & Recovery',
        'items': [
          ('❤️', 'Health Profile', 'Update your medical info'),
          ('💊', 'Medications', '4 active medications'),
          ('🩺', 'Symptoms Tracker', 'Log how you feel'),
          ('⌚', 'Wearables', 'Connected devices'),
        ],
      },
      {
        'title': 'Support & Community',
        'items': [
          ('🎧', 'Contact Care Team', 'Secure messaging'),
          ('📞', 'Emergency Contacts', 'Dr. Surgeon: 0400 000 000'),
          ('👥', 'Patient Community', 'Connect with others'),
          ('🔔', 'Notifications', 'Manage alerts'),
        ],
      },
      {
        'title': 'App Settings',
        'items': [
          ('🌐', 'Language', 'English'),
          ('🔒', 'Privacy & Security', 'Manage your data'),
          ('❓', 'Help & FAQ', 'Get support'),
          ('⭐', 'Rate the App', 'Share your feedback'),
        ],
      },
    ];

    return sections.map((section) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text(section['title']! as String, style: GoogleFonts.inter(fontSize: 13 * fs, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
        ),
        Container(
          decoration: AppDecorations.card,
          child: Column(
            children: (section['items']! as List).map<Widget>((item) {
              final t = item as (String, String, String);
              return Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  leading: Text(t.$1, style: TextStyle(fontSize: 20 * fs)),
                  title: Text(t.$2, style: GoogleFonts.inter(fontSize: 13 * fs, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  subtitle: Text(t.$3, style: GoogleFonts.inter(fontSize: 11 * fs, color: AppColors.textMedium)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textLight),
                  onTap: () {},
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
      ],
    )).toList();
  }

  Widget _signOut(double fs) {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
        child: Center(child: Text('Sign Out', style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.primary))),
      ),
    );
  }

  Widget _footer(double fs) {
    return Center(
      child: Text('MioHart v1.0.0 · Made with ❤️ for your heart', style: GoogleFonts.inter(fontSize: 11 * fs, color: AppColors.textLight)),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final double fs;
  const _ProfileCard({required this.fs});
  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
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
            Text(userName, style: GoogleFonts.inter(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text('CABG Surgery · Pre-op Phase', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
              child: Text('🏥 St. George Hospital', style: GoogleFonts.inter(fontSize: 10 * fs, fontWeight: FontWeight.w600, color: AppColors.teal)),
            ),
          ])),
          ProgressRing(
            value: journeyProgress.toDouble(),
            max: 100,
            size: isWide ? 72 : 60,
            label: '$journeyProgress%',
            sublabel: 'Journey',
          ),
        ]),
        if (!Responsive.isTablet(context)) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _StatChip('❤️', '72 BPM', 'Heart Rate', fs)),
            const SizedBox(width: 8),
            Expanded(child: _StatChip('💧', '112 mg/dL', 'Glucose', fs)),
            const SizedBox(width: 8),
            Expanded(child: _StatChip('🦶', '3,240', 'Steps', fs)),
          ]),
        ],
      ]),
    );
  }
}

class _WearableExpanded extends StatelessWidget {
  final double fs;
  const _WearableExpanded({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('⌚ Wearable Data', style: GoogleFonts.inter(fontSize: 15 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatChip('❤️', '72 BPM', 'Heart Rate', fs),
            _StatChip('💧', '112 mg/dL', 'Glucose', fs),
            _StatChip('🦶', '3,240', 'Steps', fs),
            _StatChip('💨', '98%', 'SpO₂', fs),
            _StatChip('😴', '7h 15m', 'Sleep', fs),
            _StatChip('🧠', '62 ms', 'HRV', fs),
          ],
        ),
      ]),
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
        Text(value, style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text(label, style: GoogleFonts.inter(fontSize: 9 * fs, color: AppColors.textMedium)),
      ]),
    );
  }
}
