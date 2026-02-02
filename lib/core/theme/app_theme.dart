import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.black,
    );
  }

  static const TextStyle titleStyle = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    letterSpacing: 1.2,
  );

  static final TextStyle subtitleStyle = TextStyle(
    fontSize: 18,
    color: AppColors.whiteOpacity90,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle featureTextStyle = TextStyle(
    fontSize: 16,
    color: AppColors.whiteOpacity90,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static final LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primaryPurple,
      AppColors.primaryBlue,
      AppColors.primaryTeal,
    ],
  );
}
