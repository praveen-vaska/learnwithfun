import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../blocs/user_cubit.dart';
import '../parent_zone/parent_gate_dialog.dart';
import '../parent_zone/parent_dashboard_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Audio & Sound', style: AppTextStyles.heading3()),
              const SizedBox(height: 12),
              // Sound Effects Switch
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Text('Sound Effects', style: AppTextStyles.bodyLarge()),
                      ],
                    ),
                    Switch.adaptive(
                      value: userProfile.soundEnabled,
                      activeTrackColor: AppColors.primaryPurple,
                      onChanged: (val) {
                        context.read<UserCubit>().toggleSound(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Background Music Switch
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.music_note_rounded,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Background Music',
                          style: AppTextStyles.bodyLarge(),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: userProfile.musicEnabled,
                      activeTrackColor: AppColors.primaryPurple,
                      onChanged: (val) {
                        context.read<UserCubit>().toggleMusic(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('General Preferences', style: AppTextStyles.heading3()),
              const SizedBox(height: 12),

              // Language Selector
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 12),
                        Text('Language', style: AppTextStyles.bodyLarge()),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          userProfile.language,
                          style: AppTextStyles.buttonSmall(
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Notifications Toggle
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Daily Reminders',
                          style: AppTextStyles.bodyLarge(),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: userProfile.notificationsEnabled,
                      activeTrackColor: AppColors.primaryPurple,
                      onChanged: (val) {
                        context.read<UserCubit>().toggleNotifications(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Parent Zone Lock Shortcut
              AppCard(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ParentGateDialog(
                      onAuthenticated: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ParentDashboardScreen(),
                          ),
                        );
                      },
                    ),
                  );
                },
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_rounded, color: AppColors.green),
                        const SizedBox(width: 12),
                        Text(
                          'Parent Controls',
                          style: AppTextStyles.bodyLarge(),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('About LearnWithFun', style: AppTextStyles.heading3()),
              const SizedBox(height: 12),

              // About Us
              AppCard(
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'LearnWithFun',
                    applicationVersion: '1.0.0 (Client Demo Ready)',
                    applicationLegalese:
                        '© 2026 LearnWithFun Team. All rights reserved.',
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'LearnWithFun is an engaging, child-friendly educational app offering interactive lessons, quizzes, mini-games, stories, and parental controls with 100% local deterministic mock data.',
                      ),
                    ],
                  );
                },
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'About LearnWithFun',
                          style: AppTextStyles.bodyLarge(),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Privacy Policy
              AppCard(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      title: Text(
                        'Privacy & Child Safety',
                        style: AppTextStyles.heading2(),
                      ),
                      content: const Text(
                        'LearnWithFun is designed with child safety at its core. No personal information is gathered, no external trackers or ads are present, and all parent controls are safeguarded behind the parental gate.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Close',
                            style: AppTextStyles.button(
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.security_rounded,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Privacy Policy & Child Safety',
                          style: AppTextStyles.bodyLarge(),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
