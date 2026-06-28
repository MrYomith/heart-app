import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/progress_ring.dart';
import '../widgets/mio_app_bar.dart';
import 'media_player_screen.dart';

/// Education Hub (FR-180–184) — real content from the CMS (/api/education),
/// filtered to the patient's surgery type by the backend. Progress + favourites
/// persist via /api/education/{id}/progress.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});
  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

const _topics = <(String?, String, String)>[
  (null, '✨', 'All'),
  ('understanding_heart', '🫀', 'Your Heart'),
  ('before_surgery', '🏥', 'Before Surgery'),
  ('surgery_stay', '🛏️', 'Surgery & Stay'),
  ('recovery', '🩹', 'Recovery'),
  ('living_well', '🌱', 'Living Well'),
];

String _typeEmoji(String? t) => switch (t) {
      'video' => '▶️',
      'audio' => '🎧',
      'guide' => '📄',
      'infographic' => '📊',
      _ => '📚',
    };

class _LearnScreenState extends ConsumerState<LearnScreen> {
  String? _topic;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hp(context);
    final fs = Responsive.fontScale(context);
    final asyncContent = ref.watch(educationProvider(_topic));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Education Hub', style: GoogleFonts.poppins(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text('Learn at your own pace', style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textMedium)),
          ],
        ),
        actions: mioActions(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(educationProvider(_topic).future),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
            child: ListView(
              padding: EdgeInsets.all(pad),
              children: [
                asyncContent.when(
                  loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => _Empty(icon: '⚠️', title: 'Could not load content', sub: 'Pull down to retry.', fs: fs),
                  data: (items) => _ProgressCard(items: items, fs: fs),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _topics.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final t = _topics[i];
                      final selected = t.$1 == _topic;
                      return ChoiceChip(
                        label: Text('${t.$2}  ${t.$3}', style: GoogleFonts.poppins(fontSize: 12 * fs, fontWeight: FontWeight.w600)),
                        selected: selected,
                        onSelected: (_) => setState(() => _topic = t.$1),
                        selectedColor: AppColors.teal,
                        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark),
                        backgroundColor: AppColors.bgCard,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                asyncContent.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (items) => items.isEmpty
                      ? _Empty(icon: '📚', title: 'No lessons yet', sub: 'Your care team is preparing content for this topic.', fs: fs)
                      : Column(children: [for (final c in items) _ContentCard(content: c, fs: fs, onChanged: () => ref.refresh(educationProvider(_topic)))]),
                ),
                const SizedBox(height: 20),
                // Check Your Knowledge (FR-182)
                Text('Check Your Knowledge', style: GoogleFonts.poppins(fontSize: 16 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('Short quizzes to reinforce learning', style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textMedium)),
                const SizedBox(height: 10),
                ref.watch(quizzesProvider).when(
                  loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (qs) => Column(children: [for (final q in qs) _QuizRow(quiz: q, fs: fs, onDone: () => ref.refresh(quizzesProvider))]),
                ),
                const SizedBox(height: 20),
                // Badges earned (FR-183)
                Text('Badges Earned', style: GoogleFonts.poppins(fontSize: 16 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 10),
                ref.watch(badgesProvider).when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (badges) => Wrap(spacing: 10, runSpacing: 10, children: [for (final b in badges) _BadgeChip(badge: b, fs: fs)]),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double fs;
  const _ProgressCard({required this.items, required this.fs});
  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final done = items.where((c) => (c['progress']?['completed'] as bool?) ?? false).length;
    final pct = total == 0 ? 0.0 : (done / total) * 100;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Row(children: [
        ProgressRing(value: pct, max: 100, size: 70, label: '${pct.round()}%', sublabel: 'done'),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Learning Progress', style: GoogleFonts.poppins(fontSize: 15 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(total == 0 ? 'No modules yet' : '$done of $total modules completed',
              style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textMedium)),
        ])),
      ]),
    );
  }
}

class _ContentCard extends ConsumerWidget {
  final Map<String, dynamic> content;
  final double fs;
  final VoidCallback onChanged;
  const _ContentCard({required this.content, required this.fs, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prog = content['progress'] as Map<String, dynamic>?;
    final completed = (prog?['completed'] as bool?) ?? false;
    final favourited = (prog?['favourited'] as bool?) ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppDecorations.card,
      child: ListTile(
        leading: Text(_typeEmoji(content['type'] as String?), style: const TextStyle(fontSize: 26)),
        title: Text(content['title'] as String? ?? 'Lesson',
            style: GoogleFonts.poppins(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        subtitle: Text([
          (content['category'] as String?) ?? (content['type'] as String? ?? 'lesson'),
          if (completed) '✓ completed',
        ].join(' · '), style: GoogleFonts.poppins(fontSize: 11 * fs, color: completed ? AppColors.teal : AppColors.textMedium)),
        trailing: Icon(favourited ? Icons.favorite : Icons.favorite_border, color: favourited ? AppColors.primary : AppColors.textMedium, size: 20),
        onTap: () => _open(context, ref),
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    final repo = ref.read(patientRepositoryProvider);
    final id = content['id'] as String;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final prog = content['progress'] as Map<String, dynamic>?;
        bool favourited = (prog?['favourited'] as bool?) ?? false;
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_typeEmoji(content['type'] as String?), style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(child: Text(content['title'] as String? ?? 'Lesson',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark))),
              ]),
              const SizedBox(height: 8),
              Text('${(content['type'] as String? ?? 'lesson')}${content['category'] != null ? ' · ${content['category']}' : ''}',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
              const SizedBox(height: 16),
              if ((content['media_url']) != null)
                GestureDetector(
                  onTap: () => _playMedia(ctx),
                  child: Container(
                    height: 140, width: double.infinity,
                    decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(12)),
                    child: Stack(alignment: Alignment.center, children: [
                      Positioned(top: 14, child: Text(_typeEmoji(content['type'] as String?), style: const TextStyle(fontSize: 36))),
                      Container(
                        width: 56, height: 56,
                        decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                        child: Icon(_isWebGuide() ? Icons.open_in_new_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
                      ),
                      Positioned(
                        bottom: 10,
                        child: Text(_mediaActionLabel(),
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tealDark)),
                      ),
                    ]),
                  ),
                )
              else
                Text('This lesson has no media attached yet — your care team will add it soon.',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () async {
                    await repo.trackEducationProgress(id, completed: true);
                    if (ctx.mounted) Navigator.pop(ctx);
                    onChanged();
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Mark complete'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white),
                )),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    favourited = !favourited;
                    setSheet(() {});
                    await repo.trackEducationProgress(id, favourited: favourited);
                    onChanged();
                  },
                  icon: Icon(favourited ? Icons.favorite : Icons.favorite_border, size: 18),
                  label: Text(favourited ? 'Saved' : 'Save'),
                ),
              ]),
            ]),
          );
        });
      },
    );
  }

  String get _mediaUrl => (content['media_url'] as String?) ?? '';
  bool get _isVideo => RegExp(r'\.(mp4|m4v|mov|webm)(\?|$)', caseSensitive: false).hasMatch(_mediaUrl);
  bool get _isAudio => RegExp(r'\.(mp3|wav|m4a|aac)(\?|$)', caseSensitive: false).hasMatch(_mediaUrl);
  bool _isWebGuide() => _mediaUrl.startsWith('http') && !_isVideo && !_isAudio;

  String _mediaActionLabel() {
    if (_isVideo) return 'Play video';
    if (_isAudio) return 'Play audio';
    if (_isWebGuide()) return 'Open guide';
    return 'Open';
  }

  Future<void> _playMedia(BuildContext context) async {
    final url = _mediaUrl;
    if (url.isEmpty) return;
    final title = content['title'] as String? ?? 'Lesson';
    if (_isVideo || _isAudio) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => MediaPlayerScreen(url: url, title: title, isAudio: _isAudio),
      ));
    } else {
      final uri = Uri.tryParse(url);
      if (uri != null && !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't open this resource.")));
        }
      }
    }
  }
}

class _Empty extends StatelessWidget {
  final String icon, title, sub;
  final double fs;
  const _Empty({required this.icon, required this.title, required this.sub, required this.fs});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppDecorations.card,
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        Text(title, style: GoogleFonts.poppins(fontSize: 15 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(sub, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textMedium)),
      ]),
    );
  }
}

// ─── Quizzes (FR-182) ─────────────────────────────────────────────────────────
class _QuizRow extends ConsumerWidget {
  final Map<String, dynamic> quiz;
  final double fs;
  final VoidCallback onDone;
  const _QuizRow({required this.quiz, required this.fs, required this.onDone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final best = quiz['best_score'] as int?;
    final n = quiz['question_count'] as int? ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppDecorations.card,
      child: ListTile(
        leading: const Text('📝', style: TextStyle(fontSize: 24)),
        title: Text(quiz['title'] as String? ?? 'Quiz',
            style: GoogleFonts.poppins(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        subtitle: Text(best != null ? '$n questions · best $best%' : '$n questions',
            style: GoogleFonts.poppins(fontSize: 11 * fs, color: best != null ? AppColors.teal : AppColors.textMedium)),
        trailing: Icon(best != null ? Icons.replay_rounded : Icons.chevron_right_rounded, size: 20, color: AppColors.teal),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => _QuizScreen(quizId: quiz['id'] as String)));
          onDone();
        },
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final Map<String, dynamic> badge;
  final double fs;
  const _BadgeChip({required this.badge, required this.fs});
  @override
  Widget build(BuildContext context) {
    final earned = (badge['earned'] as bool?) ?? false;
    return Opacity(
      opacity: earned ? 1 : 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: earned ? AppColors.tealLight : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: earned ? AppColors.teal : AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(badge['icon'] as String? ?? '🏅', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(badge['name'] as String? ?? 'Badge',
              style: GoogleFonts.poppins(fontSize: 11 * fs, fontWeight: FontWeight.w700, color: earned ? AppColors.tealDark : AppColors.textMedium)),
        ]),
      ),
    );
  }
}

// ─── Quiz-taking screen ───────────────────────────────────────────────────────
class _QuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  const _QuizScreen({required this.quizId});
  @override
  ConsumerState<_QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<_QuizScreen> {
  Map<String, dynamic>? _quiz;
  final Map<String, int> _answers = {};
  Map<String, dynamic>? _result;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    ref.read(patientRepositoryProvider).quiz(widget.quizId).then((q) => setState(() => _quiz = q));
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final r = await ref.read(patientRepositoryProvider).submitQuiz(widget.quizId, _answers);
      if (mounted) setState(() => _result = r);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = Responsive.fontScale(context);
    final quiz = _quiz;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: Text(quiz?['title'] as String? ?? 'Quiz', style: GoogleFonts.poppins(fontSize: 18 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: quiz == null
          ? const Center(child: CircularProgressIndicator())
          : _result != null
              ? _resultView(quiz, fs)
              : _quizView(quiz, fs),
    );
  }

  Widget _quizView(Map<String, dynamic> quiz, double fs) {
    final questions = (quiz['questions'] as List).cast<Map<String, dynamic>>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < questions.length; i++) _questionCard(questions[i], i, fs),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: (_answers.length == questions.length && !_submitting) ? _submit : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          child: Text(_submitting ? 'Checking…' : 'Submit answers', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _questionCard(Map<String, dynamic> q, int idx, double fs) {
    final qid = q['id'] as String;
    final options = (q['options'] as List).cast<String>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${idx + 1}. ${q['question']}', style: GoogleFonts.poppins(fontSize: 13 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 8),
        for (var o = 0; o < options.length; o++)
          GestureDetector(
            onTap: () => setState(() => _answers[qid] = o),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _answers[qid] == o ? AppColors.tealLight : AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _answers[qid] == o ? AppColors.teal : AppColors.border),
              ),
              child: Text(options[o], style: GoogleFonts.poppins(fontSize: 12 * fs, color: AppColors.textDark)),
            ),
          ),
      ]),
    );
  }

  Widget _resultView(Map<String, dynamic> quiz, double fs) {
    final r = _result!;
    final score = r['score'] as int;
    final badge = r['badge_awarded'] as Map<String, dynamic>?;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 10),
      Center(child: Text(score >= 80 ? '🎉' : '👍', style: const TextStyle(fontSize: 56))),
      const SizedBox(height: 8),
      Center(child: Text('$score%', style: GoogleFonts.poppins(fontSize: 36 * fs, fontWeight: FontWeight.w800, color: AppColors.teal))),
      Center(child: Text('${r['correct']} of ${r['total']} correct', style: GoogleFonts.poppins(fontSize: 13 * fs, color: AppColors.textMedium))),
      if (badge != null) ...[
        const SizedBox(height: 12),
        Center(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
          child: Text('${badge['icon']}  Badge earned: ${badge['name']}', style: GoogleFonts.poppins(fontSize: 13 * fs, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
        )),
      ],
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
        child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
    ]);
  }
}
