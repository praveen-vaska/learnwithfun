import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/kid_animations.dart';
import '../../core/illustrations/kid_scenes.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../blocs/quiz_cubit.dart';
import 'quiz_question_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int earnedXp;
  final int levelNumber;
  final int starsEarned;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.earnedXp,
    this.levelNumber = 1,
    this.starsEarned = 1,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = total > 0 ? (score / total) : 0;
    final int finalStars = starsEarned > 0
        ? starsEarned
        : (percent >= 0.75 ? 3 : (percent >= 0.5 ? 2 : 1));

    final bool hasNextLevel = levelNumber < 10;

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(),
                  // Trophy scene with sparkles
                  SparkleBits(
                    radius: 110,
                    count: 14,
                    child: PopIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 1000),
                      fromRotation: -0.6,
                      curve: Curves.elasticOut,
                      child: const TrophyScene(size: 200, confetti: false),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Level Finished Title
                  PopIn(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Level $levelNumber Completed! 🌟',
                        style: AppTextStyles.buttonSmall(
                          color: AppColors.primaryPurple,
                        ).copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  PopIn(
                    delay: const Duration(milliseconds: 550),
                    child: Text(
                      score >= (total / 2) ? 'Super Job!' : 'Great Effort!',
                      style: AppTextStyles.heading1(
                        color: AppColors.primaryPurple,
                      ).copyWith(fontSize: 34),
                    ),
                  ),
                  const SizedBox(height: 6),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 700),
                    child: Column(
                      children: [
                        Text(
                          'You got',
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
                                fontSize: 38,
                              ),
                            ),
                            Text(
                              ' / $total',
                              style: AppTextStyles.heading1().copyWith(
                                fontSize: 38,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // XP Pill
                  PopIn(
                    delay: const Duration(milliseconds: 900),
                    child: PulseGlow(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
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
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            CountUp(
                              value: earnedXp,
                              prefix: '+ ',
                              suffix: ' XP',
                              style: AppTextStyles.heading3(color: Colors.white)
                                  .copyWith(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3 Stars Slam-In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(3, (index) {
                      final isFilled = index < finalStars;
                      final big = index == 1;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 6,
                          right: 6,
                          bottom: big ? 10 : 0,
                        ),
                        child: PopIn(
                          delay: Duration(milliseconds: 1100 + index * 200),
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
                              size: big ? 60 : 48,
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

                  // Actions
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 1400),
                    child: Column(
                      children: [
                        if (hasNextLevel)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppButton(
                              label: 'Next Level ${levelNumber + 1} 🚀',
                              width: double.infinity,
                              height: 52,
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                AppAudioService.instance.playTapSound();
                                context.read<QuizCubit>().unlockNextLevel();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const QuizQuestionScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Replay 🔄',
                                variant: AppButtonVariant.outline,
                                height: 50,
                                onPressed: () {
                                  AppAudioService.instance.playTapSound();
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
                            const SizedBox(width: 14),
                            Expanded(
                              child: AppButton(
                                label: 'Level Map 🗺️',
                                variant: hasNextLevel
                                    ? AppButtonVariant.outline
                                    : AppButtonVariant.primary,
                                height: 50,
                                onPressed: () {
                                  AppAudioService.instance.playTapSound();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
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
