import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ImageCounterBadge extends StatelessWidget {
  final int count;

  const ImageCounterBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.blackOpacity70,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.photo, color: AppColors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
