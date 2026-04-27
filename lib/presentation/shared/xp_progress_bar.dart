import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int xpForNext;
  final double height;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.xpForNext,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpForNext > 0 ? (currentXp / xpForNext).clamp(0.0, 1.0) : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: height,
        backgroundColor: AppColors.xpBlue.withOpacity(0.15),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpBlue),
      ),
    );
  }
}
