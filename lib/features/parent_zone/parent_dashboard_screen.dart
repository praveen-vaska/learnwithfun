import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../blocs/user_cubit.dart';
import '../../data/mock/mock_data.dart';
import 'screen_time_screen.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserCubit>().state;
    final parentStats = MockData.parentStats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Parent Dashboard', style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.timer_outlined,
              color: AppColors.primaryPurple,
            ),
            tooltip: 'Screen Time Controls',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ScreenTimeScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Child Header Banner
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(2),
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
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${userProfile.name} (${userProfile.age} Years)',
                              style: AppTextStyles.heading3(),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Active Learner • Level ${userProfile.level}',
                              style: AppTextStyles.bodySmall(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'This Week',
                          style: AppTextStyles.buttonSmall(
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. 4 Metric Cards Grid
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.35,
                  children: [
                    _buildMetricCard(
                      title: 'Learning Time',
                      value: parentStats.timeSpentThisWeek,
                      subtitle: 'This Week',
                      icon: Icons.timer_outlined,
                      color: AppColors.blue,
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                    _buildMetricCard(
                      title: 'Lessons Completed',
                      value: '${parentStats.lessonsCompleted}',
                      subtitle: 'Total completed',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.green,
                      bgColor: const Color(0xFFF0FDF4),
                    ),
                    _buildMetricCard(
                      title: 'Quiz Accuracy',
                      value: '${parentStats.quizAccuracy}%',
                      subtitle: 'Excellent accuracy',
                      icon: Icons.emoji_events_outlined,
                      color: AppColors.yellowDark,
                      bgColor: const Color(0xFFFEFCE8),
                    ),
                    _buildMetricCard(
                      title: 'Current Streak',
                      value: '${parentStats.currentStreakDays} Days',
                      subtitle: 'Consecutive days',
                      icon: Icons.local_fire_department_outlined,
                      color: Colors.orange,
                      bgColor: const Color(0xFFFFF7ED),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Progress Overview Bar Chart
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress Overview',
                            style: AppTextStyles.heading3(),
                          ),
                          Text(
                            'Daily Minutes',
                            style: AppTextStyles.bodySmall(
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Bar chart visualization
                      SizedBox(
                        height: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: parentStats.weeklyActivity.map((activity) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${activity.minutesSpent}m',
                                  style: AppTextStyles.bodySmall().copyWith(
                                    fontSize: 10,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0,
                                    end: 90 * activity.normalizedHeight,
                                  ),
                                  duration: Duration(
                                    milliseconds:
                                        700 +
                                        parentStats.weeklyActivity.indexOf(
                                              activity,
                                            ) *
                                            110,
                                  ),
                                  curve: Curves.easeOutBack,
                                  builder: (context, h, _) => Container(
                                    width: 22,
                                    height: h.clamp(0, 200),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: activity.dayName == 'Sat'
                                            ? const [
                                                Color(0xFF9B7BFF),
                                                AppColors.primaryPurple,
                                              ]
                                            : const [
                                                Color(0xFFD6C8FF),
                                                AppColors.lavender,
                                              ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  activity.dayName,
                                  style: AppTextStyles.buttonSmall(
                                    color: AppColors.textDark,
                                  ).copyWith(fontSize: 12),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Screen Time Shortcut Banner
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: AppCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ScreenTimeScreen(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFFF5F3FF),
                  borderColor: AppColors.lavender,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.softPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.primaryPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Screen Time Controls',
                              style: AppTextStyles.heading3().copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Limit daily usage & set break alerts',
                              style: AppTextStyles.bodySmall(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.primaryPurple,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall(color: AppColors.textMedium),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(value, style: AppTextStyles.heading2(color: AppColors.textDark)),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall(color: color).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
