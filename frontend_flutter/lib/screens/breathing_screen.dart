import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

/// FR-063 / FR-101 · Guided breathing coach: animated inhale/exhale, breath counter,
/// logs the session for clinician compliance tracking.
class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});
  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen> with SingleTickerProviderStateMixin {
  static const _targetBreaths = 5;

  late final AnimationController _c;
  bool _running = false;
  int _breaths = 0;
  bool _done = false;
  int _todayCount = 0, _target = 3;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _c.addStatusListener((s) {
      if (!_running) return;
      if (s == AnimationStatus.completed) {
        _c.reverse();
      } else if (s == AnimationStatus.dismissed) {
        setState(() => _breaths++);
        if (_breaths >= _targetBreaths) {
          _finish();
        } else {
          _c.forward();
        }
      }
      setState(() {});
    });
    _loadToday();
  }

  Future<void> _loadToday() async {
    try {
      final t = await ref.read(patientRepositoryProvider).breathingToday();
      if (mounted) setState(() { _todayCount = t.todayCount; _target = t.target; });
    } catch (_) {}
  }

  void _start() {
    setState(() { _running = true; _breaths = 0; });
    _c.forward();
  }

  Future<void> _finish() async {
    _c.stop();
    setState(() { _running = false; _done = true; });
    try {
      final t = await ref.read(patientRepositoryProvider).logBreathing(type: 'breathing', count: _breaths);
      if (mounted) setState(() { _todayCount = t.todayCount; _target = t.target; });
    } catch (_) {}
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String get _phaseText {
    if (!_running) return _done ? 'Well done 🤍' : 'Tap start when ready';
    return _c.status == AnimationStatus.reverse ? 'Breathe out…' : 'Breathe in…';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgTeal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Breathing Coach', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                'Slow, gentle breaths help your lungs recover and lower stress. Follow the circle for $_targetBreaths breaths.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMedium, height: 1.4),
              ),
            ),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final scale = 0.55 + (_c.value * 0.45); // 0.55 → 1.0
                    return Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                        width: 240, height: 240,
                        child: Center(
                          child: Container(
                            width: 240 * scale, height: 240 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [AppColors.tealMid.withValues(alpha: 0.9), AppColors.teal]),
                              boxShadow: [BoxShadow(color: AppColors.teal.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 4)],
                            ),
                            child: Center(child: Text('🫁', style: TextStyle(fontSize: 60 * scale))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(_phaseText, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
                      const SizedBox(height: 8),
                      Text(_running ? 'Breath $_breaths of $_targetBreaths' : 'Today: $_todayCount of $_target sessions',
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMedium)),
                    ]);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity, height: 54,
                child: _done
                    ? ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: Text('Done', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                      )
                    : ElevatedButton(
                        onPressed: _running ? _finish : _start,
                        style: ElevatedButton.styleFrom(backgroundColor: _running ? AppColors.warning : AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: Text(_running ? 'Finish early' : 'Start breathing', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
