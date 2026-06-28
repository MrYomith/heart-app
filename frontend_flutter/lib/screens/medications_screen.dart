import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/medication.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/mio_app_bar.dart';
import '../widgets/mio_mascot.dart';

/// FR-043 / FR-122 · Medication manager: list, purpose, anticoagulant flag, mark-as-taken.
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(medicationsProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Medications', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        actions: mioActions(context),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.teal)),
        error: (e, _) => Center(child: Text("Couldn't load your medications", style: GoogleFonts.poppins(color: AppColors.textMedium))),
        data: (meds) => meds.isEmpty ? _empty() : _list(context, ref, meds),
      ),
    );
  }

  Widget _list(BuildContext context, WidgetRef ref, List<Medication> meds) {
    final takenCount = meds.where((m) => m.takenToday).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Adherence header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.bgBanner, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const MioMascot(variant: MioVariant.medical, size: 56),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Today's medications", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text('$takenCount of ${meds.length} taken', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium)),
            ])),
            Text('$takenCount/${meds.length}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.teal)),
          ]),
        ),
        const SizedBox(height: 16),
        ...meds.map((m) => _MedCard(med: m, onTaken: () => ref.read(medicationsProvider.notifier).markTaken(m.id))),
      ],
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const MioMascot(variant: MioVariant.calm, size: 80),
            const SizedBox(height: 16),
            Text('No medications listed', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text('Your medications will appear here.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium)),
          ]),
        ),
      );
}

class _MedCard extends StatelessWidget {
  final Medication med;
  final VoidCallback onTaken;
  const _MedCard({required this.med, required this.onTaken});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('💊', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(med.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark))),
              const SizedBox(width: 6),
              Text(med.dose, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
            ]),
            Text(med.schedule, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
          ])),
        ]),
        if (med.purpose != null) ...[
          const SizedBox(height: 10),
          Text(med.purpose!, style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textMedium, height: 1.4)),
        ],
        if (med.isAnticoagulant) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Flexible(child: Text('Blood thinner — never stop without asking your surgeon.', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.warning))),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 46,
          child: med.takenToday
              ? Container(
                  decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text('Taken today', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ])),
                )
              : ElevatedButton(
                  onPressed: onTaken,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('Mark as taken', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
        ),
      ]),
    );
  }
}
