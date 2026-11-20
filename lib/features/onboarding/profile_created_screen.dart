import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/animations/kid_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../blocs/user_cubit.dart';
import '../main_nav/main_nav_screen.dart';

class ProfileCreatedScreen extends StatelessWidget {
  final String childName;

  const ProfileCreatedScreen({super.key, required this.childName});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConfettiCelebration(
        trigger: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Crown + Avatar Celebration
                SparkleBits(
                  radius: 105,
                  count: 12,
                  child: PopIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 1000),
                    child: FloatBob(
                      distance: 6,
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.yellow,
                                  width: 4,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: AppVectorGraphic(
                                assetPath: userProfile.avatarAsset,
                              ),
                            ),
                            Positioned(
                              top: -24,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x3DF59E0B),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.workspace_premium_rounded,
                                      color: AppColors.textDark,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ready to Learn!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Greeting & Congratulation
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: Column(
                    children: [
                      Text(
                        'Profile Created!',
                        style: AppTextStyles.heading1(
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hi, $childName!\nLet\'s start your learning journey!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading2().copyWith(
                          fontSize: 20,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Exciting stories, fun quizzes, and glowing stars are waiting for you!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Go to Home CTA
                FadeSlideIn(
                  delay: const Duration(milliseconds: 600),
                  child: AppButton(
                    label: 'Go to Home',
                    width: double.infinity,
                    height: 58,
                    icon: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MainNavScreen(),
                        ),
                        (route) => false,
                      );
                    },
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
