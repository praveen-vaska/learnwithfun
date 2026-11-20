import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../blocs/user_cubit.dart';
import 'learning_progress_screen.dart';
import '../onboarding/choose_avatar_screen.dart';
import '../rewards/rewards_screen.dart';
import '../parent_zone/parent_gate_dialog.dart';
import '../parent_zone/parent_dashboard_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: AppTextStyles.heading2()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // 1. Profile Header Card (Avatar, Name, Level)
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryPurple,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AppVectorGraphic(
                          assetPath: userProfile.avatarAsset,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(userProfile.name, style: AppTextStyles.heading2()),
                      const SizedBox(height: 4),
                      Text(
                        'Age: ${userProfile.age} Years • ${userProfile.ageBand}',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softPurple,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Level ${userProfile.level}',
                              style: AppTextStyles.buttonSmall(
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${userProfile.currentXp} XP',
                              style: AppTextStyles.buttonSmall(
                                color: AppColors.yellowDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Profile Options List
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    _buildOptionItem(
                      icon: Icons.insights_rounded,
                      iconColor: AppColors.primaryPurple,
                      title: 'My Progress',
                      subtitle: '75% overall completion and breakdown',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const LearningProgressScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildOptionItem(
                      icon: Icons.emoji_events_rounded,
                      iconColor: AppColors.yellowDark,
                      title: 'Achievements',
                      subtitle: 'View unlocked badges and trophies',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RewardsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildOptionItem(
                      icon: Icons.face_rounded,
                      iconColor: Colors.blue,
                      title: 'My Avatar',
                      subtitle: 'Choose your favorite cartoon look',
                      onTap: () async {
                        final result = await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (context) => ChooseAvatarScreen(
                              currentAvatar: userProfile.avatarAsset,
                            ),
                          ),
                        );
                        if (result != null && context.mounted) {
                          context.read<UserCubit>().updateAvatar(result);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildOptionItem(
                      icon: Icons.family_restroom_rounded,
                      iconColor: AppColors.green,
                      title: 'Parent Zone',
                      subtitle: 'Progress charts, stats & screen time controls',
                      isLocked: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ParentGateDialog(
                            onAuthenticated: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ParentDashboardScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildOptionItem(
                      icon: Icons.settings_rounded,
                      iconColor: Colors.purple,
                      title: 'Settings',
                      subtitle: 'Sound, music, language & preferences',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading3().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall(color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          Icon(
            isLocked
                ? Icons.lock_outline_rounded
                : Icons.arrow_forward_ios_rounded,
            color: isLocked ? AppColors.primaryPurple : AppColors.textLight,
            size: isLocked ? 18 : 16,
          ),
        ],
      ),
    );
  }
}
