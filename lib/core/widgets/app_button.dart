import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../animations/bouncing_widget.dart';

enum AppButtonVariant { primary, secondary, yellow, outline, white }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 54,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Border? border;
    List<BoxShadow> shadows = [
      const BoxShadow(
        color: AppColors.shadow,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ];

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.primaryPurple;
        textColor = Colors.white;
        shadows = [
          const BoxShadow(
            color: Color(0x3D7952F5),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ];
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.softPurple;
        textColor = AppColors.primaryPurple;
        break;
      case AppButtonVariant.yellow:
        bg = AppColors.yellow;
        textColor = AppColors.textDark;
        shadows = [
          const BoxShadow(
            color: Color(0x3DF59E0B),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ];
        break;
      case AppButtonVariant.white:
        bg = Colors.white;
        textColor = AppColors.primaryPurple;
        shadows = [
          const BoxShadow(
            color: Color(0x40311B92),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ];
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        textColor = AppColors.primaryPurple;
        border = Border.all(color: AppColors.primaryPurple, width: 2);
        shadows = [];
        break;
    }

    final isEnabled = onPressed != null && !isLoading;

    return BouncingWidget(
      onTap: isEnabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(height / 2),
            border: border,
            boxShadow: isEnabled ? shadows : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[icon!, const SizedBox(width: 8)],
                      Text(
                        label,
                        style: AppTextStyles.button(color: textColor),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
