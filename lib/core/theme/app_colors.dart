import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Purples
  static const Color primaryPurple = Color(0xFF7952F5);
  static const Color deepPurple = Color(0xFF6842E8);
  static const Color darkPurple = Color(0xFF4C1D95);
  static const Color lavender = Color(0xFFA68BFF);
  static const Color softPurple = Color(0xFFEDE9FE);
  static const Color purpleLight = Color(0xFFF3E8FF);

  // Playful Accents
  static const Color yellow = Color(0xFFFFE16A);
  static const Color yellowDark = Color(0xFFF59E0B);
  static const Color skyBlue = Color(0xFF83D9FA);
  static const Color blue = Color(0xFF3B82F6);
  static const Color lime = Color(0xFFC4ED65);
  static const Color green = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFDCFCE7);
  static const Color pink = Color(0xFFFFB7CB);
  static const Color pinkDark = Color(0xFFF43F5E);
  static const Color orange = Color(0xFFFB923C);
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEE2E2);

  // Backgrounds & Neutrals
  static const Color background = Color(0xFFF7F5FC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFFFF4E9);
  static const Color surfaceLight = Color(0xFFFAF8FF);

  // Text Colors
  static const Color textDark = Color(0xFF292536);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Card Borders & Shadows
  static const Color borderLight = Color(0xFFEDE9FE);
  static const Color shadow = Color(0x147952F5);
  static const Color deepShadow = Color(0x286842E8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6842E8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFDE047), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlow = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F3FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
