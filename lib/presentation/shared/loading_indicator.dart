import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ],
    );
  }
}
