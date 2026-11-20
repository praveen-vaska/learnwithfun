import 'package:flutter/material.dart';

import '../../core/animations/kid_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_vector_graphic.dart';

class ChooseAvatarScreen extends StatefulWidget {
  final String currentAvatar;

  const ChooseAvatarScreen({super.key, required this.currentAvatar});

  @override
  State<ChooseAvatarScreen> createState() => _ChooseAvatarScreenState();
}

class _ChooseAvatarScreenState extends State<ChooseAvatarScreen> {
  late String _selectedAvatar;

  final List<Map<String, String>> _avatars = [
    {'asset': AssetPaths.avatarBoy1, 'name': 'Happy Boy'},
    {'asset': AssetPaths.avatarGirl1, 'name': 'Sunny Girl'},
    {'asset': AssetPaths.avatarBoyCap, 'name': 'Cool Explorer'},
    {'asset': AssetPaths.avatarGirlGlasses, 'name': 'Little Genius'},
    {'asset': AssetPaths.avatarPanda, 'name': 'Cute Panda'},
    {'asset': AssetPaths.avatarLion, 'name': 'Brave Lion'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Choose Your Avatar', style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Text(
                'Pick a friendly companion who will learn and grow with you!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
              ),
              const SizedBox(height: 28),

              // Avatar Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final item = _avatars[index];
                    final isSelected = _selectedAvatar == item['asset'];

                    return PopIn(
                      delay: Duration(milliseconds: 100 + index * 90),
                      child: AnimatedScale(
                        scale: isSelected ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAvatar = item['asset']!;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.purpleLight
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryPurple
                                    : AppColors.borderLight,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      const BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: AppVectorGraphic(
                                        assetPath: item['asset']!,
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryPurple,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['name']!,
                                  style: AppTextStyles.bodyLarge(
                                    color: isSelected
                                        ? AppColors.primaryPurple
                                        : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
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
                  Navigator.of(context).pop(_selectedAvatar);
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
