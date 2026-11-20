import 'package:flutter/material.dart';

import '../animations/bouncing_widget.dart';
import '../animations/kid_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_vector_graphic.dart';

/// Pastel palette per category, matching the mockup's colourful tiles.
class CategoryPalette {
  final Color top;
  final Color bottom;
  final Color accent;

  const CategoryPalette(this.top, this.bottom, this.accent);

  static const yellow = CategoryPalette(
    Color(0xFFFFF1B8),
    Color(0xFFFFE07A),
    Color(0xFFF59E0B),
  );
  static const blue = CategoryPalette(
    Color(0xFFDDF4FF),
    Color(0xFFA9E2FB),
    Color(0xFF0EA5E9),
  );
  static const green = CategoryPalette(
    Color(0xFFEAF9C8),
    Color(0xFFC4ED65),
    Color(0xFF65A30D),
  );
  static const pink = CategoryPalette(
    Color(0xFFFFE3EC),
    Color(0xFFFFB7CB),
    Color(0xFFF43F5E),
  );
  static const purple = CategoryPalette(
    Color(0xFFF1EBFF),
    Color(0xFFD6C8FF),
    Color(0xFF7952F5),
  );
  static const orange = CategoryPalette(
    Color(0xFFFFEEDD),
    Color(0xFFFFCB9A),
    Color(0xFFF97316),
  );

  static const List<CategoryPalette> cycle = [
    yellow,
    blue,
    green,
    pink,
    orange,
    purple,
  ];

  static CategoryPalette forId(String id, int index) {
    switch (id) {
      case 'abc':
        return yellow;
      case '123':
        return blue;
      case 'animals':
        return green;
      case 'shapes':
        return pink;
      default:
        return cycle[index % cycle.length];
    }
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String assetPath;
  final CategoryPalette palette;
  final VoidCallback onTap;
  final double? progress;
  final int index;

  const CategoryTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.palette,
    required this.onTap,
    this.progress,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [palette.top, palette.bottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.accent.withAlpha(45),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Decorative bubbles
              Positioned(
                right: -18,
                top: -18,
                child: _bubble(64, Colors.white.withAlpha(90)),
              ),
              Positioned(
                left: -10,
                top: 40,
                child: _bubble(26, Colors.white.withAlpha(70)),
              ),
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 4),
                      child: Wiggle(
                        autoEvery: Duration(milliseconds: 4200 + index * 900),
                        angle: 0.08,
                        child: FloatBob(
                          distance: 4,
                          rotation: 0.03,
                          phase: index * 0.21,
                          child: AppVectorGraphic(assetPath: assetPath),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(235),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading3(
                            color: AppColors.textDark,
                          ).copyWith(fontSize: 15, height: 1.1),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall(
                            color: AppColors.textMedium,
                          ).copyWith(fontSize: 11),
                        ),
                        if (progress != null) ...[
                          const SizedBox(height: 5),
                          AnimatedFillBar(
                            value: progress!,
                            height: 5,
                            color: palette.accent,
                            trackColor: palette.top,
                            delay: Duration(milliseconds: 250 + index * 80),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
