import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// Symptom escalation (FR-202) — one-tap red-flag report that raises a clinician alert.
class SymptomsScreen extends ConsumerStatefulWidget {
  const SymptomsScreen({super.key});
  @override
  ConsumerState<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends ConsumerState<SymptomsScreen> {
  bool _busy = false;

  Future<void> _report(String key, String label) async {
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: Text('Report: $label', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          content: TextField(controller: c, maxLines: 3, decoration: const InputDecoration(hintText: 'Add a note (optional)…', border: OutlineInputBorder())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Send to care team'),
            ),
          ],
        );
      },
    );
    if (note == null) return;
    setState(() => _busy = true);
    try {
      final r = await ref.read(patientRepositoryProvider).reportSymptom(key, note: note.isEmpty ? null : note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(r.severity == 'critical'
              ? 'Your care team has been alerted immediately.'
              : 'Reported. Your care team will review this.'),
          backgroundColor: r.severity == 'critical' ? AppColors.primary : AppColors.teal,
        ));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not send. Please try again.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final symptoms = ref.watch(contentProvider((category: 'symptom', stage: null)));
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: Text('Report a Symptom', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Text('🚑', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Text('If this is an emergency, call 112 (or your local emergency number) immediately.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w600))),
            ]),
          ),
          const SizedBox(height: 16),
          Text('Tap a symptom to notify your care team', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium)),
          const SizedBox(height: 10),
          symptoms.when(
            loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('Could not load symptoms.', style: GoogleFonts.poppins(color: AppColors.textMedium)),
            data: (list) => Column(children: [
              for (final s in list)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: AppDecorations.card,
                  child: ListTile(
                    leading: Text((s['emoji'] as String?) ?? '🩺', style: const TextStyle(fontSize: 26)),
                    title: Text(s['title'] as String? ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMedium),
                    onTap: _busy ? null : () => _report((s['item_key'] as String?) ?? 'symptom_report', s['title'] as String? ?? ''),
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}
