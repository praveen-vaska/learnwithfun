import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/kid_animations.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../data/models/quiz_question.dart';
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

  String? _lastPlayedQuestionId;
  bool _isPlayingAudio = false;

  @override
  void dispose() {
    AppAudioService.instance.stop();
    super.dispose();
  }

  /// Sequences human speech prompt followed by authentic animal sound
  Future<void> _playQuestionAudioSequence(QuizQuestion question) async {
    if (_isPlayingAudio) return;
    _isPlayingAudio = true;
    _lastPlayedQuestionId = question.id;

    try {
      // 1. Spoken by human voice: prompt text (e.g. "Which animal says...")
      final prompt = question.humanPrompt ?? question.audioPrompt.replaceAll(RegExp(r'"[^"]*"'), '').trim();
      final humanText = prompt.isNotEmpty ? prompt : 'Which animal says...';
      await AppAudioService.instance.speak(humanText);

      // 2. Pronounced by the animal: genuine animal sound recording
      if (question.animalSound != null && mounted) {
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) {
          await AppAudioService.instance.playAnimalSound(question.animalSound!);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  /// Plays only the authentic animal sound
  Future<void> _playOnlyAnimalSound(String soundKey) async {
    AppAudioService.instance.playTapSound();
    await AppAudioService.instance.playAnimalSound(soundKey);
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case 'Very Easy':
        return const Color(0xFF10B981);
      case 'Easy':
        return const Color(0xFF0EA5E9);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'Hard':
        return const Color(0xFF8B5CF6);
      case 'Very Hard':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primaryPurple;
    }
  }

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
              levelNumber: quizState.currentLevelNumber,
              starsEarned: quizState.starsEarned,
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

    // Auto-play audio prompt on new question
    if (_lastPlayedQuestionId != currentQuestion.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playQuestionAudioSequence(currentQuestion);
      });
    }

    final currentIndex = quizState.currentQuestionIndex;
    final total = quizState.questions.length;
    final diffColor = _getDifficultyColor(currentQuestion.difficulty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: diffColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Level ${quizState.currentLevelNumber}',
                    style: AppTextStyles.bodySmall(color: diffColor).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${currentIndex + 1} / $total',
                  style: AppTextStyles.buttonSmall(color: AppColors.primaryPurple),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 140,
              child: AnimatedFillBar(
                value: (currentIndex + (quizState.isSubmitted ? 1 : 0)) / total,
                height: 6,
                duration: const Duration(milliseconds: 600),
                gradient: LinearGradient(
                  colors: [diffColor.withOpacity(0.5), diffColor],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Replay Question & Sound',
            icon: Icon(
              _isPlayingAudio ? Icons.volume_up_rounded : Icons.volume_down_rounded,
              color: AppColors.primaryPurple,
            ),
            onPressed: () => _playQuestionAudioSequence(currentQuestion),
          ),
        ],
      ),
      body: ConfettiCelebration(
        key: _confettiKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // 1. Question Scenic Meadow / Animal Scene Card
                FadeSlideIn(
                  key: ValueKey('scenic_${currentQuestion.id}'),
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    height: 125,
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
                const SizedBox(height: 12),

                // 2. Question Text Prompt
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
                            fontSize: 19,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _playQuestionAudioSequence(currentQuestion),
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
                const SizedBox(height: 10),

                // 3. Dedicated Authentic Animal Sound Button
                if (currentQuestion.animalSound != null)
                  FadeSlideIn(
                    key: ValueKey('soundbtn_${currentQuestion.id}'),
                    delay: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () => _playOnlyAnimalSound(currentQuestion.animalSound!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22F59E0B),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.volume_up_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hear Sound: ${currentQuestion.soundDescription ?? "Listen 🐾"}',
                              style: AppTextStyles.buttonSmall(
                                color: const Color(0xFFB45309),
                              ).copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              color: Color(0xFFD97706),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // 4. 4 Answer Cards (2x2 Grid)
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final option = currentQuestion.options[index];
                      final isSelected = quizState.selectedOptionIndex == index;
                      final isSubmitted = quizState.isSubmitted;
                      final isCorrect = index == currentQuestion.correctOptionIndex;

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
                                // Also play the clicked animal's authentic sound
                                if (option.animalSound != null) {
                                  AppAudioService.instance.playAnimalSound(option.animalSound!);
                                }
                                context.read<QuizCubit>().selectOption(index);
                              },
                        backgroundColor: cardBg,
                        borderColor: borderColor,
                        padding: const EdgeInsets.all(10),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: AnimatedScale(
                                      scale: isSelected ? 1.12 : 1.0,
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.elasticOut,
                                      child: AppVectorGraphic(
                                        assetPath: option.illustrationAsset,
                                        width: 75,
                                        height: 75,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      option.label,
                                      style: AppTextStyles.heading3(
                                        color: isSelected && !isSubmitted
                                            ? AppColors.primaryPurple
                                            : AppColors.textDark,
                                      ).copyWith(fontSize: 15),
                                    ),
                                    if (option.animalSound != null) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.volume_down_rounded,
                                        size: 14,
                                        color: AppColors.textLight,
                                      ),
                                    ],
                                  ],
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

                      Widget animated = card;
                      if (isSubmitted && isCorrect) {
                        animated = Wiggle(trigger: isSubmitted, child: card);
                      } else if (isSubmitted && isSelected) {
                        animated = ShakeX(trigger: isSubmitted, child: card);
                      }
                      return PopIn(
                        key: ValueKey('opt_${currentQuestion.id}_$index'),
                        delay: Duration(milliseconds: 150 + index * 80),
                        child: animated,
                      );
                    },
                  ),
                ),

                // 5. Fun Fact / Feedback Bubble
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: !quizState.isSubmitted
                      ? const SizedBox(height: 6, key: ValueKey('none'))
                      : Builder(
                          key: ValueKey('fb_${currentQuestion.id}'),
                          builder: (context) {
                            final right = quizState.selectedOptionIndex == currentQuestion.correctOptionIndex;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: right ? const Color(0xFFDCFCE7) : const Color(0xFFFFF1E6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: right ? const Color(0xFF86EFAC) : const Color(0xFFFED7AA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    right ? '🎉' : '💡',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      right
                                          ? (currentQuestion.funFact != null
                                              ? 'Correct! ${currentQuestion.funFact}'
                                              : 'Great job! That\'s correct!')
                                          : (currentQuestion.funFact != null
                                              ? 'Fun Fact: ${currentQuestion.funFact}'
                                              : 'Nice try! Keep going!'),
                                      style: AppTextStyles.bodySmall(
                                        color: right ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // 6. Check Answer / Next Question CTA Button
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      AppButton(
                        label: quizState.isSubmitted
                            ? (currentIndex < total - 1 ? 'Next Question ▶️' : 'See Results 🏆')
                            : 'Check Answer',
                        width: double.infinity,
                        height: 52,
                        variant: quizState.isSubmitted ? AppButtonVariant.primary : AppButtonVariant.yellow,
                        onPressed: quizState.selectedOptionIndex == null
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please tap an animal card first!'),
                                    backgroundColor: AppColors.primaryPurple,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            : () {
                                if (!quizState.isSubmitted) {
                                  context.read<QuizCubit>().submitAnswer();
                                  final isCorrect =
                                      quizState.selectedOptionIndex == currentQuestion.correctOptionIndex;
                                  if (isCorrect) {
                                    AppAudioService.instance.playSuccessChime();
                                    _confettiKey.currentState?.play();
                                    showXpBurst(context, currentQuestion.xpReward);
                                  } else {
                                    AppAudioService.instance.playIncorrectSound();
                                  }
                                } else {
                                  AppAudioService.instance.playTapSound();
                                  context.read<QuizCubit>().nextQuestion();
                                }
                              },
                      ),
                      const SizedBox(height: 8),
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
