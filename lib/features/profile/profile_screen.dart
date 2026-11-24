import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../blocs/user_cubit.dart';
import '../../blocs/auth_cubit.dart';
import '../auth/screens/login_screen.dart';
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
              const SizedBox(height: 16),

              // 2. Parent Account Info Card
              FadeSlideIn(
                delay: const Duration(milliseconds: 150),
                child: _buildAccountCard(context),
              ),
              const SizedBox(height: 16),

              // 3. Profile Options List
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
                    if (context.watch<AuthCubit>().state is Authenticated) ...[
                      const SizedBox(height: 12),
                      _buildOptionItem(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.pinkDark,
                        title: 'Log Out / Switch Account',
                        subtitle: 'Safely sign out or switch accounts',
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
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

  Widget _buildAccountCard(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isAuthenticated = authState is Authenticated;
    final user = isAuthenticated ? authState.user : null;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAuthenticated
                  ? AppColors.softPurple
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAuthenticated
                  ? Icons.verified_user_rounded
                  : Icons.account_circle_outlined,
              color: isAuthenticated
                  ? AppColors.primaryPurple
                  : AppColors.textMedium,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isAuthenticated ? (user!.name) : 'Guest Explorer',
                      style: AppTextStyles.heading3().copyWith(fontSize: 15),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAuthenticated
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAuthenticated ? 'Parent Account' : 'Guest',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isAuthenticated
                              ? AppColors.green
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isAuthenticated
                      ? (user!.phoneNumber != null
                          ? '📱 +91 ${user.phoneNumber}'
                          : '✉️ ${user.email}')
                      : 'Sign in to save and sync progress',
                  style: AppTextStyles.bodySmall(color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          if (!isAuthenticated)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Sign In'),
            ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.pinkDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Log Out?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Your child’s learning stars and progress are safely saved to your account. You can log back in anytime.',
          style: TextStyle(fontSize: 14, color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMedium),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthCubit>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
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
