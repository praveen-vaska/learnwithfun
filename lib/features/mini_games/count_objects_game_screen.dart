import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../core/animations/bouncing_widget.dart';
import '../../core/animations/kid_animations.dart';
import '../../blocs/user_cubit.dart';

class CountObjectsGameScreen extends StatefulWidget {
  const CountObjectsGameScreen({super.key});

  @override
  State<CountObjectsGameScreen> createState() => _CountObjectsGameScreenState();
}

class _CountRound {
  final String itemName;
  final String itemAsset;
  final int count;
  final List<int> numberOptions;

  const _CountRound({
    required this.itemName,
    required this.itemAsset,
    required this.count,
    required this.numberOptions,
  });
}

class _CountObjectsGameScreenState extends State<CountObjectsGameScreen> {
  final GlobalKey<ConfettiCelebrationState> _confettiKey =
      GlobalKey<ConfettiCelebrationState>();

  int _roundIndex = 0;
  int _score = 0;
  int? _selectedNumber;
  bool _isAnswered = false;
  final Set<int> _tappedItemIndices = {};

  static const List<_CountRound> _rounds = [
    _CountRound(
      itemName: 'Apples',
      itemAsset: AssetPaths.appleIllustration,
      count: 3,
      numberOptions: [2, 3, 4, 5],
    ),
    _CountRound(
      itemName: 'Ducks',
      itemAsset: AssetPaths.animalDuck,
      count: 4,
      numberOptions: [3, 4, 5, 6],
    ),
    _CountRound(
      itemName: 'Stars',
      itemAsset: AssetPaths.shapeStar,
      count: 5,
      numberOptions: [4, 5, 6, 7],
    ),
    _CountRound(
      itemName: 'Cows',
      itemAsset: AssetPaths.animalCow,
      count: 2,
      numberOptions: [1, 2, 3, 4],
    ),
    _CountRound(
      itemName: 'Cats',
      itemAsset: AssetPaths.animalCat,
      count: 6,
      numberOptions: [4, 5, 6, 8],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptVoice();
    });
  }

  void _promptVoice() {
    final round = _rounds[_roundIndex];
    AppAudioService.instance.speak(
      'How many ${round.itemName} do you see? Tap them to count!',
    );
  }

  void _onItemTap(int index) {
    AppAudioService.instance.playTapSound();
    setState(() {
      _tappedItemIndices.add(index);
    });
    // Speak number counted so far
    AppAudioService.instance.speak('${_tappedItemIndices.length}');
  }

  void _onNumberSelected(int num) {
    if (_isAnswered) return;
    AppAudioService.instance.playTapSound();

    final round = _rounds[_roundIndex];
    final isCorrect = num == round.count;

    setState(() {
      _selectedNumber = num;
      _isAnswered = true;
      if (isCorrect) {
        _score += 20;
      }
    });

    if (isCorrect) {
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
          _selectedNumber = null;
          _isAnswered = false;
          _tappedItemIndices.clear();
        });
        _promptVoice();
      } else {
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
              Icons.pin_rounded,
              color: AppColors.primaryPurple,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              'Counting Master!',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading1(color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 8),
            Text(
              'You counted every single item correctly!\nScore: $_score Points\n+30 XP Earned!',
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
                        _selectedNumber = null;
                        _isAnswered = false;
                        _tappedItemIndices.clear();
                      });
                      _promptVoice();
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
        title: Text('Count & Learn', style: AppTextStyles.heading2()),
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
                const SizedBox(height: 16),

                // 2. Playful Question Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'How many ${round.itemName} do you see?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading2().copyWith(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.primaryPurple,
                      ),
                      onPressed: _promptVoice,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3. Counting Box with items
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppColors.primaryPurple.withAlpha(40),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Wrap(
                        spacing: 18,
                        runSpacing: 18,
                        alignment: WrapAlignment.center,
                        children: List.generate(round.count, (index) {
                          final isCounted = _tappedItemIndices.contains(index);
                          return BouncingWidget(
                            onTap: () => _onItemTap(index),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                FloatBob(
                                  distance: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCounted
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFF7F5FC),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isCounted
                                            ? AppColors.green
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: AppVectorGraphic(
                                      assetPath: round.itemAsset,
                                      width: 65,
                                      height: 65,
                                    ),
                                  ),
                                ),
                                if (isCounted)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Number Selection Row (4 Buttons)
                Text(
                  'Choose the correct number:',
                  style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
                ),
                const SizedBox(height: 10),
                Row(
                  children: round.numberOptions.map((number) {
                    final isSelected = _selectedNumber == number;
                    final isCorrect = number == round.count;

                    Color btnBg = Colors.white;
                    Color border = AppColors.borderLight;
                    Color textColor = AppColors.textDark;

                    if (_isAnswered) {
                      if (isCorrect) {
                        btnBg = const Color(0xFFDCFCE7);
                        border = AppColors.green;
                        textColor = AppColors.green;
                      } else if (isSelected) {
                        btnBg = const Color(0xFFFEE2E2);
                        border = AppColors.red;
                        textColor = AppColors.red;
                      }
                    }

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: BouncingWidget(
                          onTap: () => _onNumberSelected(number),
                          child: Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: btnBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: border, width: 2.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$number',
                                style: AppTextStyles.heading1(color: textColor)
                                    .copyWith(fontSize: 28),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
