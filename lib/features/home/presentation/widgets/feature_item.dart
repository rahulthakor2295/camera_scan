import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.whiteOpacity90,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTheme.featureTextStyle,
        ),
      ],
    );
  }
}
