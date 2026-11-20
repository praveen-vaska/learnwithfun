import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/illustrations/kid_scenes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/kid_animations.dart';
import '../../blocs/quiz_cubit.dart';
import 'quiz_question_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int earnedXp;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.earnedXp,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = total > 0 ? (score / total) : 0;
    int starCount = 1;
    if (percent >= 0.8) {
      starCount = 3;
    } else if (percent >= 0.5) {
      starCount = 2;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1EBFF), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.center,
          ),
        ),
        child: ConfettiCelebration(
          trigger: true,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),
                  // Trophy pops in, then floats with sparkles around it
                  SparkleBits(
                    radius: 115,
                    count: 14,
                    child: PopIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 1000),
                      fromRotation: -0.6,
                      curve: Curves.elasticOut,
                      child: const TrophyScene(size: 230, confetti: false),
                    ),
                  ),
                  const SizedBox(height: 18),
                  PopIn(
                    delay: const Duration(milliseconds: 500),
                    child: Text(
                      score >= (total / 2) ? 'Well Done!' : 'Good Effort!',
                      style: AppTextStyles.heading1(
                        color: AppColors.primaryPurple,
                      ).copyWith(fontSize: 38),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 700),
                    child: Column(
                      children: [
                        Text(
                          'You scored',
                          style: AppTextStyles.bodyLarge(
                            color: AppColors.textMedium,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CountUp(
                              value: score,
                              duration: const Duration(milliseconds: 900),
                              style: AppTextStyles.heading1().copyWith(
                                fontSize: 40,
                              ),
                            ),
                            Text(
                              ' / $total',
                              style: AppTextStyles.heading1().copyWith(
                                fontSize: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Filled purple XP pill (as in the mockup)
                  PopIn(
                    delay: const Duration(milliseconds: 1000),
                    child: PulseGlow(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.yellow,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            CountUp(
                              value: earnedXp,
                              prefix: '+ ',
                              suffix: ' XP',
                              style: AppTextStyles.heading3(color: Colors.white)
                                  .copyWith(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Stars slam in one after another, middle one bigger
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(3, (index) {
                      final isFilled = index < starCount;
                      final big = index == 1;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 6,
                          right: 6,
                          bottom: big ? 12 : 0,
                        ),
                        child: PopIn(
                          delay: Duration(milliseconds: 1300 + index * 250),
                          fromRotation: -1.2,
                          curve: Curves.elasticOut,
                          child: Wiggle(
                            autoEvery: isFilled
                                ? Duration(milliseconds: 3000 + index * 400)
                                : null,
                            child: Icon(
                              isFilled
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: isFilled
                                  ? const Color(0xFFFFC21A)
                                  : AppColors.textLight,
                              size: big ? 64 : 52,
                              shadows: isFilled
                                  ? const [
                                      Shadow(
                                        color: Color(0x66F59E0B),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 1700),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Try Again',
                            variant: AppButtonVariant.outline,
                            onPressed: () {
                              context.read<QuizCubit>().resetQuiz();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const QuizQuestionScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppButton(
                            label: 'Continue',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
