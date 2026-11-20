import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/animations/kid_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../blocs/user_cubit.dart';
import 'create_profile_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String selectedAgeBand;
  final int ageNumber;

  const LanguageSelectionScreen({
    super.key,
    required this.selectedAgeBand,
    required this.ageNumber,
  });

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English', 'flagAsset': AssetPaths.flagUk},
    {
      'name': 'Telugu',
      'native': 'తెలుగు (Telugu)',
      'flagAsset': AssetPaths.flagTelugu,
    },
    {
      'name': 'Hindi',
      'native': 'हिन्दी (Hindi)',
      'flagAsset': AssetPaths.flagHindi,
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
              Text('Choose Language', style: AppTextStyles.heading1()),
              const SizedBox(height: 8),
              Text(
                'Select the preferred voice and text language for learning stories and lessons.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
              ),
              const SizedBox(height: 32),

              // Language List
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _languages[index];
                    final isSelected = _selectedLanguage == item['name'];

                    return PopIn(
                      delay: Duration(milliseconds: 120 + index * 120),
                      child: AnimatedScale(
                        scale: isSelected ? 1.03 : 1.0,
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.elasticOut,
                        child: AppCard(
                          onTap: () {
                            setState(() {
                              _selectedLanguage = item['name']!;
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
                            vertical: 18,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                    width: 1,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: AppVectorGraphic(
                                  assetPath: item['flagAsset']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name']!,
                                      style: AppTextStyles.heading3(
                                        color: isSelected
                                            ? AppColors.primaryPurple
                                            : AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['native']!,
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
                  context.read<UserCubit>().updateLanguage(_selectedLanguage);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateProfileScreen(
                        selectedAgeBand: widget.selectedAgeBand,
                        ageNumber: widget.ageNumber,
                        selectedLanguage: _selectedLanguage,
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
