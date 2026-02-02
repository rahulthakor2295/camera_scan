import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.whiteOpacity20,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 3,
        ),
      ),
      child: const Icon(
        Icons.qr_code_scanner,
        size: 60,
        color: AppColors.white,
      ),
    );
  }
}
