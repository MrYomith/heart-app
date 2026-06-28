import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// PHQ-9 / PCL-5 screening (FR-124) — a moderate+ score creates a referral
/// to Psychokardiologie on the backend.
class ScreeningScreen extends ConsumerStatefulWidget {
  final String type; // 'phq9' | 'pcl5'
  const ScreeningScreen({super.key, this.type = 'phq9'});
  @override
  ConsumerState<ScreeningScreen> createState() => _ScreeningScreenState();
}

const _phq9 = [
  'Little interest or pleasure in doing things',
  'Feeling down, depressed, or hopeless',
  'Trouble falling/staying asleep, or sleeping too much',
  'Feeling tired or having little energy',
  'Poor appetite or overeating',
  'Feeling bad about yourself, or that you are a failure',
  'Trouble concentrating on things',
  'Moving/speaking slowly, or being restless',
  'Thoughts that you would be better off dead',
];
const _pcl5 = [
  'Repeated, disturbing memories of the stressful experience',
  'Repeated, disturbing dreams of the experience',
  'Suddenly feeling or acting as if it were happening again',
  'Feeling very upset when reminded of it',
  'Strong physical reactions when reminded of it',
  'Avoiding memories, thoughts, or feelings about it',
  'Avoiding external reminders of the experience',
  'Trouble remembering important parts of it',
  'Strong negative beliefs about yourself or the world',
  'Blaming yourself or others for it',
  'Strong negative feelings (fear, anger, guilt, shame)',
  'Loss of interest in activities you used to enjoy',
  'Feeling distant or cut off from people',
  'Trouble experiencing positive feelings',
  'Irritable behaviour or angry outbursts',
  'Taking risks or doing things that could harm you',
  'Being "superalert" or watchful',
  'Feeling jumpy or easily startled',
  'Difficulty concentrating',
  'Trouble falling or staying asleep',
];
const _opts = ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'];

class _ScreeningScreenState extends ConsumerState<ScreeningScreen> {
  late List<int> _answers;
  bool _busy = false;

  List<String> get _questions => widget.type == 'pcl5' ? _pcl5 : _phq9;
  String get _title => widget.type == 'pcl5' ? 'PCL-5 (Post-traumatic stress)' : 'PHQ-9 (Mood)';

  @override
  void initState() {
    super.initState();
    _answers = List.filled(_questions.length, 0);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final total = _answers.fold<int>(0, (a, b) => a + b);
    try {
      final r = await ref.read(patientRepositoryProvider).submitScreening(widget.type, total);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: Text('Score: $total · ${r.severity}', style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
          content: Text(r.referral
              ? 'Based on your answers, we have notified the Psychokardiologie team — they will reach out to support you. You are not alone. 🤍'
              : 'Thank you for checking in. Keep tracking how you feel, and tell your care team any time.',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark)),
          actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('Done'))],
        ),
      );
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit. Please try again.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: Text(_title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Over the last 2 weeks, how often have you been bothered by:',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium)),
          const SizedBox(height: 12),
          for (var i = 0; i < _questions.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: AppDecorations.card,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${i + 1}. ${_questions[i]}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (var o = 0; o < _opts.length; o++)
                    ChoiceChip(
                      label: Text(_opts[o], style: GoogleFonts.poppins(fontSize: 11)),
                      selected: _answers[i] == o,
                      onSelected: (_) => setState(() => _answers[i] = o),
                      selectedColor: AppColors.teal,
                      labelStyle: TextStyle(color: _answers[i] == o ? Colors.white : AppColors.textDark),
                      backgroundColor: AppColors.bg,
                    ),
                ]),
              ]),
            ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _busy ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
            child: Text(_busy ? 'Submitting…' : 'Submit screening', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
