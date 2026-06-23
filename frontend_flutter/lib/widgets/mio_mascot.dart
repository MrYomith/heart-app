import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum MioVariant { happy, calm, medical, celebrate, thriving, defaultMio }

class MioMascot extends StatelessWidget {
  final MioVariant variant;
  final double size;

  const MioMascot({super.key, this.variant = MioVariant.defaultMio, this.size = 80});

  Color get _bgColor {
    switch (variant) {
      case MioVariant.calm:
      case MioVariant.medical:
        return AppColors.teal;
      case MioVariant.thriving:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  bool get _hasSparkle =>
      variant == MioVariant.happy || variant == MioVariant.celebrate || variant == MioVariant.thriving;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [_bgColor.withOpacity(0.85), _bgColor],
              ),
              boxShadow: [
                BoxShadow(color: _bgColor.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: Text('🫀', style: TextStyle(fontSize: size * 0.45)),
            ),
          ),
          if (_hasSparkle)
            Positioned(
              top: 0,
              right: 0,
              child: Text('✨', style: TextStyle(fontSize: size * 0.22)),
            ),
        ],
      ),
    );
  }
}
