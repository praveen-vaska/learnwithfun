import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/animations/kid_animations.dart';
import '../home/home_dashboard_screen.dart';
import '../learning/categories_screen.dart';
import '../quiz/quiz_intro_screen.dart';
import '../rewards/rewards_screen.dart';
import '../profile/profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavScreen> createState() => MainNavScreenState();
}

class MainNavScreenState extends State<MainNavScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tabAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: 1,
  );

  @override
  void dispose() {
    _tabAnim.dispose();
    super.dispose();
  }

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchTab(int index) {
    if (index >= 0 && index < 5 && index != _currentIndex) {
      setState(() => _currentIndex = index);
      _tabAnim.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeDashboardScreen(onNavigateTab: switchTab),
      const CategoriesScreen(),
      const QuizIntroScreen(),
      const RewardsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _tabAnim, curve: Curves.easeOut),
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _tabAnim, curve: Curves.easeOutCubic),
              ),
          child: IndexedStack(index: _currentIndex, children: screens),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepPurple.withAlpha(20),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.menu_book_rounded, 'Learn'),
                _buildNavItem(2, Icons.quiz_rounded, 'Quiz'),
                _buildNavItem(3, Icons.emoji_events_rounded, 'Rewards'),
                _buildNavItem(4, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => switchTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              width: isSelected ? 52 : 40,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.softPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                // Re-keyed on selection so the icon pops each time it's chosen
                child: isSelected
                    ? PopIn(
                        key: ValueKey('nav$index$_currentIndex'),
                        curve: Curves.elasticOut,
                        duration: const Duration(milliseconds: 600),
                        child: Icon(
                          icon,
                          color: AppColors.primaryPurple,
                          size: 25,
                        ),
                      )
                    : Icon(icon, color: AppColors.textLight, size: 24),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style:
                  AppTextStyles.bodySmall(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : AppColors.textLight,
                  ).copyWith(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
