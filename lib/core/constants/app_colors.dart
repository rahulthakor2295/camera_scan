import 'package:flutter/material.dart';

class AppColors {
  static final Color primaryPurple = Colors.purple.shade900;
  static final Color primaryBlue = Colors.blue.shade900;
  static final Color primaryTeal = Colors.teal.shade900;

  static const Color white = Colors.white;
  static final Color whiteOpacity20 = Colors.white.withValues(alpha: 0.2);
  static final Color whiteOpacity60 =
      Colors.white.withValues(alpha: 0.6); // For backgrounds
  static final Color whiteOpacity70 = Colors.white.withValues(alpha: 0.7);
  static final Color whiteOpacity90 = Colors.white.withValues(alpha: 0.9);

  static const Color black = Colors.black;
  static final Color blackOpacity60 = Colors.black.withValues(alpha: 0.6);
  static final Color blackOpacity70 = Colors.black.withValues(alpha: 0.7);

  static const Color yellow = Colors.yellow;
  static const Color green = Colors.green;
  static const Color red = Colors.red;
}
