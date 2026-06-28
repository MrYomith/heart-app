import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// FR-106 · Nutrition recovery: protein, hydration, meals, bowel movement.
class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});
  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  int _protein = 0, _hydration = 0, _meals = 0, _proteinTarget = 75, _hydrationTarget = 8;
  bool _bowel = false;
  bool _loading = true, _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ref.read(patientRepositoryProvider).nutritionToday();
      if (mounted) {
        setState(() {
        _protein = (d['protein_grams'] as num?)?.toInt() ?? 0;
        _hydration = (d['hydration_glasses'] as num?)?.toInt() ?? 0;
        _meals = (d['meals_count'] as num?)?.toInt() ?? 0;
        _bowel = d['bowel_movement'] as bool? ?? false;
        _proteinTarget = (d['protein_target'] as num?)?.toInt() ?? 75;
        _hydrationTarget = (d['hydration_target'] as num?)?.toInt() ?? 8;
        _loading = false;
      });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(patientRepositoryProvider).logNutrition(protein: _protein, hydration: _hydration, meals: _meals, bowel: _bowel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved 🤍'), behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Nutrition', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : ListView(padding: const EdgeInsets.all(20), children: [
              Text("Today's nutrition", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text('Good nutrition powers your healing. Aim for $_proteinTarget g protein and $_hydrationTarget glasses of fluid.', style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textMedium, height: 1.4)),
              const SizedBox(height: 20),
              _StepperCard(icon: '🥩', label: 'Protein', unit: 'g', value: _protein, step: 5, target: _proteinTarget, onChanged: (v) => setState(() => _protein = v)),
              _StepperCard(icon: '💧', label: 'Hydration', unit: 'glasses', value: _hydration, step: 1, target: _hydrationTarget, onChanged: (v) => setState(() => _hydration = v)),
              _StepperCard(icon: '🍽️', label: 'Meals eaten', unit: 'meals', value: _meals, step: 1, target: 5, onChanged: (v) => setState(() => _meals = v)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppDecorations.card,
                child: Row(children: [
                  const Text('🚽', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bowel movement today', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text('Important after surgery', style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textMedium)),
                  ])),
                  Switch(value: _bowel, activeThumbColor: AppColors.teal, onChanged: (v) => setState(() => _bowel = v)),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(height: 54, child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : Text('Save', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              )),
            ]),
    );
  }
}

class _StepperCard extends StatelessWidget {
  final String icon, label, unit;
  final int value, step, target;
  final ValueChanged<int> onChanged;
  const _StepperCard({required this.icon, required this.label, required this.unit, required this.value, required this.step, required this.target, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final pct = target == 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text('$value / $target $unit', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
          ])),
          _btn(Icons.remove, () => onChanged((value - step).clamp(0, 9999))),
          const SizedBox(width: 8),
          _btn(Icons.add, () => onChanged(value + step)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: pct, minHeight: 6, backgroundColor: AppColors.border, color: AppColors.teal),
        ),
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: AppColors.teal),
        ),
      );
}
