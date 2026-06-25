import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/mio_mascot.dart';

/// FR-100 · Pain tracking: 3 sliders (rest/cough/move) 0–10. Any score ≥7 alerts the nurse.
class PainTrackingScreen extends ConsumerStatefulWidget {
  const PainTrackingScreen({super.key});
  @override
  ConsumerState<PainTrackingScreen> createState() => _PainTrackingScreenState();
}

class _PainTrackingScreenState extends ConsumerState<PainTrackingScreen> {
  double _rest = 0, _cough = 0, _move = 0;
  bool _submitting = false;
  bool _submitted = false;
  bool _nurseAlerted = false;

  Color _painColor(double v) {
    if (v >= 7) return AppColors.primary;
    if (v >= 4) return AppColors.warning;
    return AppColors.success;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final repo = ref.read(patientRepositoryProvider);
    bool alerted = false;
    try {
      for (final entry in [('pain_rest', _rest), ('pain_cough', _cough), ('pain_move', _move)]) {
        final res = await repo.logVital(entry.$1, entry.$2);
        if (res.alertRaised) alerted = true;
      }
      if (mounted) setState(() { _submitted = true; _nurseAlerted = alerted; });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Pain Check', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: _submitted ? _confirmation() : _form(),
    );
  }

  Widget _form() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          const Center(child: MioMascot(variant: MioVariant.medical, size: 84)),
          const SizedBox(height: 18),
          Text('How is your pain right now?', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('0 = no pain, 10 = worst pain. Be honest — this helps your nurse care for you.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMedium, height: 1.4)),
          const SizedBox(height: 28),
          _PainSlider(label: 'At rest', value: _rest, color: _painColor(_rest), onChanged: (v) => setState(() => _rest = v)),
          _PainSlider(label: 'When coughing', value: _cough, color: _painColor(_cough), onChanged: (v) => setState(() => _cough = v)),
          _PainSlider(label: 'When moving', value: _move, color: _painColor(_move), onChanged: (v) => setState(() => _move = v)),
          const SizedBox(height: 16),
          if (_rest >= 7 || _cough >= 7 || _move >= 7)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.notifications_active_rounded, color: AppColors.primaryDark, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('A score of 7 or higher will alert your nurse right away.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryDark, fontWeight: FontWeight.w600))),
              ]),
            ),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _submitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : Text('Submit pain scores', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      );

  Widget _confirmation() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(_nurseAlerted ? Icons.notifications_active_rounded : Icons.check_circle_rounded, size: 72, color: _nurseAlerted ? AppColors.primary : AppColors.success),
            const SizedBox(height: 18),
            Text(_nurseAlerted ? 'Your nurse has been alerted' : 'Pain scores saved', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 10),
            Text(
              _nurseAlerted
                  ? "Because your pain is high, we've notified your nurse and they'll check on you shortly. Hang in there. 🤍"
                  : 'Thank you. Keeping track helps your care team manage your comfort.',
              textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14.5, color: AppColors.textMedium, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52, width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text('Done', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      );
}

class _PainSlider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;
  const _PainSlider({required this.label, required this.value, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15), border: Border.all(color: color, width: 2)),
            child: Center(child: Text('${value.round()}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: color))),
          ),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color, thumbColor: color, inactiveTrackColor: AppColors.border, overlayColor: color.withValues(alpha: 0.15), trackHeight: 6,
          ),
          child: Slider(value: value, min: 0, max: 10, divisions: 10, label: '${value.round()}', onChanged: onChanged),
        ),
      ]),
    );
  }
}
