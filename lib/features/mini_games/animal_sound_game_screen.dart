import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../core/animations/bouncing_widget.dart';
import '../../core/animations/kid_animations.dart';
import '../../blocs/user_cubit.dart';

class AnimalSoundGameScreen extends StatefulWidget {
  const AnimalSoundGameScreen({super.key});

  @override
  State<AnimalSoundGameScreen> createState() => _AnimalSoundGameScreenState();
}

class _AnimalRound {
  final String promptSound;
  final String animalName;
  final String correctAsset;
  final List<({String name, String asset})> choices;

  const _AnimalRound({
    required this.promptSound,
    required this.animalName,
    required this.correctAsset,
    required this.choices,
  });
}

class _AnimalSoundGameScreenState extends State<AnimalSoundGameScreen> {
  final GlobalKey<ConfettiCelebrationState> _confettiKey =
      GlobalKey<ConfettiCelebrationState>();

  int _roundIndex = 0;
  int _score = 0;
  int? _selectedChoice;
  bool _isAnswered = false;

  static const List<_AnimalRound> _rounds = [
    _AnimalRound(
      promptSound: 'Authentic Cow Sound',
      animalName: 'Cow',
      correctAsset: AssetPaths.animalCow,
      choices: [
        (name: 'Cow', asset: AssetPaths.animalCow),
        (name: 'Cat', asset: AssetPaths.animalCat),
        (name: 'Duck', asset: AssetPaths.animalDuck),
        (name: 'Lion', asset: AssetPaths.animalLion),
      ],
    ),
    _AnimalRound(
      promptSound: 'Authentic Cat Sound',
      animalName: 'Cat',
      correctAsset: AssetPaths.animalCat,
      choices: [
        (name: 'Elephant', asset: AssetPaths.animalElephant),
        (name: 'Cat', asset: AssetPaths.animalCat),
        (name: 'Dog', asset: AssetPaths.animalDog),
        (name: 'Duck', asset: AssetPaths.animalDuck),
      ],
    ),
    _AnimalRound(
      promptSound: 'Authentic Dog Bark',
      animalName: 'Dog',
      correctAsset: AssetPaths.animalDog,
      choices: [
        (name: 'Dog', asset: AssetPaths.animalDog),
        (name: 'Sheep', asset: AssetPaths.animalSheep),
        (name: 'Cow', asset: AssetPaths.animalCow),
        (name: 'Cat', asset: AssetPaths.animalCat),
      ],
    ),
    _AnimalRound(
      promptSound: 'Authentic Lion Roar',
      animalName: 'Lion',
      correctAsset: AssetPaths.animalLion,
      choices: [
        (name: 'Monkey', asset: AssetPaths.animalMonkey),
        (name: 'Cow', asset: AssetPaths.animalCow),
        (name: 'Lion', asset: AssetPaths.animalLion),
        (name: 'Cat', asset: AssetPaths.animalCat),
      ],
    ),
    _AnimalRound(
      promptSound: 'Authentic Duck Quack',
      animalName: 'Duck',
      correctAsset: AssetPaths.animalDuck,
      choices: [
        (name: 'Duck', asset: AssetPaths.animalDuck),
        (name: 'Cow', asset: AssetPaths.animalCow),
        (name: 'Sheep', asset: AssetPaths.animalSheep),
        (name: 'Frog', asset: AssetPaths.animalFrog),
      ],
    ),
    _AnimalRound(
      promptSound: 'Authentic Sheep Bleat',
      animalName: 'Sheep',
      correctAsset: AssetPaths.animalSheep,
      choices: [
        (name: 'Dog', asset: AssetPaths.animalDog),
        (name: 'Cow', asset: AssetPaths.animalCow),
        (name: 'Sheep', asset: AssetPaths.animalSheep),
        (name: 'Elephant', asset: AssetPaths.animalElephant),
      ],
    ),
    _AnimalRound(
      promptSound: 'Authentic Elephant Trumpet',
      animalName: 'Elephant',
      correctAsset: AssetPaths.animalElephant,
      choices: [
        (name: 'Lion', asset: AssetPaths.animalLion),
        (name: 'Elephant', asset: AssetPaths.animalElephant),
        (name: 'Cow', asset: AssetPaths.animalCow),
        (name: 'Monkey', asset: AssetPaths.animalMonkey),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSound();
    });
  }

  void _playSound() {
    final round = _rounds[_roundIndex];
    AppAudioService.instance.playAnimalSound(round.animalName);
  }

  void _selectChoice(int index) {
    if (_isAnswered) return;
    AppAudioService.instance.playTapSound();

    final round = _rounds[_roundIndex];
    final chosen = round.choices[index];
    final correct = chosen.name == round.animalName;

    setState(() {
      _selectedChoice = index;
      _isAnswered = true;
      if (correct) {
        _score += 20;
      }
    });

    if (correct) {
      AppAudioService.instance.playSuccessChime();
      _confettiKey.currentState?.play();
    } else {
      AppAudioService.instance.playIncorrectSound();
    }

    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_roundIndex < _rounds.length - 1) {
        setState(() {
          _roundIndex++;
          _selectedChoice = null;
          _isAnswered = false;
        });
        _playSound();
      } else {
        // Finished all rounds
        context.read<UserCubit>().addXp(30);
        AppAudioService.instance.playCelebrationFanfare();
        _showVictoryDialog();
      }
    });
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stars_rounded,
              color: AppColors.yellowDark,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              'Animal Sound Champion!',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading1(color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 8),
            Text(
              'You recognized all the animal sounds!\nScore: $_score Points\n+30 XP Earned!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge(color: AppColors.textMedium),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Play Again',
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      setState(() {
                        _roundIndex = 0;
                        _score = 0;
                        _selectedChoice = null;
                        _isAnswered = false;
                      });
                      _playSound();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Done',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final round = _rounds[_roundIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Animal Sounds Guess', style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            AppAudioService.instance.stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ConfettiCelebration(
        key: _confettiKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // 1. Progress & Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softPurple,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Round ${_roundIndex + 1} / ${_rounds.length}',
                        style: AppTextStyles.buttonSmall(
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.yellowDark,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Score: $_score',
                            style: AppTextStyles.buttonSmall(
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Big Audio Card: "Listen to the Sound!"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7952F5), Color(0xFFA68BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Who makes this sound?',
                        style: AppTextStyles.heading2(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"${round.promptSound}"',
                        style: AppTextStyles.bodyMedium(
                          color: const Color(0xFFFFE16A),
                        ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 14),
                      BouncingWidget(
                        onTap: _playSound,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.volume_up_rounded,
                                color: AppColors.primaryPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hear Sound Again 🔊',
                                style: AppTextStyles.buttonSmall(
                                  color: AppColors.primaryPurple,
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

                // 3. 4 Animal Choices
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.05,
                        ),
                    itemCount: round.choices.length,
                    itemBuilder: (context, index) {
                      final choice = round.choices[index];
                      final isSelected = _selectedChoice == index;
                      final isCorrect = choice.name == round.animalName;

                      Color cardBg = Colors.white;
                      Color borderColor = AppColors.borderLight;

                      if (_isAnswered) {
                        if (isCorrect) {
                          cardBg = const Color(0xFFDCFCE7);
                          borderColor = AppColors.green;
                        } else if (isSelected) {
                          cardBg = const Color(0xFFFEE2E2);
                          borderColor = AppColors.red;
                        }
                      }

                      return BouncingWidget(
                        onTap: () => _selectChoice(index),
                        child: AppCard(
                          backgroundColor: cardBg,
                          borderColor: borderColor,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: FloatBob(
                                    distance: 4,
                                    child: AppVectorGraphic(
                                      assetPath: choice.asset,
                                      width: 75,
                                      height: 75,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                choice.name,
                                style: AppTextStyles.heading3(
                                  color: AppColors.textDark,
                                ).copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
