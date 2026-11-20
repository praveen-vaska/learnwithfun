import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import '../animations/kid_animations.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: KidPageTransitionsBuilder(),
          TargetPlatform.iOS: KidPageTransitionsBuilder(),
          TargetPlatform.windows: KidPageTransitionsBuilder(),
          TargetPlatform.macOS: KidPageTransitionsBuilder(),
          TargetPlatform.linux: KidPageTransitionsBuilder(),
          TargetPlatform.fuchsia: KidPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryPurple,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        primary: AppColors.primaryPurple,
        secondary: AppColors.yellow,
        surface: AppColors.cardBg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: AppTextStyles.heading2(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.deepShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.button(),
        ),
      ),
    );
  }
}
