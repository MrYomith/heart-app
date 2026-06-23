import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/progress_ring.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hp(context);
    final fs = Responsive.fontScale(context);
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);

    final topics = [
      ('🫀', 'Understanding\nYour Heart', 'Anatomy & Function'),
      ('🏥', 'Surgery\nProcedure', 'What to Expect'),
      ('💊', 'Medications\nExplained', 'Your Regimen'),
      ('🥗', 'Heart-Healthy\nNutrition', 'Diet & Recovery'),
      ('🧘', 'Mental\nWellbeing', 'Managing Anxiety'),
      ('🚶', 'Physical\nRehab', 'Exercises & Safety'),
    ];

    final videos = [
      ('▶️', 'What is Open-Heart Surgery?', '4:32', 'Dr. Surgeon Guide'),
      ('▶️', 'ERAS Protocol Explained', '6:15', 'Hospital Team'),
      ('▶️', 'Your First Week Home', '8:44', 'Cardiac Nurses'),
      ('▶️', 'Breathing Exercises', '5:20', 'Physio Team'),
    ];

    final guides = [
      ('📄', 'Pre-surgery Checklist', '2 min read'),
      ('📊', 'Recovery Milestones Infographic', 'Visual Guide'),
      ('📄', 'Medication Guide', '5 min read'),
      ('📊', 'Heart-Healthy Plate', 'Infographic'),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Education Hub', style: GoogleFonts.inter(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text('Learn at your own pace', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: isWide
                ? _buildWideLayout(context, topics, videos, guides, pad, fs)
                : _buildPhoneLayout(context, topics, videos, guides, fs),
          ),
        ),
      ),
    );
  }

  // ── Phone layout ─────────────────────────────────────────
  Widget _buildPhoneLayout(BuildContext context, List topics, List videos, List guides, double fs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProgressCard(fs: fs),
        const SizedBox(height: 18),
        Text('Browse Topics', style: GoogleFonts.inter(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _TopicCard(t: topics[i], fs: fs, size: 92),
          ),
        ),
        const SizedBox(height: 18),
        Text('Recommended Videos', style: GoogleFonts.inter(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _VideoCard(v: videos[i], fs: fs, width: 162),
          ),
        ),
        const SizedBox(height: 18),
        _GuidesSection(guides: guides, fs: fs),
        const SizedBox(height: 18),
        _QuizSection(fs: fs),
      ],
    );
  }

  // ── Tablet layout (2-column) ──────────────────────────────
  Widget _buildWideLayout(BuildContext context, List topics, List videos, List guides, double pad, double fs) {
    final topicCols = Responsive.isLarge(context) ? 6 : 4;
    final videoCols = Responsive.isLarge(context) ? 4 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress + quiz side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ProgressCard(fs: fs)),
            const SizedBox(width: 16),
            Expanded(child: _QuizSection(fs: fs)),
          ],
        ),
        const SizedBox(height: 20),
        Text('Browse Topics', style: GoogleFonts.inter(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: topicCols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: topics.map((t) => _TopicCard(t: t, fs: fs, size: double.infinity)).toList(),
        ),
        const SizedBox(height: 20),
        Text('Recommended Videos', style: GoogleFonts.inter(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: videoCols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: videos.map((v) => _VideoCard(v: v, fs: fs, width: double.infinity)).toList(),
        ),
        const SizedBox(height: 20),
        _GuidesSection(guides: guides, fs: fs),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double fs;
  const _ProgressCard({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Row(children: [
        ProgressRing(value: 72, max: 100, size: Responsive.value(context, phone: 70.0, tablet: 84.0), label: '72%', sublabel: 'complete'),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Learning Progress', style: GoogleFonts.inter(fontSize: 15 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('13 of 18 modules completed', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: [
            _Badge('🏅', 'Heart Hero', fs),
            _Badge('🌟', 'Fast Learner', fs),
            _Badge('💊', 'Meds Master', fs),
          ]),
        ])),
      ]),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final dynamic t;
  final double fs;
  final dynamic size;
  const _TopicCard({required this.t, required this.fs, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size is double && size != double.infinity ? size : null,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(t.$1, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(t.$2, style: GoogleFonts.inter(fontSize: 10 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark), textAlign: TextAlign.center),
        Text(t.$3, style: GoogleFonts.inter(fontSize: 9 * fs, color: AppColors.textMedium), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final dynamic v;
  final double fs;
  final dynamic width;
  const _VideoCard({required this.v, required this.fs, required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width is double && width != double.infinity ? width : null,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
            child: Center(child: Text(v.$1, style: const TextStyle(fontSize: 28))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v.$2, style: GoogleFonts.inter(fontSize: 10 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${v.$3} · ${v.$4}', style: GoogleFonts.inter(fontSize: 9 * fs, color: AppColors.textMedium)),
          ]),
        ),
      ]),
    );
  }
}

class _GuidesSection extends StatelessWidget {
  final List guides;
  final double fs;
  const _GuidesSection({required this.guides, required this.fs});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Guides & Infographics', style: GoogleFonts.inter(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      const SizedBox(height: 10),
      Container(
        decoration: AppDecorations.card,
        child: Column(children: guides.map((g) => Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Text(g.$1, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.$2, style: GoogleFonts.inter(fontSize: 13 * fs, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              Text(g.$3, style: GoogleFonts.inter(fontSize: 11 * fs, color: AppColors.textMedium)),
            ])),
            const Icon(Icons.download_rounded, size: 18, color: AppColors.teal),
          ]),
        )).toList()),
      ),
    ]);
  }
}

class _QuizSection extends StatelessWidget {
  final double fs;
  const _QuizSection({required this.fs});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Knowledge Quizzes', style: GoogleFonts.inter(fontSize: 17 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _QuizCard('🫀', 'Heart Surgery\nBasics', '5 questions', AppColors.primary.withValues(alpha: 0.1), fs)),
        const SizedBox(width: 10),
        Expanded(child: _QuizCard('💊', 'Medications\nSafety', '8 questions', AppColors.tealLight, fs)),
      ]),
    ]);
  }
}

class _QuizCard extends StatelessWidget {
  final String icon, title, sub;
  final Color bg;
  final double fs;
  const _QuizCard(this.icon, this.title, this.sub, this.bg, this.fs);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 6),
        Text(title, style: GoogleFonts.inter(fontSize: 13 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text(sub, style: GoogleFonts.inter(fontSize: 11 * fs, color: AppColors.textMedium)),
        const SizedBox(height: 8),
        Text('Start Quiz →', style: GoogleFonts.inter(fontSize: 11 * fs, fontWeight: FontWeight.w700, color: AppColors.teal)),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String icon, label;
  final double fs;
  const _Badge(this.icon, this.label, this.fs);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 3),
        Text(label, style: GoogleFonts.inter(fontSize: 9 * fs, fontWeight: FontWeight.w700, color: AppColors.teal)),
      ]),
    );
  }
}
