import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/kid_animations.dart';
import '../../blocs/quiz_cubit.dart';
import '../../blocs/user_cubit.dart';
import 'quiz_result_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  final GlobalKey<ConfettiCelebrationState> _confettiKey =
      GlobalKey<ConfettiCelebrationState>();

  @override
  Widget build(BuildContext context) {
    final quizState = context.watch<QuizCubit>().state;
    final currentQuestion = quizState.currentQuestion;

    if (currentQuestion == null || quizState.isQuizCompleted) {
      // Navigate to results
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Award XP to user profile
        context.read<UserCubit>().addXp(quizState.earnedXp);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              score: quizState.score,
              total: quizState.questions.length,
              earnedXp: quizState.earnedXp,
            ),
          ),
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryPurple),
        ),
      );
    }

    final currentIndex = quizState.currentQuestionIndex;
    final total = quizState.questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              '${currentIndex + 1} / $total',
              style: AppTextStyles.buttonSmall(color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 120,
              child: AnimatedFillBar(
                value: (currentIndex + (quizState.isSubmitted ? 1 : 0)) / total,
                height: 6,
                duration: const Duration(milliseconds: 600),
                gradient: const LinearGradient(
                  colors: [AppColors.lavender, AppColors.primaryPurple],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.volume_up_rounded,
              color: AppColors.primaryPurple,
            ),
            onPressed: () {
              AppAudioService.instance.speak(currentQuestion.audioPrompt);
            },
          ),
        ],
      ),
      body: ConfettiCelebration(
        key: _confettiKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // 1. Scenic Meadow Card (from Reference Image)
                FadeSlideIn(
                  key: ValueKey('scenic_${currentQuestion.id}'),
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppVectorGraphic(
                      assetPath: currentQuestion.illustrationAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Question Text with Speaker Icon
                FadeSlideIn(
                  key: ValueKey('qtext_${currentQuestion.id}'),
                  delay: const Duration(milliseconds: 150),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          currentQuestion.questionText,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading2().copyWith(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          AppAudioService.instance.speak(
                            currentQuestion.audioPrompt,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.softPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_up_rounded,
                            color: AppColors.primaryPurple,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. 4 Answer Cards (2x2 Grid)
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.05,
                        ),
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final option = currentQuestion.options[index];
                      final isSelected = quizState.selectedOptionIndex == index;
                      final isSubmitted = quizState.isSubmitted;
                      final isCorrect =
                          index == currentQuestion.correctOptionIndex;

                      Color cardBg = Colors.white;
                      Color borderColor = AppColors.borderLight;
                      Widget? statusBadge;

                      if (isSubmitted) {
                        if (isCorrect) {
                          cardBg = const Color(0xFFDCFCE7);
                          borderColor = AppColors.green;
                          statusBadge = const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.green,
                            size: 22,
                          );
                        } else if (isSelected) {
                          cardBg = const Color(0xFFFEE2E2);
                          borderColor = AppColors.red;
                          statusBadge = const Icon(
                            Icons.cancel_rounded,
                            color: AppColors.red,
                            size: 22,
                          );
                        }
                      } else if (isSelected) {
                        cardBg = AppColors.purpleLight;
                        borderColor = AppColors.primaryPurple;
                      }

                      final card = AppCard(
                        onTap: isSubmitted
                            ? null
                            : () {
                                AppAudioService.instance.playTapSound();
                                context.read<QuizCubit>().selectOption(index);
                              },
                        backgroundColor: cardBg,
                        borderColor: borderColor,
                        padding: const EdgeInsets.all(12),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: AnimatedScale(
                                      scale: isSelected ? 1.12 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.elasticOut,
                                      child: AppVectorGraphic(
                                        assetPath: option.illustrationAsset,
                                        width: 80,
                                        height: 80,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  option.label,
                                  style: AppTextStyles.heading3(
                                    color: isSelected && !isSubmitted
                                        ? AppColors.primaryPurple
                                        : AppColors.textDark,
                                  ).copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                            if (statusBadge != null)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: PopIn(child: statusBadge),
                              ),
                          ],
                        ),
                      );

                      // Correct answer jumps for joy, wrong pick shakes "no".
                      Widget animated = card;
                      if (isSubmitted && isCorrect) {
                        animated = Wiggle(trigger: isSubmitted, child: card);
                      } else if (isSubmitted && isSelected) {
                        animated = ShakeX(trigger: isSubmitted, child: card);
                      }
                      return PopIn(
                        key: ValueKey('opt_${currentQuestion.id}_$index'),
                        delay: Duration(milliseconds: 150 + index * 90),
                        child: animated,
                      );
                    },
                  ),
                ),

                // Feedback bubble after checking
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: !quizState.isSubmitted
                      ? const SizedBox(height: 8, key: ValueKey('none'))
                      : Builder(
                          key: ValueKey('fb_${currentQuestion.id}'),
                          builder: (context) {
                            final right =
                                quizState.selectedOptionIndex ==
                                currentQuestion.correctOptionIndex;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: right
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFFF1E6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                right
                                    ? '🎉 Great job! That\'s correct!'
                                    : '💪 Nice try! Keep going!',
                                style: AppTextStyles.bodyMedium(
                                  color: right
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFC2410C),
                                ).copyWith(fontWeight: FontWeight.w800),
                              ),
                            );
                          },
                        ),
                ),

                // 4. Submit / Next Question CTA
                FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  child: Column(
                    children: [
                      AppButton(
                        label: quizState.isSubmitted
                            ? (currentIndex < total - 1
                                  ? 'Next Question'
                                  : 'See Results')
                            : 'Check Answer',
                        width: double.infinity,
                        variant: quizState.isSubmitted
                            ? AppButtonVariant.primary
                            : AppButtonVariant.yellow,
                        onPressed: quizState.selectedOptionIndex == null
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please tap an answer card first!',
                                    ),
                                    backgroundColor: AppColors.primaryPurple,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            : () {
                                if (!quizState.isSubmitted) {
                                  context.read<QuizCubit>().submitAnswer();
                                  final isCorrect =
                                      quizState.selectedOptionIndex ==
                                      currentQuestion.correctOptionIndex;
                                  if (isCorrect) {
                                    AppAudioService.instance.playSuccessChime();
                                    _confettiKey.currentState?.play();
                                    showXpBurst(
                                      context,
                                      currentQuestion.xpReward,
                                    );
                                  } else {
                                    AppAudioService.instance
                                        .playIncorrectSound();
                                  }
                                } else {
                                  AppAudioService.instance.playTapSound();
                                  context.read<QuizCubit>().nextQuestion();
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
