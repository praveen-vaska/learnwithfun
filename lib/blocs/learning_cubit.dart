import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/learning_category.dart';
import '../data/models/lesson.dart';
import '../data/repositories/learning_repository.dart';

class LearningState extends Equatable {
  final List<LearningCategory> categories;
  final List<Lesson> currentLessons;
  final String selectedCategoryId;
  final int activeLessonIndex;
  final bool isAudioPlaying;

  const LearningState({
    required this.categories,
    required this.currentLessons,
    required this.selectedCategoryId,
    this.activeLessonIndex = 0,
    this.isAudioPlaying = false,
  });

  LearningState copyWith({
    List<LearningCategory>? categories,
    List<Lesson>? currentLessons,
    String? selectedCategoryId,
    int? activeLessonIndex,
    bool? isAudioPlaying,
  }) {
    return LearningState(
      categories: categories ?? this.categories,
      currentLessons: currentLessons ?? this.currentLessons,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      activeLessonIndex: activeLessonIndex ?? this.activeLessonIndex,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    currentLessons,
    selectedCategoryId,
    activeLessonIndex,
    isAudioPlaying,
  ];
}

class LearningCubit extends Cubit<LearningState> {
  final LearningRepository _repository;

  LearningCubit(this._repository)
    : super(
        LearningState(
          categories: _repository.getCategories(),
          currentLessons: _repository.getLessons('abc'),
          selectedCategoryId: 'abc',
        ),
      );

  void selectCategory(String categoryId) {
    final lessons = _repository.getLessons(categoryId);
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        currentLessons: lessons,
        activeLessonIndex: 0,
        isAudioPlaying: false,
      ),
    );
  }

  void setActiveLesson(int index) {
    if (index >= 0 && index < state.currentLessons.length) {
      emit(state.copyWith(activeLessonIndex: index, isAudioPlaying: false));
    }
  }

  void nextLesson() {
    if (state.activeLessonIndex < state.currentLessons.length - 1) {
      emit(
        state.copyWith(
          activeLessonIndex: state.activeLessonIndex + 1,
          isAudioPlaying: false,
        ),
      );
    }
  }

  void previousLesson() {
    if (state.activeLessonIndex > 0) {
      emit(
        state.copyWith(
          activeLessonIndex: state.activeLessonIndex - 1,
          isAudioPlaying: false,
        ),
      );
    }
  }

  void toggleAudioPlayback() {
    emit(state.copyWith(isAudioPlaying: !state.isAudioPlaying));
  }

  void completeCurrentLesson() {
    if (state.currentLessons.isNotEmpty) {
      final currentLesson = state.currentLessons[state.activeLessonIndex];
      _repository.markLessonCompleted(currentLesson.id);
      final updatedLessons = _repository.getLessons(state.selectedCategoryId);
      final updatedCategories = _repository.getCategories();
      emit(
        state.copyWith(
          currentLessons: updatedLessons,
          categories: updatedCategories,
        ),
      );
    }
  }
}
