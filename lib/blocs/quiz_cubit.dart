import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/quiz_question.dart';
import '../data/repositories/learning_repository.dart';

class QuizState extends Equatable {
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final int? selectedOptionIndex;
  final bool isSubmitted;
  final bool isAnswerCorrect;
  final int score;
  final int earnedXp;
  final bool isQuizCompleted;

  const QuizState({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.selectedOptionIndex,
    this.isSubmitted = false,
    this.isAnswerCorrect = false,
    this.score = 0,
    this.earnedXp = 0,
    this.isQuizCompleted = false,
  });

  QuizQuestion? get currentQuestion =>
      questions.isNotEmpty && currentQuestionIndex < questions.length
      ? questions[currentQuestionIndex]
      : null;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    int? selectedOptionIndex,
    bool clearSelection = false,
    bool? isSubmitted,
    bool? isAnswerCorrect,
    int? score,
    int? earnedXp,
    bool? isQuizCompleted,
  }) {
    return QuizState(
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
    );
  }

  @override
  List<Object?> get props => [
    questions,
    currentQuestionIndex,
    selectedOptionIndex,
    isSubmitted,
    isAnswerCorrect,
    score,
    earnedXp,
    isQuizCompleted,
  ];
}

class QuizCubit extends Cubit<QuizState> {
  final LearningRepository _repository;

  QuizCubit(this._repository)
    : super(QuizState(questions: _repository.getQuizQuestions()));

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
      emit(state.copyWith(isQuizCompleted: true));
    }
  }

  void resetQuiz() {
    emit(QuizState(questions: _repository.getQuizQuestions()));
  }
}
