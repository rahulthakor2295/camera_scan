import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryPurple,
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
