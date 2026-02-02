import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'FlashScan',
          style: AppTheme.titleStyle,
        ),
        const SizedBox(height: 16),
        Text(
          'Lightning Fast Detection',
          style: AppTheme.subtitleStyle,
        ),
      ],
    );
  }
}
