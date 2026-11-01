import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF0F6B4F);
  static const deepGreen = Color(0xFF0B3D2E);
  static const orange = Color(0xFFF28C28);
  static const cream = Color(0xFFFFF6E5);
  static const sand = Color(0xFFF4E3C1);
  static const ink = Color(0xFF1C2B26);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.orange,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    fontFamily: 'Roboto',
  );
}
