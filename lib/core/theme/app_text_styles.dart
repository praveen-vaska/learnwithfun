import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings with child-friendly Baloo 2 / Nunito feel
  static TextStyle heading1({Color color = AppColors.textDark}) {
    return GoogleFonts.baloo2(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: color,
      height: 1.2,
    );
  }

  static TextStyle heading2({Color color = AppColors.textDark}) {
    return GoogleFonts.baloo2(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.25,
    );
  }

  static TextStyle heading3({Color color = AppColors.textDark}) {
    return GoogleFonts.baloo2(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.3,
    );
  }

  // Body typography with Nunito rounded readability
  static TextStyle bodyLarge({Color color = AppColors.textDark}) {
    return GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle bodyMedium({Color color = AppColors.textDark}) {
    return GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle bodySmall({Color color = AppColors.textMedium}) {
    return GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.3,
    );
  }

  // Button labels
  static TextStyle button({Color color = Colors.white}) {
    return GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: 0.3,
    );
  }

  static TextStyle buttonSmall({Color color = Colors.white}) {
    return GoogleFonts.nunito(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: color,
    );
  }

  // Giant letters (e.g., A a in Lesson Screen)
  static TextStyle giantDisplay({Color color = AppColors.primaryPurple}) {
    return GoogleFonts.baloo2(
      fontSize: 72,
      fontWeight: FontWeight.w900,
      color: color,
      height: 1.0,
    );
  }

  static TextStyle bannerTitle({Color color = Colors.white}) {
    return GoogleFonts.baloo2(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: color,
      height: 1.2,
    );
  }
}
