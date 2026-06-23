import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressRing extends StatelessWidget {
  final double value;
  final double max;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final String? label;
  final String? sublabel;

  const ProgressRing({
    super.key,
    required this.value,
    required this.max,
    this.size = 80,
    this.strokeWidth = 7,
    this.color = AppColors.teal,
    this.trackColor = const Color(0xFFE8E8E8),
    this.label,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: (value / max).clamp(0.0, 1.0),
          color: color,
          trackColor: trackColor,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: size > 70 ? 17 : 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1,
                  ),
                ),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: TextStyle(
                    fontSize: size > 70 ? 9 : 8,
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({required this.progress, required this.color, required this.trackColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
