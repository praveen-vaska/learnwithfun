import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/animations/fade_slide_in.dart';
import '../../core/illustrations/kid_scenes.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/quiz_level.dart';
import '../../blocs/quiz_cubit.dart';
import 'quiz_question_screen.dart';

class QuizIntroScreen extends StatefulWidget {
  const QuizIntroScreen({super.key});

  @override
  State<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends State<QuizIntroScreen> {
  String _selectedDifficulty = 'All';

  final List<String> _difficultyFilters = const [
    'All',
    'Very Easy',
    'Easy',
    'Medium',
    'Hard',
    'Very Hard',
  ];

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Very Easy':
        return const Color(0xFF10B981); // Emerald Green
      case 'Easy':
        return const Color(0xFF0EA5E9); // Sky Blue
      case 'Medium':
        return const Color(0xFFF59E0B); // Amber Orange
      case 'Hard':
        return const Color(0xFF8B5CF6); // Purple
      case 'Very Hard':
        return const Color(0xFFEF4444); // Crimson
      default:
        return AppColors.primaryPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizState = context.watch<QuizCubit>().state;
    final allLevels = MockData.quizLevels;
    final unlockedLevel = quizState.unlockedLevel;
    final starsMap = quizState.levelStars;

    // Filter levels
    final filteredLevels = _selectedDifficulty == 'All'
        ? allLevels
        : allLevels
            .where((l) => l.difficulty == _selectedDifficulty)
            .toList();

    // Calculate total stars won
    final int totalStarsWon = starsMap.values.fold(0, (sum, s) => sum + s);
    final int maxStarsPossible = allLevels.length * 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Animal Sounds Quiz', style: AppTextStyles.heading2()),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$totalStarsWon / $maxStarsPossible',
                  style: AppTextStyles.buttonSmall(
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // Hero Header Banner
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x338B5CF6),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '10 Progressive Levels 🏆',
                                    style: AppTextStyles.bodySmall(
                                      color: Colors.white,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Real Animal Sounds!',
                                  style: AppTextStyles.heading2(
                                    color: Colors.white,
                                  ).copyWith(fontSize: 22),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Listen to genuine animal cries (moo, bark, roar!) and match the animal.',
                                  style: AppTextStyles.bodySmall(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const SizedBox(
                            width: 90,
                            height: 90,
                            child: TrophyScene(size: 90, confetti: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Difficulty Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _difficultyFilters.map((diff) {
                        final isSelected = _selectedDifficulty == diff;
                        final color = diff == 'All'
                            ? AppColors.primaryPurple
                            : _getDifficultyColor(diff);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(diff),
                            selected: isSelected,
                            onSelected: (_) {
                              AppAudioService.instance.playTapSound();
                              setState(() => _selectedDifficulty = diff);
                            },
                            selectedColor: color.withOpacity(0.18),
                            checkmarkColor: color,
                            labelStyle: TextStyle(
                              color: isSelected ? color : AppColors.textMedium,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 13,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? color
                                    : AppColors.borderLight,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Levels List
                  ...filteredLevels.map((level) {
                    final bool isUnlocked = level.levelNumber <= unlockedLevel;
                    final int stars = starsMap[level.levelNumber] ?? 0;
                    final color = _getDifficultyColor(level.difficulty);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildLevelCard(
                        context: context,
                        level: level,
                        isUnlocked: isUnlocked,
                        stars: stars,
                        difficultyColor: color,
                      ),
                    );
                  }),
                  const SizedBox(height: 70), // Spacing for bottom button
                ],
              ),
            ),

            // Bottom Continue CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: AppButton(
                label: 'Play Level $unlockedLevel ▶️',
                width: double.infinity,
                height: 54,
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  AppAudioService.instance.playTapSound();
                  context.read<QuizCubit>().startLevel(unlockedLevel);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const QuizQuestionScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required QuizLevel level,
    required bool isUnlocked,
    required int stars,
    required Color difficultyColor,
  }) {
    return AppCard(
      onTap: isUnlocked
          ? () {
              AppAudioService.instance.playTapSound();
              context.read<QuizCubit>().startLevel(level.levelNumber);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QuizQuestionScreen(),
                ),
              );
            }
          : () {
              AppAudioService.instance.playTapSound();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🔒 Complete Level ${level.levelNumber - 1} to unlock Level ${level.levelNumber}!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: AppColors.primaryPurple,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
      borderColor: isUnlocked
          ? (stars > 0 ? AppColors.yellowDark : difficultyColor.withOpacity(0.4))
          : AppColors.borderLight,
      backgroundColor: isUnlocked ? Colors.white : const Color(0xFFF9FAFB),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Level Number Circle / Lock Icon
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? difficultyColor.withOpacity(0.12)
                  : const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked
                    ? difficultyColor.withOpacity(0.5)
                    : const Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
            child: Center(
              child: isUnlocked
                  ? Text(
                      '${level.levelNumber}',
                      style: AppTextStyles.heading2(
                        color: difficultyColor,
                      ).copyWith(fontSize: 22),
                    )
                  : const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Title, Subtitle, and Sound Indicators
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        level.difficulty,
                        style: AppTextStyles.bodySmall(
                          color: difficultyColor,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '+${level.xpReward} XP',
                            style: AppTextStyles.bodySmall(
                              color: const Color(0xFFB45309),
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  level.title,
                  style: AppTextStyles.heading3(
                    color: isUnlocked
                        ? AppColors.textDark
                        : const Color(0xFF6B7280),
                  ).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  level.subtitle,
                  style: AppTextStyles.bodySmall(
                    color: isUnlocked
                        ? AppColors.textMedium
                        : const Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Stars earned row
                Row(
                  children: [
                    ...List.generate(3, (starIdx) {
                      final bool isEarned = starIdx < stars;
                      return Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          isEarned
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isEarned
                              ? const Color(0xFFFFC21A)
                              : const Color(0xFFD1D5DB),
                          size: 20,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      '${level.questions.length} questions 🐾',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Play arrow button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? difficultyColor.withOpacity(0.12)
                  : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? Icons.play_arrow_rounded : Icons.lock_outline_rounded,
              color: isUnlocked ? difficultyColor : const Color(0xFF9CA3AF),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
