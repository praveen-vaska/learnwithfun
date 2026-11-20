import 'package:flutter/material.dart';

import '../../core/animations/kid_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import 'language_selection_screen.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  int _selectedAgeBandIndex = 1; // Default to 6-8 Years

  final List<Map<String, dynamic>> _ageBands = [
    {
      'title': '3 - 5 Years',
      'subtitle': 'Preschool Fun',
      'iconAsset': AssetPaths.avatarBoyCap,
      'color': const Color(0xFFFEF3C7),
      'ageNumber': 4,
    },
    {
      'title': '6 - 8 Years',
      'subtitle': 'Primary Learning',
      'iconAsset': AssetPaths.avatarBoy1,
      'color': const Color(0xFFEDE9FE),
      'ageNumber': 6,
    },
    {
      'title': '9 - 12 Years',
      'subtitle': 'Advanced Learning',
      'iconAsset': AssetPaths.avatarGirlGlasses,
      'color': const Color(0xFFDCFCE7),
      'ageNumber': 10,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('How old are you?', style: AppTextStyles.heading1()),
              const SizedBox(height: 8),
              Text(
                'Choose your age group so we can customize your fun learning path!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
              ),
              const SizedBox(height: 32),

              // Age Band Cards
              Expanded(
                child: ListView.separated(
                  itemCount: _ageBands.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _ageBands[index];
                    final isSelected = _selectedAgeBandIndex == index;

                    return PopIn(
                      delay: Duration(milliseconds: 120 + index * 120),
                      child: AnimatedScale(
                        scale: isSelected ? 1.03 : 1.0,
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.elasticOut,
                        child: AppCard(
                          onTap: () {
                            setState(() {
                              _selectedAgeBandIndex = index;
                            });
                          },
                          borderColor: isSelected
                              ? AppColors.primaryPurple
                              : AppColors.borderLight,
                          backgroundColor: isSelected
                              ? AppColors.purpleLight
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: item['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                                child: AppVectorGraphic(
                                  assetPath: item['iconAsset'] as String,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: AppTextStyles.heading3(
                                        color: isSelected
                                            ? AppColors.primaryPurple
                                            : AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['subtitle'] as String,
                                      style: AppTextStyles.bodySmall(
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryPurple
                                        : AppColors.borderLight,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? PopIn(
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        child: Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              AppButton(
                label: 'Continue',
                width: double.infinity,
                onPressed: () {
                  final chosenBand = _ageBands[_selectedAgeBandIndex];
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LanguageSelectionScreen(
                        selectedAgeBand: chosenBand['title'] as String,
                        ageNumber: chosenBand['ageNumber'] as int,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
