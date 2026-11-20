import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../animations/bouncing_widget.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool hasShadow;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = AppColors.cardBg,
    this.borderColor = AppColors.borderLight,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
        boxShadow: hasShadow
            ? [
                const BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return BouncingWidget(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }
}
