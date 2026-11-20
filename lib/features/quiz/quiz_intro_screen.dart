import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/illustrations/kid_scenes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../blocs/quiz_cubit.dart';
import 'quiz_question_screen.dart';

class QuizIntroScreen extends StatelessWidget {
  const QuizIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Kids Fun Quiz', style: AppTextStyles.heading2()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: const TrophyScene(size: 210, confetti: false),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Animal Sounds & Wonders!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Answer 5 fun multiple-choice questions with cheerful illustrations to win glowing stars and earn up to +50 XP!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge(color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 24),

                  // Quiz Details Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCol(
                          Icons.help_outline_rounded,
                          '5 Questions',
                          AppColors.primaryPurple,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.borderLight,
                        ),
                        _buildInfoCol(
                          Icons.star_rounded,
                          '+50 XP Reward',
                          AppColors.yellowDark,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.borderLight,
                        ),
                        _buildInfoCol(
                          Icons.timer_outlined,
                          'No Rush',
                          AppColors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Start Quiz CTA
              Column(
                children: [
                  AppButton(
                    label: 'Start Quiz',
                    width: double.infinity,
                    height: 56,
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () {
                      context.read<QuizCubit>().resetQuiz();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const QuizQuestionScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCol(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.buttonSmall(color: AppColors.textDark),
        ),
      ],
    );
  }
}
