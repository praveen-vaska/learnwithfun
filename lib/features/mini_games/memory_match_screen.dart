import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/animations/bouncing_widget.dart';
import '../../core/animations/kid_animations.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/confetti_overlay.dart';

import 'dart:math' as math;

import '../../blocs/mini_game_cubit.dart';
import '../../blocs/user_cubit.dart';
import '../../data/models/match_pair_level.dart';
import '../../data/services/local_storage_service.dart';

class MemoryMatchScreen extends StatelessWidget {
  final int? initialLevel;

  const MemoryMatchScreen({super.key, this.initialLevel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = MiniGameCubit(
          storage: LocalStorageService(),
          initialLevel: initialLevel ?? 1,
        );
        if (initialLevel != null) {
          cubit.startLevel(initialLevel!);
        }
        return cubit;
      },
      child: const _MemoryMatchRootView(),
    );
  }
}

class _MemoryMatchRootView extends StatelessWidget {
  const _MemoryMatchRootView();

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<MiniGameCubit>().state;

    if (gameState.viewMode == MiniGameViewMode.levelMap) {
      return const _LevelSelectionView();
    }
    return const _GamePlayView();
  }
}

// ==========================================
// 1. LEVEL SELECTION VIEW (10 Progressive Levels)
// ==========================================

class _LevelSelectionView extends StatelessWidget {
  const _LevelSelectionView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MiniGameCubit>().state;
    final unlocked = state.unlockedLevel;
    final starsMap = state.levelStars;

    int totalStars = 0;
    for (final s in starsMap.values) {
      totalStars += s;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Match Pairs Levels', style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.yellowDark.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.yellowDark,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$totalStars / 30',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🧩', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Solve Level to Unlock Next! 🚀',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Progress: $unlocked of ${MatchPairLevel.allLevels.length} Levels Unlocked',
                            style: AppTextStyles.bodySmall(
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Level Grid / Path
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: MatchPairLevel.allLevels.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final level = MatchPairLevel.allLevels[index];
                  final isUnlocked = level.levelNumber <= unlocked;
                  final stars = starsMap[level.levelNumber] ?? 0;

                  return _LevelListItem(
                    level: level,
                    isUnlocked: isUnlocked,
                    stars: stars,
                    onTap: () {
                      if (isUnlocked) {
                        AppAudioService.instance.playTapSound();
                        context.read<MiniGameCubit>().startLevel(
                          level.levelNumber,
                        );
                      } else {
                        AppAudioService.instance.playCardFlipSound();
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🔒 Solve Level ${level.levelNumber - 1} first to unlock ${level.title}!',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: AppColors.primaryPurple,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelListItem extends StatelessWidget {
  final MatchPairLevel level;
  final bool isUnlocked;
  final int stars;
  final VoidCallback onTap;

  const _LevelListItem({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked ? AppColors.borderLight : Colors.grey.shade300,
            width: isUnlocked ? 1.4 : 1,
          ),
          boxShadow: isUnlocked
              ? const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Level Number & Emoji Avatar
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? level.difficultyColor.withAlpha(30)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: isUnlocked
                    ? Text(level.emoji, style: const TextStyle(fontSize: 28))
                    : const Icon(
                        Icons.lock_rounded,
                        color: Colors.grey,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Level Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? AppColors.softPurple
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Level ${level.levelNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? AppColors.primaryPurple
                                : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: level.difficultyColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          level.difficulty,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: level.difficultyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.title,
                    style: AppTextStyles.heading3(
                      color: isUnlocked
                          ? AppColors.textDark
                          : Colors.grey.shade600,
                    ).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${level.pairs.length} Pairs • ${level.totalCards} Cards • ${level.timeSeconds}s',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnlocked ? AppColors.textMedium : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Stars & Play Action
            if (isUnlocked)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (starIdx) {
                      return Icon(
                        starIdx < stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: starIdx < stars
                            ? AppColors.yellowDark
                            : Colors.grey.shade400,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Play ▶',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. ACTIVE GAME PLAY VIEW
// ==========================================

class _GamePlayView extends StatelessWidget {
  const _GamePlayView();

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<MiniGameCubit>().state;
    final level = gameState.currentLevel;

    // Format timer
    final minutes = (gameState.secondsRemaining ~/ 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (gameState.secondsRemaining % 60).toString().padLeft(
      2,
      '0',
    );

    // Handle Victory
    if (gameState.isVictory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppAudioService.instance.playCelebrationFanfare();
        context.read<UserCubit>().addXp(25);
        _showVictoryDialog(context, gameState);
      });
    }

    // Handle Game Over (Time's Up)
    if (gameState.isGameOver && !gameState.isVictory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppAudioService.instance.playIncorrectSound();
        _showGameOverDialog(context, gameState);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lvl ${level.levelNumber}: ${level.title} ${level.emoji}',
              style: AppTextStyles.heading2().copyWith(fontSize: 17),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.grid_view_rounded),
          tooltip: 'Level Map',
          onPressed: () {
            context.read<MiniGameCubit>().showLevelMap();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryPurple,
            ),
            tooltip: 'Restart Level',
            onPressed: () {
              context.read<MiniGameCubit>().restartGame();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // 1. Stats Bar (Level, Timer, Moves, Score)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: gameState.secondsRemaining <= 10
                            ? const Color(0xFFFEE2E2)
                            : AppColors.softPurple,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: gameState.secondsRemaining <= 10
                                ? AppColors.red
                                : AppColors.primaryPurple,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$minutes:$seconds',
                            style: AppTextStyles.buttonSmall(
                              color: gameState.secondsRemaining <= 10
                                  ? AppColors.red
                                  : AppColors.primaryPurple,
                            ).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    // Pairs Found Counter
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${gameState.cards.where((c) => c.isMatched).length ~/ 2}/${level.pairCount} Pairs',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),

                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
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
                            '${gameState.score} pts',
                            style: AppTextStyles.buttonSmall(
                              color: AppColors.textDark,
                            ).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Responsive Cards Grid
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: level.crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: level.crossAxisCount == 2
                        ? 0.95
                        : level.crossAxisCount == 3
                        ? 0.82
                        : 0.78,
                  ),
                  itemCount: gameState.cards.length,
                  itemBuilder: (context, index) {
                    final card = gameState.cards[index];
                    final isRevealed = card.isFlipped || card.isMatched;

                    return BouncingWidget(
                      onTap: () {
                        AppAudioService.instance.playCardFlipSound();
                        context.read<MiniGameCubit>().flipCard(index);
                      },
                      child: PopIn(
                        delay: Duration(milliseconds: 60 + index * 35),
                        child: Wiggle(
                          trigger: card.isMatched,
                          angle: 0.08,
                          child: _FlipCard(
                            revealed: isRevealed,
                            front: _buildFront(
                              card.assetPath,
                              card.label,
                              card.isMatched,
                            ),
                            back: _buildBack(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showVictoryDialog(BuildContext context, MiniGameState gameState) {
    final level = gameState.currentLevel;
    final isLastLevel = level.levelNumber >= MatchPairLevel.allLevels.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ConfettiCelebration(
          trigger: true,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            contentPadding: const EdgeInsets.all(22),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.yellowDark,
                  size: 64,
                ),
                const SizedBox(height: 8),
                Text(
                  isLastLevel
                      ? 'Grand Master Champion! 👑'
                      : 'Level ${level.levelNumber} Solved! 🎉',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading1(color: AppColors.primaryPurple)
                      .copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),

                // Stars display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Icon(
                      i < gameState.starsEarned
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < gameState.starsEarned
                          ? AppColors.yellowDark
                          : Colors.grey.shade400,
                      size: 34,
                    );
                  }),
                ),
                const SizedBox(height: 10),

                Text(
                  'Score: ${gameState.score} • Moves: ${gameState.movesCount}\nTime Left: ${gameState.secondsRemaining}s • +25 XP Earned!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Column(
                  children: [
                    if (!isLastLevel) ...[
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: 'Next Level (Lvl ${level.levelNumber + 1}) 🚀',
                          variant: AppButtonVariant.primary,
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context.read<MiniGameCubit>().nextLevel();
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Replay 🔄',
                            variant: AppButtonVariant.outline,
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.read<MiniGameCubit>().restartGame();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            label: 'Levels 🗺️',
                            variant: isLastLevel
                                ? AppButtonVariant.primary
                                : AppButtonVariant.outline,
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.read<MiniGameCubit>().showLevelMap();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGameOverDialog(BuildContext context, MiniGameState gameState) {
    final level = gameState.currentLevel;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          contentPadding: const EdgeInsets.all(22),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.hourglass_bottom_rounded,
                color: Color(0xFFEA580C),
                size: 58,
              ),
              const SizedBox(height: 12),
              Text(
                'Time\'s Up! ⏰',
                style: AppTextStyles.heading1(color: const Color(0xFFEA580C))
                    .copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Don\'t give up! Practice makes perfect.\nGive Level ${level.levelNumber} another try!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Try Again 🔄',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<MiniGameCubit>().restartGame();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: 'Levels 🗺️',
                      variant: AppButtonVariant.outline,
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<MiniGameCubit>().showLevelMap();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildFront(String asset, String label, bool matched) {
  return Container(
    decoration: BoxDecoration(
      color: matched ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7E6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: matched ? AppColors.green : const Color(0xFFFFC56B),
        width: 2.2,
      ),
      boxShadow: const [
        BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 3)),
      ],
    ),
    padding: const EdgeInsets.all(6),
    child: Column(
      children: [
        Expanded(child: AppVectorGraphic(assetPath: asset)),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTextStyles.buttonSmall(color: AppColors.textDark)
              .copyWith(fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget _buildBack() {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFA68BFF), Color(0xFF7952F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withAlpha(120), width: 1.8),
      boxShadow: const [
        BoxShadow(
          color: AppColors.deepShadow,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Center(
      child: Text(
        '?',
        style: AppTextStyles.heading1(color: Colors.white).copyWith(
          fontSize: 32,
          shadows: const [
            Shadow(
              color: Color(0x553B0764),
              offset: Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    ),
  );
}

/// 3D Y-axis card flip between [back] (hidden) and [front] (revealed).
class _FlipCard extends StatelessWidget {
  final bool revealed;
  final Widget front;
  final Widget back;

  const _FlipCard({
    required this.revealed,
    required this.front,
    required this.back,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: revealed ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutBack,
      builder: (context, v, _) {
        final angle = v * math.pi;
        final showFront = v >= 0.5;
        final lift = 1 + 0.06 * math.sin(v.clamp(0.0, 1.0) * math.pi);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle)
            ..scaleByDouble(lift, lift, 1, 1),
          child: showFront
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: front,
                )
              : back,
        );
      },
    );
  }
}
