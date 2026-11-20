import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/animations/kid_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../blocs/user_cubit.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/reward_badge.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserCubit>().state;
    final badges = MockData.badges;

    final double levelProgress = userProfile.nextLevelXp > 0
        ? (userProfile.currentXp / userProfile.nextLevelXp).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Rewards', style: AppTextStyles.heading2()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Level & XP Progress Card (Matching Reference Image)
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryPurple,
                                width: 2,
                              ),
                            ),
                            child: AppVectorGraphic(
                              assetPath: userProfile.avatarAsset,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Level ${userProfile.level}',
                                      style: AppTextStyles.heading2(),
                                    ),
                                    Text(
                                      '${userProfile.currentXp} / ${userProfile.nextLevelXp} XP',
                                      style: AppTextStyles.buttonSmall(
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AnimatedFillBar(
                                  value: levelProgress,
                                  height: 10,
                                  delay: const Duration(milliseconds: 300),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD54F),
                                      Color(0xFFF59E0B),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 16),
                      // 3 Stat Highlights
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            '${userProfile.currentXp}',
                            'Total XP',
                            Icons.star_rounded,
                            AppColors.yellowDark,
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: AppColors.borderLight,
                          ),
                          _buildStatColumn(
                            '${userProfile.stars}',
                            'Stars',
                            Icons.auto_awesome_rounded,
                            AppColors.yellowDark,
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: AppColors.borderLight,
                          ),
                          _buildStatColumn(
                            '${userProfile.streakDays} Days',
                            'Streak',
                            Icons.local_fire_department_rounded,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Achievements Header
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Achievements', style: AppTextStyles.heading2()),
                    Text(
                      '${badges.where((b) => b.isUnlocked).length} / ${badges.length} Unlocked',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Badges Grid
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];

                    return PopIn(
                      delay: Duration(
                        milliseconds: 350 + ((index ~/ 3) + (index % 3)) * 90,
                      ),
                      child: AppCard(
                        onTap: () {
                          _showBadgeDetails(context, badge);
                        },
                        padding: const EdgeInsets.all(8),
                        borderColor: badge.isUnlocked
                            ? AppColors.yellowDark
                            : AppColors.borderLight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: badge.isUnlocked
                                  ? FloatBob(
                                      distance: 3,
                                      rotation: 0.05,
                                      phase: index * 0.17,
                                      child: AppVectorGraphic(
                                        assetPath: badge.isUnlocked
                                            ? badge.assetPath
                                            : AssetPaths.badgeLocked,
                                      ),
                                    )
                                  : AppVectorGraphic(
                                      assetPath: badge.isUnlocked
                                          ? badge.assetPath
                                          : AssetPaths.badgeLocked,
                                    ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              badge.title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading3().copyWith(
                                fontSize: 13,
                                color: badge.isUnlocked
                                    ? AppColors.textDark
                                    : AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge.isUnlocked
                                  ? 'Unlocked!'
                                  : '${badge.requiredXp} XP Needed',
                              style: AppTextStyles.buttonSmall(
                                color: badge.isUnlocked
                                    ? AppColors.green
                                    : AppColors.textLight,
                              ).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(value, style: AppTextStyles.heading3()),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall(color: AppColors.textMedium),
        ),
      ],
    );
  }

  void _showBadgeDetails(BuildContext context, RewardBadge badge) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: AppVectorGraphic(
                  assetPath: badge.isUnlocked
                      ? badge.assetPath
                      : AssetPaths.badgeLocked,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                badge.title,
                style: AppTextStyles.heading2(
                  color: badge.isUnlocked
                      ? AppColors.primaryPurple
                      : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? const Color(0xFFDCFCE7)
                      : AppColors.softPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  badge.isUnlocked
                      ? '✓ Unlocked'
                      : 'Requires ${badge.requiredXp} XP',
                  style: AppTextStyles.buttonSmall(
                    color: badge.isUnlocked
                        ? AppColors.green
                        : AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Awesome',
                style: AppTextStyles.button(color: AppColors.primaryPurple),
              ),
            ),
          ],
        );
      },
    );
  }
}
