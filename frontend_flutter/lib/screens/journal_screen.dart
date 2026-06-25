import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// Journal — decision-making + gratitude entries (FR-067 / FR-142).
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  static const _types = [
    ('gratitude', '🙏', 'Gratitude'),
    ('decision_goal', '🎯', 'Goal'),
    ('decision_concern', '🤔', 'Concern'),
    ('surgeon_question', '❓', 'Question for surgeon'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider(null));
    final repo = ref.read(patientRepositoryProvider);

    Future<void> add() async {
      String type = 'gratitude';
      final controller = TextEditingController();
      final ok = await showModalBottomSheet<bool>(
        context: context, backgroundColor: AppColors.bgCard, isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('New journal entry', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(spacing: 6, children: [
              for (final t in _types)
                ChoiceChip(
                  label: Text('${t.$2} ${t.$3}'), selected: type == t.$1,
                  onSelected: (_) => setSheet(() => type = t.$1),
                  selectedColor: AppColors.teal, labelStyle: TextStyle(color: type == t.$1 ? Colors.white : AppColors.textDark),
                ),
            ]),
            const SizedBox(height: 12),
            TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(hintText: 'Write here…', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(46)),
              child: const Text('Save entry'),
            ),
          ]),
        )),
      );
      if (ok == true && controller.text.trim().isNotEmpty) {
        await repo.addJournal(type, controller.text.trim());
        ref.invalidate(journalProvider(null));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bgCard, title: Text('My Journal', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark))),
      floatingActionButton: FloatingActionButton.extended(onPressed: add, backgroundColor: AppColors.teal, icon: const Icon(Icons.edit), label: const Text('New entry')),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load your journal.', style: GoogleFonts.inter(color: AppColors.textMedium))),
        data: (list) => list.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('📔', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 10),
                Text('Your journal is empty', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text('Note something you are grateful for, a goal, or a question for your surgeon.',
                    textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
              ])))
            : ListView(padding: const EdgeInsets.all(16), children: [
                for (final e in list)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: AppDecorations.card,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(_emoji(e['type'] as String?), style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text((e['entry_date'] as String?) ?? '', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
                      ]),
                      const SizedBox(height: 6),
                      Text(e['body'] as String? ?? '', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark, height: 1.4)),
                    ]),
                  ),
              ]),
      ),
    );
  }

  String _emoji(String? t) => {'gratitude': '🙏', 'decision_goal': '🎯', 'decision_concern': '🤔', 'surgeon_question': '❓'}[t] ?? '📝';
}
