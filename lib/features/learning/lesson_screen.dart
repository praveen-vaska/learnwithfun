import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/app_audio_indicator.dart';
import '../../core/animations/kid_animations.dart';
import '../../blocs/learning_cubit.dart';
import '../../blocs/user_cubit.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  void _playLessonAudio(BuildContext context, dynamic lesson) {
    if (lesson.categoryId == 'animals') {
      AppAudioService.instance.playAnimalSound(lesson.conceptWord);
    } else {
      AppAudioService.instance.speak(lesson.soundText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final learningState = context.watch<LearningCubit>().state;
    final currentLessons = learningState.currentLessons;

    if (currentLessons.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No lessons available')),
      );
    }

    final currentIndex = learningState.activeLessonIndex;
    final lesson = currentLessons[currentIndex];
    final total = currentLessons.length;
    final categoryId = lesson.categoryId;
    final isAbc = categoryId == 'abc';
    final isNumbers = categoryId == '123';
    final isAnimals = categoryId == 'animals';

    // Header display text logic
    String displayHeading = lesson.title;
    String displaySubtitle = '';

    if (isAbc) {
      final parts = lesson.title.split(' ');
      final first = parts.first;
      displaySubtitle = '$first for ${lesson.conceptWord}';
    } else if (isNumbers) {
      displayHeading = lesson.title.split(' ').first;
      displaySubtitle = 'Number $displayHeading • ${lesson.conceptWord}';
    } else if (isAnimals) {
      displayHeading = lesson.conceptWord;
      displaySubtitle = 'Meet the $displayHeading!';
    } else {
      displayHeading = lesson.conceptWord;
      displaySubtitle = lesson.title;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            AppAudioService.instance.stop();
            Navigator.of(context).pop();
          },
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
                value: (currentIndex + 1) / total,
                height: 6,
                duration: const Duration(milliseconds: 600),
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
              _playLessonAudio(context, lesson);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
          child: Column(
            children: [
              // Card holding concept + interactive illustration
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 520),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.85, end: 1.0).animate(anim),
                      child: RotationTransition(
                        turns: Tween(begin: -0.02, end: 0.0).animate(anim),
                        child: child,
                      ),
                    ),
                  ),
                  child: Container(
                    key: ValueKey(lesson.id),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF1EBFF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        PopIn(
                          child: isAbc
                              ? RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.giantDisplay()
                                        .copyWith(fontSize: 78),
                                    children: [
                                      TextSpan(
                                        text: lesson.title.split(' ').first,
                                        style: const TextStyle(
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                      TextSpan(
                                        text: lesson.title.contains(' ')
                                            ? ' ${lesson.title.split(' ').sublist(1).join(' ')}'
                                            : '',
                                        style: const TextStyle(
                                          color: Color(0xFFFF6FA3),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(
                                  displayHeading,
                                  style: AppTextStyles.giantDisplay().copyWith(
                                    fontSize: isNumbers ? 80 : 38,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Center(
                            child: SparkleBits(
                              radius: 105,
                              count: 9,
                              child: PopIn(
                                delay: const Duration(milliseconds: 150),
                                duration: const Duration(milliseconds: 900),
                                child: GestureDetector(
                                  onTap: () =>
                                      _playLessonAudio(context, lesson),
                                  child: FloatBob(
                                    distance: 7,
                                    rotation: 0.04,
                                    child: AppVectorGraphic(
                                      assetPath: lesson.illustrationAsset,
                                      width: 190,
                                      height: 190,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isAnimals)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Tap the animal to hear it roar/sound!',
                              style: AppTextStyles.bodySmall(
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Word + audio + description
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Column(
                  key: ValueKey('w${lesson.id}'),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            displaySubtitle,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.heading1().copyWith(
                              fontSize: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppAudioIndicator(
                          isPlaying: learningState.isAudioPlaying,
                          onToggle: () {
                            context.read<LearningCubit>().toggleAudioPlayback();
                            _playLessonAudio(context, lesson);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson.description,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: AppTextStyles.bodyLarge(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Previous',
                      variant: AppButtonVariant.outline,
                      onPressed: currentIndex > 0
                          ? () {
                              AppAudioService.instance.playTapSound();
                              context.read<LearningCubit>().previousLesson();
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      label: currentIndex < total - 1 ? 'Next' : 'Finish',
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        context.read<LearningCubit>().completeCurrentLesson();
                        context.read<UserCubit>().addXp(10);
                        showXpBurst(context, 10);
                        AppAudioService.instance.playSuccessChime();

                        if (currentIndex < total - 1) {
                          context.read<LearningCubit>().nextLesson();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '🎉 Lesson completed! +10 XP earned!',
                              ),
                              backgroundColor: AppColors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
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
}
