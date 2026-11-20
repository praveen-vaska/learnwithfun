import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../blocs/user_cubit.dart';
import 'choose_avatar_screen.dart';
import 'profile_created_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  final String selectedAgeBand;
  final int ageNumber;
  final String selectedLanguage;

  const CreateProfileScreen({
    super.key,
    required this.selectedAgeBand,
    required this.ageNumber,
    required this.selectedLanguage,
  });

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Arab',
  );
  late int _selectedAge;
  String _selectedAvatar = AssetPaths.avatarBoy1;

  final List<String> _quickAvatars = [
    AssetPaths.avatarBoy1,
    AssetPaths.avatarGirl1,
    AssetPaths.avatarBoyCap,
    AssetPaths.avatarGirlGlasses,
    AssetPaths.avatarPanda,
    AssetPaths.avatarLion,
  ];

  @override
  void initState() {
    super.initState();
    _selectedAge = widget.ageNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onCreateProfile() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter child’s lovely name!'),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
      return;
    }

    context.read<UserCubit>().setProfile(
      name: name,
      age: _selectedAge,
      ageBand: widget.selectedAgeBand,
      avatarAsset: _selectedAvatar,
      language: widget.selectedLanguage,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ProfileCreatedScreen(childName: name),
      ),
    );
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Create Your Profile', style: AppTextStyles.heading1()),
              const SizedBox(height: 8),
              Text(
                'Let\'s make your learning space personal and exciting!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
              ),
              const SizedBox(height: 28),

              // Hero Avatar Preview with Edit Badge
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (context) =>
                          ChooseAvatarScreen(currentAvatar: _selectedAvatar),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _selectedAvatar = result;
                    });
                  }
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      padding: const EdgeInsets.all(6),
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
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AppVectorGraphic(assetPath: _selectedAvatar),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Child's Name Input
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Child\'s Name',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _nameController,
                      style: AppTextStyles.heading3(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter name (e.g. Arab)',
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Age Selector Dropdown Card
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Age',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_selectedAge Years',
                          style: AppTextStyles.heading3(),
                        ),
                      ],
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedAge,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primaryPurple,
                          size: 28,
                        ),
                        items: List.generate(
                          10,
                          (index) => DropdownMenuItem(
                            value: index + 3,
                            child: Text(
                              '${index + 3} Years',
                              style: AppTextStyles.bodyLarge(),
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedAge = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Avatar Carousel Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Avatar', style: AppTextStyles.heading3()),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                          builder: (context) => ChooseAvatarScreen(
                            currentAvatar: _selectedAvatar,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedAvatar = result;
                        });
                      }
                    },
                    child: Text(
                      'View All',
                      style: AppTextStyles.buttonSmall(
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickAvatars.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final avatar = _quickAvatars[index];
                    final isSelected = _selectedAvatar == avatar;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 70,
                        height: 70,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryPurple
                                : AppColors.borderLight,
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  const BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: AppVectorGraphic(assetPath: avatar),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),

              // Create Profile Button
              AppButton(
                label: 'Create Profile',
                width: double.infinity,
                onPressed: _onCreateProfile,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
