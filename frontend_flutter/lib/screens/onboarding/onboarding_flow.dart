import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../services/onboarding_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../auth/auth_widgets.dart';

/// 10-step onboarding (FR-010–015), streamlined into the data-bearing screens:
/// Welcome → Medical → Health background → GAD-7 → Connect to hospital → Finish.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});
  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _page = PageController();
  int _index = 0;
  bool _submitting = false;
  String? _error;

  // Collected data
  String? _surgeryType;
  DateTime? _surgeryDate;
  bool _notScheduled = false;
  String? _nyha;
  final _conditions = TextEditingController();
  final _allergies = TextEditingController();
  final List<int> _gad7 = List.filled(7, -1);

  // Enrollment
  String _enrollStatus = 'none'; // none | approved | pending
  String? _enrollHospital;

  static const _totalPages = 6;

  static const _surgeryTypes = [
    ('cabg', 'CABG (bypass)'),
    ('valve', 'Valve repair / replacement'),
    ('tavi', 'TAVI'),
    ('aortic', 'Aortic surgery'),
    ('combined', 'Combined procedure'),
    ('none', 'Not sure yet'),
  ];

  static const _nyhaOptions = [
    ('I', 'No limitation of activity'),
    ('II', 'Slight limitation, comfortable at rest'),
    ('III', 'Marked limitation, comfortable only at rest'),
    ('IV', 'Symptoms even at rest'),
  ];

  static const _gad7Questions = [
    'Feeling nervous, anxious, or on edge',
    'Not being able to stop or control worrying',
    'Worrying too much about different things',
    'Trouble relaxing',
    "Being so restless that it's hard to sit still",
    'Becoming easily annoyed or irritable',
    'Feeling afraid, as if something awful might happen',
  ];
  static const _gad7Options = ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'];

  @override
  void dispose() {
    _page.dispose();
    _conditions.dispose();
    _allergies.dispose();
    super.dispose();
  }

  bool get _canAdvance {
    switch (_index) {
      case 1: // medical
        return _surgeryType != null && (_notScheduled || _surgeryDate != null) && _nyha != null;
      case 3: // GAD-7 — all answered
        return !_gad7.contains(-1);
      default:
        return true;
    }
  }

  void _next() {
    setState(() => _error = null);
    if (_index < _totalPages - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
    }
  }

  void _back() {
    if (_index > 0) _page.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
  }

  List<String> _split(String s) =>
      s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<void> _finish() async {
    setState(() { _submitting = true; _error = null; });
    try {
      await OnboardingRepository().complete(
        surgeryType: _surgeryType,
        surgeryDate: _notScheduled || _surgeryDate == null ? null : _surgeryDate!.toIso8601String().split('T').first,
        nyhaClass: _nyha,
        conditions: _split(_conditions.text),
        allergies: _split(_allergies.text),
        gad7Answers: _gad7.where((v) => v >= 0).toList(),
      );
      await ref.read(authControllerProvider.notifier).refreshUser();
      // AuthGate now routes to the home experience.
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(children: [
                if (_index > 0)
                  IconButton(onPressed: _back, icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textMedium))
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_index + 1) / _totalPages,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_index + 1}/$_totalPages', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
              ]),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _welcomePage(),
                  _medicalPage(),
                  _backgroundPage(),
                  _gad7Page(),
                  _hospitalPage(),
                  _finishPage(),
                ],
              ),
            ),
            // Footer nav
            if (_index < _totalPages - 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: MioPrimaryButton(
                  label: _index == 0 ? "Let's begin" : 'Continue',
                  onPressed: _canAdvance ? _next : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _scroll(List<Widget> children) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _title(String t, String sub) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: GoogleFonts.inter(fontSize: 23, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 6),
        Text(sub, style: GoogleFonts.inter(fontSize: 14.5, color: AppColors.textMedium, height: 1.4)),
        const SizedBox(height: 22),
      ]);

  // ── Page 0: Welcome ──
  Widget _welcomePage() => Center(
        child: _scroll([
          const SizedBox(height: 20),
          const Center(child: MioMascot(variant: MioVariant.happy, size: 110)),
          const SizedBox(height: 28),
          Text("Welcome — I'm Mio 🤍", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Text(
            "I'll be your companion through every step of your heart journey. First, a few questions so I can personalise everything for you. It takes about 3 minutes, and you can change answers later.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textMedium, height: 1.55),
          ),
        ]),
      );

  // ── Page 1: Medical ──
  Widget _medicalPage() => _scroll([
        _title('About your surgery', 'This helps me tailor your plan and education to your procedure (FR-011).'),
        Text('Surgery type', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 8),
        ..._surgeryTypes.map((t) => _radioTile(t.$2, _surgeryType == t.$1, () => setState(() => _surgeryType = t.$1))),
        const SizedBox(height: 18),
        Text('Surgery date', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _notScheduled ? null : () async {
                final now = DateTime.now();
                final d = await showDatePicker(context: context, initialDate: now, firstDate: now.subtract(const Duration(days: 365)), lastDate: now.add(const Duration(days: 730)));
                if (d != null) setState(() => _surgeryDate = d);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.teal),
              label: Text(_surgeryDate == null ? 'Pick a date' : '${_surgeryDate!.day}.${_surgeryDate!.month}.${_surgeryDate!.year}',
                  style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: AppColors.border, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ]),
        _checkTile('Not scheduled yet', _notScheduled, (v) => setState(() { _notScheduled = v; if (v) _surgeryDate = null; })),
        const SizedBox(height: 18),
        Text('How does your heart limit you? (NYHA)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 8),
        ..._nyhaOptions.map((t) => _radioTile('Class ${t.$1} — ${t.$2}', _nyha == t.$1, () => setState(() => _nyha = t.$1))),
      ]);

  // ── Page 2: Background ──
  Widget _backgroundPage() => _scroll([
        _title('Your health background', 'Optional, but it helps your care team. Separate items with commas.'),
        MioTextField(controller: _conditions, label: 'Existing conditions', hint: 'e.g. Diabetes, High blood pressure', icon: Icons.medical_information_outlined, textInputAction: TextInputAction.next),
        const SizedBox(height: 18),
        MioTextField(controller: _allergies, label: 'Allergies', hint: 'e.g. Penicillin', icon: Icons.warning_amber_rounded, textInputAction: TextInputAction.done),
      ]);

  // ── Page 3: GAD-7 ──
  Widget _gad7Page() => _scroll([
        _title('How have you been feeling?', 'Over the last 2 weeks, how often have you been bothered by the following? (GAD-7, FR-013)'),
        ...List.generate(_gad7Questions.length, (q) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: AppDecorations.card,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${q + 1}. ${_gad7Questions[q]}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.35)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: List.generate(4, (opt) {
                  final sel = _gad7[q] == opt;
                  return GestureDetector(
                    onTap: () => setState(() => _gad7[q] = opt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.teal : AppColors.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? AppColors.teal : AppColors.border, width: 1.5),
                      ),
                      child: Text(_gad7Options[opt], style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textMedium)),
                    ),
                  );
                })),
              ]),
            )),
      ]);

  // ── Page 4: Hospital ──
  Widget _hospitalPage() => _HospitalStep(
        status: _enrollStatus,
        hospitalName: _enrollHospital,
        onEnrolled: (status, name) => setState(() { _enrollStatus = status; _enrollHospital = name; }),
      );

  // ── Page 5: Finish ──
  Widget _finishPage() => Center(
        child: _scroll([
          const SizedBox(height: 16),
          const Center(child: MioMascot(variant: MioVariant.celebrate, size: 110)),
          const SizedBox(height: 24),
          Text("You're all set! 🎉", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Text(
            _enrollStatus == 'approved'
                ? "You're connected to $_enrollHospital. I've personalised your plan — let's begin your journey together."
                : _enrollStatus == 'pending'
                    ? "Your request to $_enrollHospital is awaiting approval. You can start using your plan now; your care team features unlock once they approve you."
                    : "I've personalised your plan. You can connect with your hospital anytime from More. Let's begin.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textMedium, height: 1.55),
          ),
          const SizedBox(height: 28),
          MioErrorBanner(message: _error),
          MioPrimaryButton(label: 'Enter MioHeart', loading: _submitting, onPressed: _finish),
        ]),
      );

  // ── small reusable tiles ──
  Widget _radioTile(String label, bool selected, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.tealLight : AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.teal : AppColors.border, width: 1.5),
          ),
          child: Row(children: [
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: selected ? AppColors.teal : AppColors.textLight, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: AppColors.textDark))),
          ]),
        ),
      );

  Widget _checkTile(String label, bool value, ValueChanged<bool> onChanged) => GestureDetector(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Icon(value ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: value ? AppColors.teal : AppColors.textLight),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMedium)),
          ]),
        ),
      );
}

/// Hospital connection step — code OR pick from a list, or skip.
class _HospitalStep extends StatefulWidget {
  final String status;
  final String? hospitalName;
  final void Function(String status, String? name) onEnrolled;
  const _HospitalStep({required this.status, required this.hospitalName, required this.onEnrolled});
  @override
  State<_HospitalStep> createState() => _HospitalStepState();
}

class _HospitalStepState extends State<_HospitalStep> {
  final _repo = OnboardingRepository();
  final _code = TextEditingController();
  bool _useCode = true;
  bool _busy = false;
  String? _error;
  List<Hospital> _hospitals = [];
  String? _selected;

  @override
  void initState() {
    super.initState();
    _repo.hospitals().then((h) { if (mounted) setState(() => _hospitals = h.where((x) => x.type == 'hospital').toList()); }).catchError((_) {});
  }

  @override
  void dispose() { _code.dispose(); super.dispose(); }

  Future<void> _connect() async {
    setState(() { _busy = true; _error = null; });
    try {
      if (_useCode) {
        if (_code.text.trim().isEmpty) throw Exception('Enter the code from your clinic.');
        final status = await _repo.enrollByCode(_code.text.trim());
        widget.onEnrolled(status, 'your hospital');
      } else {
        if (_selected == null) throw Exception('Please choose your hospital.');
        final status = await _repo.requestHospital(_selected!);
        final name = _hospitals.firstWhere((h) => h.id == _selected).name;
        widget.onEnrolled(status, name);
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status != 'none') {
      final approved = widget.status == 'approved';
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(children: [
          const SizedBox(height: 24),
          Icon(approved ? Icons.verified_rounded : Icons.hourglass_top_rounded, size: 64, color: approved ? AppColors.success : AppColors.warning),
          const SizedBox(height: 16),
          Text(approved ? 'Connected!' : 'Request sent', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(
            approved
                ? "You're linked to ${widget.hospitalName}. Your care team can now support you."
                : "${widget.hospitalName} will review your request. You can keep going meanwhile.",
            textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14.5, color: AppColors.textMedium, height: 1.5),
          ),
        ]),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Connect with your hospital', style: GoogleFonts.inter(fontSize: 23, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 6),
        Text('So your care team can support your recovery (FR-014). You can also skip and do this later.', style: GoogleFonts.inter(fontSize: 14.5, color: AppColors.textMedium, height: 1.4)),
        const SizedBox(height: 20),
        // toggle
        Row(children: [
          _toggle('I have a code', _useCode, () => setState(() => _useCode = true)),
          const SizedBox(width: 10),
          _toggle('Find my hospital', !_useCode, () => setState(() => _useCode = false)),
        ]),
        const SizedBox(height: 18),
        if (_useCode)
          MioTextField(controller: _code, label: 'Clinic code', hint: 'e.g. HERZ-2026', icon: Icons.vpn_key_outlined, textInputAction: TextInputAction.done)
        else
          Column(children: _hospitals.map((h) => GestureDetector(
                onTap: () => setState(() => _selected = h.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: _selected == h.id ? AppColors.tealLight : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selected == h.id ? AppColors.teal : AppColors.border, width: 1.5),
                  ),
                  child: Row(children: [
                    const Icon(Icons.local_hospital_outlined, color: AppColors.teal, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(h.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark))),
                    if (h.city != null) Text(h.city!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight)),
                  ]),
                ),
              )).toList()),
        const SizedBox(height: 16),
        MioErrorBanner(message: _error),
        MioPrimaryButton(label: _useCode ? 'Connect' : 'Send request', loading: _busy, onPressed: _connect),
      ]),
    );
  }

  Widget _toggle(String label, bool active, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? AppColors.teal : AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: active ? AppColors.teal : AppColors.border, width: 1.5),
            ),
            child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textMedium)),
          ),
        ),
      );
}
