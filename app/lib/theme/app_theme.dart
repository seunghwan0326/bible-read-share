import 'package:flutter/material.dart';

class AppColors {
  static const wine = Color(0xFF6B2737);
  static const wineDark = Color(0xFF4A1724);
  static const cream = Color(0xFFFFF9F0);
  static const ink = Color(0xFF2B2623);
  static const muted = Color(0xFF786E68);
  static const readGreen = Color(0xFF37704F);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.wine,
      brightness: Brightness.light,
      surface: AppColors.cream,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'sans-serif', color: AppColors.ink),
      bodyLarge: TextStyle(fontFamily: 'sans-serif', color: AppColors.ink),
      titleMedium: TextStyle(fontFamily: 'sans-serif', color: AppColors.ink),
      titleLarge: TextStyle(fontFamily: 'sans-serif', color: AppColors.ink),
    ),
  );
}
