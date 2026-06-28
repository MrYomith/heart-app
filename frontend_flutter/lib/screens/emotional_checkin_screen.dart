import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/mio_mascot.dart';

/// FR-041 · Daily emotional check-in: 5-emoji scale + 30-day mood trend.
class EmotionalCheckinScreen extends ConsumerStatefulWidget {
  const EmotionalCheckinScreen({super.key});
  @override
  ConsumerState<EmotionalCheckinScreen> createState() => _EmotionalCheckinScreenState();
}

class _EmotionalCheckinScreenState extends ConsumerState<EmotionalCheckinScreen> {
  static const _moods = [
    (1, '😢', 'Very low', AppColors.primary),
    (2, '😟', 'Low', AppColors.warning),
    (3, '😐', 'Okay', AppColors.textMedium),
    (4, '🙂', 'Good', AppColors.tealMid),
    (5, '😄', 'Great', AppColors.success),
  ];

  int? _selected;
  bool _submitting = false;
  bool _submitted = false;
  String? _careMessage;
  List<({DateTime date, double value})> _trend = [];

  @override
  void initState() {
    super.initState();
    _loadTrend();
  }

  Future<void> _loadTrend() async {
    try {
      final t = await ref.read(patientRepositoryProvider).vitalTrend('mood', days: 30);
      if (mounted) setState(() => _trend = t);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_selected == null) return;
    setState(() => _submitting = true);
    try {
      final res = await ref.read(patientRepositoryProvider).logVital('mood', _selected!.toDouble());
      await _loadTrend();
      if (mounted) {
        setState(() {
          _submitted = true;
          _careMessage = res.alertRaised ? res.message : null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save your check-in. Please try again.'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(authControllerProvider).user?.firstName ?? 'there';
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Daily Check-in', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Center(child: MioMascot(variant: _submitted ? MioVariant.happy : MioVariant.calm, size: 88)),
          const SizedBox(height: 20),
          Text(
            _submitted ? 'Thank you for checking in 🤍' : 'How are you feeling today, $name?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            _submitted ? "I've saved how you're feeling. Come back anytime." : 'Tap the face that matches your mood right now.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14.5, color: AppColors.textMedium, height: 1.4),
          ),
          const SizedBox(height: 28),

          // 5-emoji scale
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _moods.map((m) {
              final sel = _selected == m.$1;
              return GestureDetector(
                onTap: _submitted ? null : () => setState(() => _selected = m.$1),
                child: Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sel ? m.$4.withValues(alpha: 0.18) : AppColors.bgCard,
                      border: Border.all(color: sel ? m.$4 : AppColors.border, width: sel ? 2.5 : 1.5),
                    ),
                    child: Center(child: Text(m.$2, style: TextStyle(fontSize: sel ? 30 : 26))),
                  ),
                  const SizedBox(height: 6),
                  Text(m.$3, style: GoogleFonts.poppins(fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? m.$4 : AppColors.textMedium)),
                ]),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          if (_careMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.favorite_rounded, color: AppColors.teal, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(_careMessage!, style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.tealDark, height: 1.4))),
              ]),
            ),
            const SizedBox(height: 20),
          ],

          if (!_submitted)
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: (_selected == null || _submitting) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : Text('Save check-in', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),

          const SizedBox(height: 32),
          // 30-day trend
          Text('Your mood · last 30 days', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          _MoodTrend(points: _trend),
        ]),
      ),
    );
  }
}

class _MoodTrend extends StatelessWidget {
  final List<({DateTime date, double value})> points;
  const _MoodTrend({required this.points});

  Color _color(double v) {
    if (v <= 1) return AppColors.primary;
    if (v <= 2) return AppColors.warning;
    if (v <= 3) return AppColors.textLight;
    if (v <= 4) return AppColors.tealMid;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card,
        child: Center(child: Text('No check-ins yet — your trend will grow here.', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight))),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: AppDecorations.card,
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: points.map((p) {
            final h = 16 + (p.value / 5) * 88; // 1→~34px, 5→~104px
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(height: h, decoration: BoxDecoration(color: _color(p.value), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 4),
                    Text('${p.date.day}', style: GoogleFonts.poppins(fontSize: 8, color: AppColors.textLight)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
