import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Mio — the heart companion character.
///
/// Renders the real 3D Mio artwork from `assets/mio/<pose>.png`. Until the
/// designer's PNGs are dropped in, it falls back to a soft emoji badge so the
/// app still runs and lays out identically — add the files and Mio appears
/// everywhere automatically, matching the mockups.
enum MioVariant {
  defaultMio, // standing, hand on chest
  happy,      // winking, thumbs-up
  calm,       // calming / hands on heart
  medical,    // surgery scrubs + cap
  celebrate,  // arms up, confetti
  thriving,   // lotus meditation
  reading,    // holding a book (education)
  clipboard,  // holding the daily-plan clipboard
  waving,     // friendly wave
  sleeping,   // resting
  walking,    // rehab / activity
}

class MioMascot extends StatelessWidget {
  final MioVariant variant;
  final double size;

  const MioMascot({super.key, this.variant = MioVariant.defaultMio, this.size = 80});

  String get _asset => 'assets/mio/${_fileFor(variant)}.png';

  static String _fileFor(MioVariant v) => switch (v) {
        MioVariant.defaultMio => 'mio_default',
        MioVariant.happy => 'mio_happy',
        MioVariant.calm => 'mio_calm',
        MioVariant.medical => 'mio_scrubs',
        MioVariant.celebrate => 'mio_celebrate',
        MioVariant.thriving => 'mio_thriving',
        MioVariant.reading => 'mio_reading',
        MioVariant.clipboard => 'mio_clipboard',
        MioVariant.waving => 'mio_waving',
        MioVariant.sleeping => 'mio_sleeping',
        MioVariant.walking => 'mio_walking',
      };

  @override
  Widget build(BuildContext context) {
    // Size by height and let width follow the character's natural aspect ratio,
    // so tall full-body poses (the hero) aren't squashed into a square.
    return Image.asset(
      _asset,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => _Fallback(variant: variant, size: size),
    );
  }
}

/// Emoji-badge fallback used only when the character PNG isn't present yet.
class _Fallback extends StatelessWidget {
  final MioVariant variant;
  final double size;
  const _Fallback({required this.variant, required this.size});

  Color get _bg => switch (variant) {
        MioVariant.calm || MioVariant.medical => AppColors.teal,
        MioVariant.thriving || MioVariant.walking => AppColors.success,
        _ => AppColors.primary,
      };

  bool get _sparkle =>
      variant == MioVariant.happy || variant == MioVariant.celebrate || variant == MioVariant.thriving;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [_bg.withValues(alpha: 0.85), _bg],
          ),
          boxShadow: [BoxShadow(color: _bg.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Center(child: Text('🫀', style: TextStyle(fontSize: size * 0.45))),
      ),
      if (_sparkle)
        Positioned(top: 0, right: 0, child: Text('✨', style: TextStyle(fontSize: size * 0.22))),
    ]);
  }
}
