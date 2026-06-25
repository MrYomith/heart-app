import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_ring.dart';

/// FR-060 · ERAS pre-op preparation checklist: 7 progress rings + overall readiness.
class ErasScreen extends ConsumerStatefulWidget {
  const ErasScreen({super.key});
  @override
  ConsumerState<ErasScreen> createState() => _ErasScreenState();
}

class _ErasScreenState extends ConsumerState<ErasScreen> {
  List<Map<String, dynamic>> _items = [];
  int _overall = 0;
  bool _loading = true;

  static const _icons = {
    'smoking': '🚭', 'nutrition': '🥗', 'exercise': '🏃', 'breathing': '🫁',
    'medications': '💊', 'skin_prep': '🧼', 'education': '🎓',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(patientRepositoryProvider).erasSummary();
      if (mounted) setState(() { _items = s.items; _overall = s.overall; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _bump(String key, int current, int delta) async {
    final next = (current + delta).clamp(0, 100);
    setState(() {
      _items = [for (final i in _items) i['item_key'] == key ? {...i, 'progress': next} : i];
      _overall = (_items.fold<int>(0, (s, i) => s + (i['progress'] as int)) / _items.length).round();
    });
    try {
      final s = await ref.read(patientRepositoryProvider).updateEras(key, next);
      if (mounted) setState(() { _items = s.items; _overall = s.overall; });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Surgery Prep', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : ListView(padding: const EdgeInsets.all(20), children: [
              // Overall readiness
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.bgBanner, borderRadius: BorderRadius.circular(18)),
                child: Row(children: [
                  ProgressRing(value: _overall.toDouble(), max: 100, size: 86, label: '$_overall%', sublabel: 'ready'),
                  const SizedBox(width: 18),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your surgery readiness', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text('Complete each area below. Every step makes your surgery and recovery safer.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMedium, height: 1.4)),
                  ])),
                ]),
              ),
              const SizedBox(height: 18),
              ..._items.map((i) => _ErasCard(
                    icon: _icons[i['item_key']] ?? '✅',
                    label: i['label'] as String,
                    progress: i['progress'] as int,
                    onMinus: () => _bump(i['item_key'] as String, i['progress'] as int, -25),
                    onPlus: () => _bump(i['item_key'] as String, i['progress'] as int, 25),
                  )),
            ]),
    );
  }
}

class _ErasCard extends StatelessWidget {
  final String icon, label;
  final int progress;
  final VoidCallback onMinus, onPlus;
  const _ErasCard({required this.icon, required this.label, required this.progress, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    final done = progress >= 100;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text(done ? 'Complete ✓' : '$progress%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: done ? AppColors.success : AppColors.textMedium)),
          ])),
          _btn(Icons.remove, onMinus),
          const SizedBox(width: 8),
          _btn(Icons.add, onPlus),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress / 100, minHeight: 6, backgroundColor: AppColors.border, color: done ? AppColors.success : AppColors.teal),
        ),
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: AppColors.teal)),
      );
}
