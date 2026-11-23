import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/quiz_question.dart';
import '../data/repositories/learning_repository.dart';

class QuizState extends Equatable {
  final int currentLevelNumber;
  final int unlockedLevel;
  final Map<int, int> levelStars;
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final int? selectedOptionIndex;
  final bool isSubmitted;
  final bool isAnswerCorrect;
  final int score;
  final int earnedXp;
  final bool isQuizCompleted;
  final int starsEarned;

  const QuizState({
    this.currentLevelNumber = 1,
    this.unlockedLevel = 1,
    this.levelStars = const {},
    required this.questions,
    this.currentQuestionIndex = 0,
    this.selectedOptionIndex,
    this.isSubmitted = false,
    this.isAnswerCorrect = false,
    this.score = 0,
    this.earnedXp = 0,
    this.isQuizCompleted = false,
    this.starsEarned = 0,
  });

  QuizQuestion? get currentQuestion =>
      questions.isNotEmpty && currentQuestionIndex < questions.length
          ? questions[currentQuestionIndex]
          : null;

  QuizState copyWith({
    int? currentLevelNumber,
    int? unlockedLevel,
    Map<int, int>? levelStars,
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    int? selectedOptionIndex,
    bool clearSelection = false,
    bool? isSubmitted,
    bool? isAnswerCorrect,
    int? score,
    int? earnedXp,
    bool? isQuizCompleted,
    int? starsEarned,
  }) {
    return QuizState(
      currentLevelNumber: currentLevelNumber ?? this.currentLevelNumber,
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      levelStars: levelStars ?? this.levelStars,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOptionIndex: clearSelection
          ? null
          : (selectedOptionIndex ?? this.selectedOptionIndex),
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isAnswerCorrect: isAnswerCorrect ?? this.isAnswerCorrect,
      score: score ?? this.score,
      earnedXp: earnedXp ?? this.earnedXp,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
      starsEarned: starsEarned ?? this.starsEarned,
    );
  }

  @override
  List<Object?> get props => [
    currentLevelNumber,
    unlockedLevel,
    levelStars,
    questions,
    currentQuestionIndex,
    selectedOptionIndex,
    isSubmitted,
    isAnswerCorrect,
    score,
    earnedXp,
    isQuizCompleted,
    starsEarned,
  ];
}

class QuizCubit extends Cubit<QuizState> {
  final LearningRepository _repository;

  QuizCubit(this._repository)
    : super(
        QuizState(
          currentLevelNumber: 1,
          unlockedLevel: _repository.getQuizUnlockedLevel(),
          levelStars: _repository.getQuizStars(),
          questions:
              _repository.getQuizLevel(1)?.questions ??
              _repository.getQuizQuestions(),
        ),
      );

  void refreshProgress() {
    emit(
      state.copyWith(
        unlockedLevel: _repository.getQuizUnlockedLevel(),
        levelStars: _repository.getQuizStars(),
      ),
    );
  }

  void startLevel(int levelNumber) {
    final level = _repository.getQuizLevel(levelNumber);
    final questions = level?.questions ?? _repository.getQuizQuestions();
    emit(
      QuizState(
        currentLevelNumber: levelNumber,
        unlockedLevel: _repository.getQuizUnlockedLevel(),
        levelStars: _repository.getQuizStars(),
        questions: questions,
        currentQuestionIndex: 0,
        selectedOptionIndex: null,
        isSubmitted: false,
        isAnswerCorrect: false,
        score: 0,
        earnedXp: 0,
        isQuizCompleted: false,
        starsEarned: 0,
      ),
    );
  }

  void selectOption(int index) {
    if (state.isSubmitted) return; // Prevent changing after submitting
    emit(state.copyWith(selectedOptionIndex: index));
  }

  void submitAnswer() {
    if (state.selectedOptionIndex == null || state.isSubmitted) return;

    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = state.selectedOptionIndex == question.correctOptionIndex;
    final newScore = isCorrect ? state.score + 1 : state.score;
    final addedXp = isCorrect ? question.xpReward : 0;

    emit(
      state.copyWith(
        isSubmitted: true,
        isAnswerCorrect: isCorrect,
        score: newScore,
        earnedXp: state.earnedXp + addedXp,
      ),
    );
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      emit(
        state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex + 1,
          clearSelection: true,
          isSubmitted: false,
          isAnswerCorrect: false,
        ),
      );
    } else {
      // Calculate stars earned for current level
      final int total = state.questions.length;
      final double ratio = total > 0 ? (state.score / total) : 0;
      int starsWon = 1;
      if (ratio >= 0.75) {
        starsWon = 3;
      } else if (ratio >= 0.5) {
        starsWon = 2;
      }

      // Persist stars
      _repository.saveQuizStars(state.currentLevelNumber, starsWon);

      // Unlock next level if currently at max unlocked
      int newUnlocked = state.unlockedLevel;
      if (state.currentLevelNumber >= state.unlockedLevel &&
          state.currentLevelNumber < 10) {
        newUnlocked = state.currentLevelNumber + 1;
        _repository.saveQuizUnlockedLevel(newUnlocked);
      }

      final updatedStars = Map<int, int>.from(_repository.getQuizStars());
      updatedStars[state.currentLevelNumber] = starsWon;

      emit(
        state.copyWith(
          isQuizCompleted: true,
          starsEarned: starsWon,
          unlockedLevel: newUnlocked,
          levelStars: updatedStars,
        ),
      );
    }
  }

  void unlockNextLevel() {
    if (state.currentLevelNumber < 10) {
      startLevel(state.currentLevelNumber + 1);
    } else {
      startLevel(1);
    }
  }

  void resetQuiz() {
    startLevel(state.currentLevelNumber);
  }
}
