import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/illustrations/kid_scenes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/category_tile.dart';
import '../../core/animations/bouncing_widget.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/kid_animations.dart';
import '../../blocs/user_cubit.dart';
import '../../blocs/learning_cubit.dart';
import '../notifications/notifications_screen.dart';
import '../challenges/daily_challenge_screen.dart';
import '../learning/alphabet_grid_screen.dart';
import '../learning/lesson_screen.dart';
import '../mini_games/memory_match_screen.dart';
import '../stories/stories_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const HomeDashboardScreen({super.key, this.onNavigateTab});

  void _openCategory(BuildContext context, String id) {
    context.read<LearningCubit>().selectCategory(id);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AlphabetGridScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserCubit>().state;

    final categories = [
      ('abc', 'ABC', 'Learning', AssetPaths.catAlphabet),
      ('123', 'Numbers', '& Colors', AssetPaths.catNumbers),
      ('animals', 'Animals', 'World', AssetPaths.catAnimals),
      ('shapes', 'Shapes', '& Colors', AssetPaths.catShapes),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: avatar, greeting, bell
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Row(
                  children: [
                    BouncingWidget(
                      onTap: () => onNavigateTab?.call(4),
                      child: PopIn(
                        child: Container(
                          width: 52,
                          height: 52,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryPurple,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: AppVectorGraphic(
                            assetPath: userProfile.avatarAsset,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Hi, ${userProfile.name}!',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.heading2(),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Waving hand
                              Wiggle(
                                autoEvery: const Duration(milliseconds: 2600),
                                angle: 0.35,
                                child: const Text(
                                  '👋',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Let\'s learn something new!',
                            style: AppTextStyles.bodySmall(
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BouncingWidget(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Wiggle(
                              autoEvery: const Duration(seconds: 5),
                              angle: 0.3,
                              child: const Icon(
                                Icons.notifications_rounded,
                                color: AppColors.primaryPurple,
                                size: 24,
                              ),
                            ),
                            Positioned(
                              top: 9,
                              right: 10,
                              child: PulseGlow(
                                scale: 1.25,
                                glowColor: const Color(0x88F43F5E),
                                borderRadius: 6,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: AppColors.pinkDark,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Daily Challenge banner
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B7BFF), Color(0xFF6D28D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x406D28D9),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: DriftingClouds(
                            count: 3,
                            color: Color(0x1AFFFFFF),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Challenge',
                                      style: AppTextStyles.heading2(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Complete a quiz and earn 20 XP!',
                                      style: AppTextStyles.bodySmall(
                                        color: Colors.white.withAlpha(225),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    PulseGlow(
                                      glowColor: const Color(0x80FFE16A),
                                      child: AppButton(
                                        label: 'Let\'s Go',
                                        variant: AppButtonVariant.white,
                                        height: 40,
                                        width: 120,
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const DailyChallengeScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const TrophyScene(size: 116, confetti: false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Stats ribbon with count-up
              FadeSlideIn(
                delay: const Duration(milliseconds: 260),
                child: Row(
                  children: [
                    _StatPill(
                      icon: Icons.star_rounded,
                      value: userProfile.currentXp,
                      suffix: ' XP',
                      iconColor: AppColors.yellowDark,
                      bgColor: const Color(0xFFFEF3C7),
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      icon: Icons.local_fire_department_rounded,
                      value: userProfile.streakDays,
                      suffix: ' Days',
                      iconColor: Colors.orange,
                      bgColor: const Color(0xFFFFEDD5),
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      icon: Icons.workspace_premium_rounded,
                      value: userProfile.level,
                      prefix: 'Level ',
                      iconColor: AppColors.primaryPurple,
                      bgColor: AppColors.softPurple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Categories header
              FadeSlideIn(
                delay: const Duration(milliseconds: 320),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categories', style: AppTextStyles.heading2()),
                    TextButton(
                      onPressed: () => onNavigateTab?.call(1),
                      child: Text(
                        'See All',
                        style: AppTextStyles.buttonSmall(
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // 5. Colourful 2x2 category grid, tiles pop in one by one
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.0,
                children: [
                  for (var i = 0; i < categories.length; i++)
                    PopIn(
                      delay: Duration(milliseconds: 380 + i * 110),
                      child: CategoryTile(
                        index: i,
                        title: categories[i].$2,
                        subtitle: categories[i].$3,
                        assetPath: categories[i].$4,
                        palette: CategoryPalette.forId(categories[i].$1, i),
                        onTap: () => _openCategory(context, categories[i].$1),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Continue learning
              FadeSlideIn(
                delay: const Duration(milliseconds: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Continue Learning', style: AppTextStyles.heading3()),
                    const SizedBox(height: 12),
                    AppCard(
                      onTap: () {
                        context.read<LearningCubit>().selectCategory('abc');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LessonScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: FloatBob(
                              distance: 3,
                              child: const AppVectorGraphic(
                                assetPath: AssetPaths.appleIllustration,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alphabet Learning',
                                  style: AppTextStyles.heading3(),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lesson 1 of 26 • Letter A',
                                  style: AppTextStyles.bodySmall(
                                    color: AppColors.textMedium,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const AnimatedFillBar(
                                  value: 0.75,
                                  height: 7,
                                  delay: Duration(milliseconds: 900),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.lavender,
                                      AppColors.primaryPurple,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          PulseGlow(
                            scale: 1.08,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPurple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 7. Mini games & stories shortcuts
              FadeSlideIn(
                delay: const Duration(milliseconds: 900),
                child: Row(
                  children: [
                    Expanded(
                      child: _ShortcutCard(
                        title: 'Match Pairs',
                        subtitle: 'Play mini game!',
                        icon: Icons.extension_rounded,
                        color: AppColors.green,
                        bg: const Color(0xFFF0FDF4),
                        border: const Color(0xFFBBF7D0),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MemoryMatchScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ShortcutCard(
                        title: 'Stories & Songs',
                        subtitle: 'Rhymes & HD videos',
                        icon: Icons.smart_display_rounded,
                        color: AppColors.primaryPurple,
                        bg: const Color(0xFFFAF5FF),
                        border: const Color(0xFFE9D5FF),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const StoriesScreen(),
                          ),
                        ),
                      ),
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

class _StatPill extends StatelessWidget {
  final IconData icon;
  final int value;
  final String prefix;
  final String suffix;
  final Color iconColor;
  final Color bgColor;

  const _StatPill({
    required this.icon,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wiggle(
              trigger: value,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: CountUp(
                  value: value,
                  prefix: prefix,
                  suffix: suffix,
                  style: AppTextStyles.buttonSmall(color: AppColors.textDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      backgroundColor: bg,
      borderColor: border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: Wiggle(
              autoEvery: const Duration(seconds: 4),
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.heading3()),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall(color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}
