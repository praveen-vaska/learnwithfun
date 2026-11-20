import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/animations/kid_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../blocs/daily_challenge_cubit.dart';
import '../../blocs/user_cubit.dart';
import '../learning/alphabet_grid_screen.dart';
import '../quiz/quiz_question_screen.dart';
import '../mini_games/memory_match_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final GlobalKey<ConfettiCelebrationState> _confettiKey =
      GlobalKey<ConfettiCelebrationState>();

  @override
  Widget build(BuildContext context) {
    final challengeState = context.watch<DailyChallengeCubit>().state;
    final challenges = challengeState.challenges;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Daily Challenge', style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ConfettiCelebration(
        key: _confettiKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finish today’s activities to boost your learning streak!',
                  style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
                ),
                const SizedBox(height: 20),

                // Challenge List
                Expanded(
                  child: ListView.separated(
                    itemCount: challenges.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = challenges[index];

                      return FadeSlideIn(
                        delay: Duration(milliseconds: 100 * index),
                        child: AppCard(
                          padding: const EdgeInsets.all(16),
                          borderColor: item.isCompleted
                              ? AppColors.green
                              : AppColors.borderLight,
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: item.isCompleted
                                      ? const Color(0xFFDCFCE7)
                                      : AppColors.softPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.isCompleted
                                      ? Icons.check_rounded
                                      : item.icon,
                                  color: item.isCompleted
                                      ? AppColors.green
                                      : AppColors.primaryPurple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: AppTextStyles.heading3(),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '+${item.xpReward} XP Reward',
                                      style: AppTextStyles.buttonSmall(
                                        color: AppColors.yellowDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Action Play / Done button
                              if (item.isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    'Done',
                                    style: AppTextStyles.buttonSmall(
                                      color: AppColors.green,
                                    ),
                                  ),
                                )
                              else
                                IconButton(
                                  icon: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: AppColors.primaryPurple,
                                    size: 36,
                                  ),
                                  onPressed: () {
                                    if (item.id == 'c1') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AlphabetGridScreen(),
                                        ),
                                      );
                                    } else if (item.id == 'c2') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const QuizQuestionScreen(),
                                        ),
                                      );
                                    } else {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MemoryMatchScreen(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Treasure Gift Box Card (Matching Reference Image)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.yellowDark,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x20F59E0B),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Wiggle(
                            autoEvery: const Duration(milliseconds: 2200),
                            angle: 0.14,
                            child: FloatBob(
                              distance: 4,
                              child: AppVectorGraphic(
                                assetPath: AssetPaths.giftBox,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Complete all and earn 50 XP!',
                          style: AppTextStyles.heading2(
                            color: AppColors.textDark,
                          ).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          challengeState.bonusClaimed
                              ? '🎉 Bonus claimed! Awesome job!'
                              : (challengeState.allCompleted
                                    ? 'All tasks finished! Tap below to claim!'
                                    : 'Finish the remaining tasks to unlock!'),
                          style: AppTextStyles.bodySmall(
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: challengeState.bonusClaimed
                              ? 'Bonus Claimed'
                              : 'Claim 50 XP Bonus',
                          variant: AppButtonVariant.primary,
                          width: double.infinity,
                          onPressed:
                              (!challengeState.bonusClaimed &&
                                  challengeState.allCompleted)
                              ? () {
                                  context
                                      .read<DailyChallengeCubit>()
                                      .claimBonus();
                                  context.read<UserCubit>().addXp(50);
                                  _confettiKey.currentState?.play();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🎁 +50 XP Bonus added!'),
                                      backgroundColor: AppColors.green,
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
