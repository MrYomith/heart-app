import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/progress_ring.dart';

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
            Text('Education Hub', style: GoogleFonts.inter(fontSize: 20 * fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text('Learn at your own pace', style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
          ],
        ),
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
                        label: Text('${t.$2}  ${t.$3}', style: GoogleFonts.inter(fontSize: 12 * fs, fontWeight: FontWeight.w600)),
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
          Text('Learning Progress', style: GoogleFonts.inter(fontSize: 15 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(total == 0 ? 'No modules yet' : '$done of $total modules completed',
              style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
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
            style: GoogleFonts.inter(fontSize: 14 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        subtitle: Text([
          (content['category'] as String?) ?? (content['type'] as String? ?? 'lesson'),
          if (completed) '✓ completed',
        ].join(' · '), style: GoogleFonts.inter(fontSize: 11 * fs, color: completed ? AppColors.teal : AppColors.textMedium)),
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
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark))),
              ]),
              const SizedBox(height: 8),
              Text('${(content['type'] as String? ?? 'lesson')}${content['category'] != null ? ' · ${content['category']}' : ''}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
              const SizedBox(height: 16),
              if ((content['media_url']) != null)
                Container(
                  height: 120, width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(_typeEmoji(content['type'] as String?), style: const TextStyle(fontSize: 40))),
                )
              else
                Text('This lesson has no media attached yet — your care team will add it soon.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMedium)),
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
        Text(title, style: GoogleFonts.inter(fontSize: 15 * fs, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(sub, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12 * fs, color: AppColors.textMedium)),
      ]),
    );
  }
}
