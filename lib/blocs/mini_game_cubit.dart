import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/services/audio_service.dart';
import '../../data/models/match_pair_level.dart';
import '../../data/services/local_storage_service.dart';

class MemoryCard extends Equatable {
  final int id;
  final String assetPath;
  final String label;
  final bool isFlipped;
  final bool isMatched;

  const MemoryCard({
    required this.id,
    required this.assetPath,
    required this.label,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({
    int? id,
    String? assetPath,
    String? label,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      assetPath: assetPath ?? this.assetPath,
      label: label ?? this.label,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  List<Object?> get props => [id, assetPath, label, isFlipped, isMatched];
}

enum MiniGameViewMode { levelMap, playing }

class MiniGameState extends Equatable {
  final MiniGameViewMode viewMode;
  final MatchPairLevel currentLevel;
  final int unlockedLevel;
  final Map<int, int> levelStars;
  final List<MemoryCard> cards;
  final int score;
  final int secondsRemaining;
  final int totalTimeSeconds;
  final int movesCount;
  final bool isGameOver;
  final bool isVictory;
  final int starsEarned;
  final int? firstFlippedIndex;
  final int? secondFlippedIndex;
  final bool isCheckingMatch;

  const MiniGameState({
    this.viewMode = MiniGameViewMode.levelMap,
    required this.currentLevel,
    this.unlockedLevel = 1,
    this.levelStars = const {},
    required this.cards,
    this.score = 0,
    this.secondsRemaining = 35,
    this.totalTimeSeconds = 35,
    this.movesCount = 0,
    this.isGameOver = false,
    this.isVictory = false,
    this.starsEarned = 0,
    this.firstFlippedIndex,
    this.secondFlippedIndex,
    this.isCheckingMatch = false,
  });

  MiniGameState copyWith({
    MiniGameViewMode? viewMode,
    MatchPairLevel? currentLevel,
    int? unlockedLevel,
    Map<int, int>? levelStars,
    List<MemoryCard>? cards,
    int? score,
    int? secondsRemaining,
    int? totalTimeSeconds,
    int? movesCount,
    bool? isGameOver,
    bool? isVictory,
    int? starsEarned,
    int? firstFlippedIndex,
    int? secondFlippedIndex,
    bool clearFirst = false,
    bool clearSecond = false,
    bool? isCheckingMatch,
  }) {
    return MiniGameState(
      viewMode: viewMode ?? this.viewMode,
      currentLevel: currentLevel ?? this.currentLevel,
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      levelStars: levelStars ?? this.levelStars,
      cards: cards ?? this.cards,
      score: score ?? this.score,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      movesCount: movesCount ?? this.movesCount,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      starsEarned: starsEarned ?? this.starsEarned,
      firstFlippedIndex: clearFirst
          ? null
          : (firstFlippedIndex ?? this.firstFlippedIndex),
      secondFlippedIndex: clearSecond
          ? null
          : (secondFlippedIndex ?? this.secondFlippedIndex),
      isCheckingMatch: isCheckingMatch ?? this.isCheckingMatch,
    );
  }

  @override
  List<Object?> get props => [
    viewMode,
    currentLevel,
    unlockedLevel,
    levelStars,
    cards,
    score,
    secondsRemaining,
    totalTimeSeconds,
    movesCount,
    isGameOver,
    isVictory,
    starsEarned,
    firstFlippedIndex,
    secondFlippedIndex,
    isCheckingMatch,
  ];
}

class MiniGameCubit extends Cubit<MiniGameState> {
  final LocalStorageService _storage;
  Timer? _timer;

  MiniGameCubit({LocalStorageService? storage, int initialLevel = 1})
    : _storage = storage ?? LocalStorageService(),
      super(
        MiniGameState(
          viewMode: MiniGameViewMode.levelMap,
          currentLevel: MatchPairLevel.getLevel(initialLevel),
          cards: _generateCardsForLevel(MatchPairLevel.getLevel(initialLevel)),
          secondsRemaining: MatchPairLevel.getLevel(initialLevel).timeSeconds,
          totalTimeSeconds: MatchPairLevel.getLevel(initialLevel).timeSeconds,
        ),
      ) {
    _loadProgress();
  }

  void _loadProgress() {
    final unlocked = _storage.loadMatchPairsUnlockedLevel();
    final stars = _storage.loadMatchPairsStars();
    emit(state.copyWith(unlockedLevel: unlocked, levelStars: stars));
  }

  static List<MemoryCard> _generateCardsForLevel(MatchPairLevel level) {
    final List<MemoryCard> list = [];
    int id = 0;
    for (final pair in level.pairs) {
      list.add(
        MemoryCard(id: id++, assetPath: pair['asset']!, label: pair['label']!),
      );
      list.add(
        MemoryCard(id: id++, assetPath: pair['asset']!, label: pair['label']!),
      );
    }
    list.shuffle();
    return list;
  }

  void showLevelMap() {
    _timer?.cancel();
    emit(
      state.copyWith(
        viewMode: MiniGameViewMode.levelMap,
        isGameOver: false,
        isVictory: false,
      ),
    );
  }

  void startLevel(int levelNumber) {
    _timer?.cancel();
    final level = MatchPairLevel.getLevel(levelNumber);
    final cards = _generateCardsForLevel(level);

    emit(
      state.copyWith(
        viewMode: MiniGameViewMode.playing,
        currentLevel: level,
        cards: cards,
        score: 0,
        movesCount: 0,
        secondsRemaining: level.timeSeconds,
        totalTimeSeconds: level.timeSeconds,
        isGameOver: false,
        isVictory: false,
        starsEarned: 0,
        clearFirst: true,
        clearSecond: true,
        isCheckingMatch: false,
      ),
    );

    _startTimer();
  }

  void nextLevel() {
    if (state.currentLevel.levelNumber < MatchPairLevel.allLevels.length) {
      startLevel(state.currentLevel.levelNumber + 1);
    } else {
      showLevelMap();
    }
  }

  void restartGame() {
    startLevel(state.currentLevel.levelNumber);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0 && !state.isGameOver && !state.isVictory) {
        emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
      } else {
        timer.cancel();
        if (!state.isVictory) {
          emit(state.copyWith(isGameOver: true));
        }
      }
    });
  }

  void flipCard(int index) {
    if (state.isCheckingMatch ||
        state.cards[index].isFlipped ||
        state.cards[index].isMatched ||
        state.isGameOver ||
        state.isVictory) {
      return;
    }

    final updatedCards = List<MemoryCard>.from(state.cards);
    updatedCards[index] = updatedCards[index].copyWith(isFlipped: true);

    if (state.firstFlippedIndex == null) {
      emit(state.copyWith(cards: updatedCards, firstFlippedIndex: index));
    } else {
      // Second card flipped -> count a move!
      final firstIdx = state.firstFlippedIndex!;
      final newMoves = state.movesCount + 1;

      emit(
        state.copyWith(
          cards: updatedCards,
          secondFlippedIndex: index,
          isCheckingMatch: true,
          movesCount: newMoves,
        ),
      );

      final firstCard = updatedCards[firstIdx];
      final secondCard = updatedCards[index];

      if (firstCard.label == secondCard.label) {
        // MATCH!
        AppAudioService.instance.playSuccessChime();
        Future.delayed(const Duration(milliseconds: 300), () {
          final matchedList = List<MemoryCard>.from(state.cards);
          matchedList[firstIdx] = matchedList[firstIdx].copyWith(
            isMatched: true,
          );
          matchedList[index] = matchedList[index].copyWith(isMatched: true);

          final allMatched = matchedList.every((c) => c.isMatched);
          final earnedScore = state.score + 25;

          if (allMatched) {
            _timer?.cancel();

            // Calculate Stars (1 to 3 stars based on time left)
            final percentTimeLeft =
                state.secondsRemaining / state.totalTimeSeconds;
            int stars = 1;
            if (percentTimeLeft >= 0.45) {
              stars = 3;
            } else if (percentTimeLeft >= 0.18) {
              stars = 2;
            }

            final currentLevelNum = state.currentLevel.levelNumber;
            final nextUnlocked =
                (currentLevelNum < MatchPairLevel.allLevels.length)
                ? (currentLevelNum + 1 > state.unlockedLevel
                      ? currentLevelNum + 1
                      : state.unlockedLevel)
                : state.unlockedLevel;

            // Persist unlocked level & stars
            _storage.saveMatchPairsUnlockedLevel(nextUnlocked);
            _storage.saveMatchPairsStars(currentLevelNum, stars);

            final updatedStarsMap = Map<int, int>.from(state.levelStars);
            if (stars > (updatedStarsMap[currentLevelNum] ?? 0)) {
              updatedStarsMap[currentLevelNum] = stars;
            }

            emit(
              state.copyWith(
                cards: matchedList,
                score: earnedScore,
                clearFirst: true,
                clearSecond: true,
                isCheckingMatch: false,
                isVictory: true,
                starsEarned: stars,
                unlockedLevel: nextUnlocked,
                levelStars: updatedStarsMap,
              ),
            );
          } else {
            emit(
              state.copyWith(
                cards: matchedList,
                score: earnedScore,
                clearFirst: true,
                clearSecond: true,
                isCheckingMatch: false,
              ),
            );
          }
        });
      } else {
        // NOT A MATCH, flip back
        Future.delayed(const Duration(milliseconds: 700), () {
          final resetList = List<MemoryCard>.from(state.cards);
          resetList[firstIdx] = resetList[firstIdx].copyWith(isFlipped: false);
          resetList[index] = resetList[index].copyWith(isFlipped: false);

          emit(
            state.copyWith(
              cards: resetList,
              clearFirst: true,
              clearSecond: true,
              isCheckingMatch: false,
            ),
          );
        });
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
