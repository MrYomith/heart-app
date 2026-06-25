import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/mio_mascot.dart';

/// FR-102 · Mobilisation milestones: sit → stand → walk, marked as achieved.
class MobilisationScreen extends ConsumerStatefulWidget {
  const MobilisationScreen({super.key});
  @override
  ConsumerState<MobilisationScreen> createState() => _MobilisationScreenState();
}

class _MobilisationScreenState extends ConsumerState<MobilisationScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final m = await ref.read(patientRepositoryProvider).mobilisation();
      if (mounted) setState(() { _items = m; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _achieve(String id) async {
    setState(() => _items = [for (final i in _items) i['id'] == id ? {...i, 'achieved': true} : i]);
    try {
      await ref.read(patientRepositoryProvider).achieveMilestone(id);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final done = _items.where((i) => i['achieved'] == true).length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Mobilisation', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : ListView(padding: const EdgeInsets.all(20), children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.bgTeal, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const MioMascot(variant: MioVariant.happy, size: 56),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Getting moving again', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text('$done of ${_items.length} milestones reached. Move at your own pace — small steps count.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMedium, height: 1.4)),
                  ])),
                ]),
              ),
              const SizedBox(height: 18),
              ..._items.map((i) => _MilestoneCard(
                    label: i['label'] as String,
                    achieved: i['achieved'] == true,
                    onAchieve: () => _achieve(i['id'] as String),
                  )),
            ]),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final String label;
  final bool achieved;
  final VoidCallback onAchieve;
  const _MilestoneCard({required this.label, required this.achieved, required this.onAchieve});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Row(children: [
        Icon(achieved ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: achieved ? AppColors.success : AppColors.border, size: 26),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark, decoration: achieved ? TextDecoration.lineThrough : null))),
        if (!achieved)
          GestureDetector(
            onTap: onAchieve,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(20)),
              child: Text('Done', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
      ]),
    );
  }
}
