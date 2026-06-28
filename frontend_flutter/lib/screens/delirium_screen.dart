import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/mio_mascot.dart';

/// FR-103 · Daily orientation check. Confusion on ≥2 answers alerts the nurse.
class DeliriumScreen extends ConsumerStatefulWidget {
  const DeliriumScreen({super.key});
  @override
  ConsumerState<DeliriumScreen> createState() => _DeliriumScreenState();
}

class _DeliriumScreenState extends ConsumerState<DeliriumScreen> {
  // Each question: the patient confirms whether they feel clear/oriented.
  static const _questions = [
    'Do you know what day it is today?',
    'Do you know where you are right now?',
    'Do you feel clear-headed (not foggy or confused)?',
    'Are you able to follow this conversation easily?',
  ];
  final Map<int, bool> _answers = {};
  bool _submitting = false;
  String? _resultMsg;
  bool _risk = false;

  bool get _complete => _answers.length == _questions.length;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final res = await ref.read(patientRepositoryProvider).submitDelirium(
            [for (int i = 0; i < _questions.length; i++) _answers[i] ?? false],
          );
      if (mounted) setState(() { _resultMsg = res.message; _risk = res.risk; });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit. Try again.'), behavior: SnackBarBehavior.floating));
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
        title: Text('Daily Check-in', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: _resultMsg != null ? _result() : _form(),
    );
  }

  Widget _form() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Center(child: MioMascot(variant: MioVariant.calm, size: 76)),
          const SizedBox(height: 16),
          Text('A quick orientation check', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('This helps your nurse make sure your mind is recovering well after surgery.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMedium, height: 1.4)),
          const SizedBox(height: 22),
          ..._questions.asMap().entries.map((e) => _QuestionCard(
                question: e.value,
                answer: _answers[e.key],
                onYes: () => setState(() => _answers[e.key] = true),
                onNo: () => setState(() => _answers[e.key] = false),
              )),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: (_complete && !_submitting) ? _submit : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.4), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _submitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : Text(_complete ? 'Submit check-in' : 'Answer all questions', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      );

  Widget _result() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(_risk ? Icons.notifications_active_rounded : Icons.check_circle_rounded, size: 72, color: _risk ? AppColors.warning : AppColors.success),
            const SizedBox(height: 18),
            Text(_risk ? 'Your nurse will check in' : "You're doing well", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 10),
            Text(_resultMsg!, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14.5, color: AppColors.textMedium, height: 1.5)),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text('Done', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            )),
          ]),
        ),
      );
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final bool? answer;
  final VoidCallback onYes;
  final VoidCallback onNo;
  const _QuestionCard({required this.question, required this.answer, required this.onYes, required this.onNo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(question, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.35)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _choice('Yes', answer == true, AppColors.success, onYes)),
          const SizedBox(width: 10),
          Expanded(child: _choice('Not really', answer == false, AppColors.warning, onNo)),
        ]),
      ]),
    );
  }

  Widget _choice(String label, bool selected, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Center(child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? color : AppColors.textMedium))),
        ),
      );
}
