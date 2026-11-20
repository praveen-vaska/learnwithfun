import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/animations/bouncing_widget.dart';
import '../../core/animations/kid_animations.dart';
import '../../blocs/learning_cubit.dart';
import 'lesson_screen.dart';

class AlphabetGridScreen extends StatelessWidget {
  const AlphabetGridScreen({super.key});

  // (tile background, letter/accent colour) pairs
  static const List<(Color, Color)> _tones = [
    (Color(0xFFE9F9D9), Color(0xFF4CAF50)),
    (Color(0xFFFFE4E6), Color(0xFFE11D48)),
    (Color(0xFFE0F2FE), Color(0xFF0284C7)),
    (Color(0xFFFFF3C4), Color(0xFFD97706)),
    (Color(0xFFF3E8FF), Color(0xFF7C3AED)),
    (Color(0xFFFFEDD5), Color(0xFFEA580C)),
    (Color(0xFFDDF7F4), Color(0xFF0D9488)),
    (Color(0xFFFCE7F3), Color(0xFFDB2777)),
  ];

  @override
  Widget build(BuildContext context) {
    final learningState = context.watch<LearningCubit>().state;
    final lessons = learningState.currentLessons;
    final category = learningState.categories
        .where((c) => c.id == learningState.selectedCategoryId)
        .firstOrNull;
    final title = category?.title ?? 'Learning Fun';
    final categoryId = learningState.selectedCategoryId;
    final isAbc = categoryId == 'abc';
    final isNumbers = categoryId == '123';
    final isAnimals = categoryId == 'animals';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      isAnimals
                          ? 'Tap an animal to hear its sound!'
                          : isNumbers
                          ? 'Tap numbers to count and learn!'
                          : 'Tap a card to start learning!',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${lessons.length} Cards',
                      style: AppTextStyles.buttonSmall(
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isAbc
                    ? _buildAlphabetGrid(context, lessons)
                    : isNumbers
                    ? _buildNumbersGrid(context, lessons)
                    : _buildIllustratedGrid(context, lessons, isAnimals),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. A-Z 4-Column Grid
  Widget _buildAlphabetGrid(BuildContext context, List<dynamic> lessons) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final tone = _tones[index % _tones.length];
        final letterChar = lesson.title.split(' ').first;
        final wave = (index ~/ 4) + (index % 4);

        return PopIn(
          delay: Duration(milliseconds: 60 + wave * 45),
          child: BouncingWidget(
            onTap: () {
              AppAudioService.instance.playTapSound();
              context.read<LearningCubit>().setActiveLesson(index);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LessonScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: tone.$1,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: lesson.isCompleted ? AppColors.green : Colors.white,
                  width: lesson.isCompleted ? 2.2 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tone.$2.withAlpha(40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          letterChar,
                          style: AppTextStyles.heading1(color: tone.$2)
                              .copyWith(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                  if (lesson.isCompleted)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 2. 123 Numbers 3-Column Grid
  Widget _buildNumbersGrid(BuildContext context, List<dynamic> lessons) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final tone = _tones[index % _tones.length];

        return PopIn(
          delay: Duration(milliseconds: 60 + index * 45),
          child: BouncingWidget(
            onTap: () {
              AppAudioService.instance.playTapSound();
              context.read<LearningCubit>().setActiveLesson(index);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LessonScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tone.$1,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: lesson.isCompleted ? AppColors.green : Colors.white,
                  width: lesson.isCompleted ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tone.$2.withAlpha(45),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}',
                        style: AppTextStyles.heading1(
                          color: tone.$2,
                        ).copyWith(fontSize: 34, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Center(
                          child: FloatBob(
                            distance: 3,
                            child: AppVectorGraphic(
                              assetPath: lesson.illustrationAsset,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.conceptWord,
                        style: AppTextStyles.buttonSmall(
                          color: AppColors.textDark,
                        ).copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  if (lesson.isCompleted)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 3. Illustrated Category Cards (Animals, Shapes, Fruits, Vehicles, etc.)
  Widget _buildIllustratedGrid(
    BuildContext context,
    List<dynamic> lessons,
    bool isAnimals,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final tone = _tones[index % _tones.length];

        return PopIn(
          delay: Duration(milliseconds: 70 + index * 50),
          child: BouncingWidget(
            onTap: () {
              AppAudioService.instance.playTapSound();
              context.read<LearningCubit>().setActiveLesson(index);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LessonScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tone.$1,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: lesson.isCompleted ? AppColors.green : Colors.white,
                  width: lesson.isCompleted ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tone.$2.withAlpha(40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: FloatBob(
                            distance: 4,
                            child: AppVectorGraphic(
                              assetPath: lesson.illustrationAsset,
                              width: 72,
                              height: 72,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lesson.conceptWord,
                        style: AppTextStyles.heading3(color: AppColors.textDark)
                            .copyWith(fontSize: 16),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isAnimals) {
                                AppAudioService.instance.playAnimalSound(
                                  lesson.conceptWord,
                                );
                              } else {
                                AppAudioService.instance.speak(
                                  lesson.soundText,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: tone.$2.withAlpha(35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.volume_up_rounded,
                                    size: 14,
                                    color: tone.$2,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAnimals ? 'Sound' : 'Listen',
                                    style: AppTextStyles.buttonSmall(
                                      color: tone.$2,
                                    ).copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (lesson.isCompleted)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
