import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HealthBarPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color? color;

  HealthBarPainter({required this.progress, this.color});

  Color get _barColor {
    if (color != null) return color!;
    if (progress >= 0.7) return AppColors.hpGreen;
    if (progress >= 0.4) return AppColors.hpYellow;
    return AppColors.hpRed;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    final fgPaint = Paint()
      ..color = _barColor
      ..style = PaintingStyle.fill;

    final radius = Radius.circular(size.height / 2);
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );
    final filled = (size.width * progress.clamp(0.0, 1.0));
    final fgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, filled, size.height),
      radius,
    );

    canvas.drawRRect(bgRect, bgPaint);
    if (filled > 0) canvas.drawRRect(fgRect, fgPaint);
  }

  @override
  bool shouldRepaint(covariant HealthBarPainter old) =>
      old.progress != progress || old.color != color;
}

class HealthBar extends StatelessWidget {
  final int current;
  final int max;
  final double height;

  const HealthBar({
    super.key,
    required this.current,
    this.max = 100,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HealthBarPainter(progress: current / max),
      child: SizedBox(height: height, width: double.infinity),
    );
  }
}
