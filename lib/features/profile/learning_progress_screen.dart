import 'package:flutter/material.dart';

import '../../core/animations/kid_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/animations/fade_slide_in.dart';

class LearningProgressScreen extends StatelessWidget {
  const LearningProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Learning Progress', style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // 1. Circular Overall Progress (Matching Reference Image)
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 130,
                              height: 130,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 0.75),
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeOutCubic,
                                builder: (context, v, _) =>
                                    CircularProgressIndicator(
                                      value: v,
                                      strokeWidth: 12,
                                      backgroundColor: AppColors.softPurple,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            AppColors.green,
                                          ),
                                      strokeCap: StrokeCap.round,
                                    ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CountUp(
                                  value: 75,
                                  suffix: '%',
                                  duration: const Duration(milliseconds: 1500),
                                  style: AppTextStyles.heading1().copyWith(
                                    fontSize: 32,
                                    color: AppColors.green,
                                  ),
                                ),
                                Text(
                                  'Completed',
                                  style: AppTextStyles.bodySmall(
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Overall Learning Progress',
                        style: AppTextStyles.heading2().copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You are doing wonderfully! Keep exploring new topics.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Category Performance Bars
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category Progress',
                        style: AppTextStyles.heading3(),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryRow(
                        'ABC Alphabets',
                        1.0,
                        '100%',
                        AppColors.green,
                      ),
                      const SizedBox(height: 14),
                      _buildCategoryRow(
                        '123 Numbers',
                        0.8,
                        '80%',
                        AppColors.blue,
                      ),
                      const SizedBox(height: 14),
                      _buildCategoryRow(
                        'Animals World',
                        0.6,
                        '60%',
                        AppColors.orange,
                      ),
                      const SizedBox(height: 14),
                      _buildCategoryRow(
                        'Shapes & Colors',
                        0.7,
                        '70%',
                        AppColors.primaryPurple,
                      ),
                      const SizedBox(height: 14),
                      _buildCategoryRow(
                        'Fruits & Veggies',
                        0.5,
                        '50%',
                        AppColors.lime,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    String title,
    double progress,
    String percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyMedium()),
            Text(percentage, style: AppTextStyles.buttonSmall(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedFillBar(
          value: progress,
          height: 8,
          color: color,
          delay: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
