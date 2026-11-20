import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/story.dart';
import '../data/repositories/learning_repository.dart';

class StoriesState extends Equatable {
  final List<Story> stories;
  final bool isRhymesTab;
  final String selectedFilter; // 'all', 'videos', 'stories', 'rhymes'
  final String selectedLanguage; // 'All', 'English', 'Telugu', 'Hindi'
  final Story? currentStory;
  final int currentPageIndex;
  final bool isAudioPlaying;
  final double playbackProgress; // 0.0 to 1.0

  const StoriesState({
    required this.stories,
    this.isRhymesTab = false,
    this.selectedFilter = 'all',
    this.selectedLanguage = 'All',
    this.currentStory,
    this.currentPageIndex = 0,
    this.isAudioPlaying = false,
    this.playbackProgress = 0.0,
  });

  StoriesState copyWith({
    List<Story>? stories,
    bool? isRhymesTab,
    String? selectedFilter,
    String? selectedLanguage,
    Story? currentStory,
    int? currentPageIndex,
    bool? isAudioPlaying,
    double? playbackProgress,
  }) {
    return StoriesState(
      stories: stories ?? this.stories,
      isRhymesTab: isRhymesTab ?? this.isRhymesTab,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      currentStory: currentStory ?? this.currentStory,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      playbackProgress: playbackProgress ?? this.playbackProgress,
    );
  }

  @override
  List<Object?> get props => [
    stories,
    isRhymesTab,
    selectedFilter,
    selectedLanguage,
    currentStory,
    currentPageIndex,
    isAudioPlaying,
    playbackProgress,
  ];
}

class StoriesCubit extends Cubit<StoriesState> {
  final LearningRepository _repository;

  StoriesCubit(this._repository, [String initialLanguage = 'All'])
    : super(
        StoriesState(
          stories: _repository.getStories(
            language: initialLanguage == 'All' ? null : initialLanguage,
          ),
          selectedLanguage: initialLanguage,
          selectedFilter: 'all',
        ),
      );

  void setFilter(String filter) {
    bool? rhymesOnly;
    bool? videosOnly;
    if (filter == 'rhymes') {
      rhymesOnly = true;
    } else if (filter == 'stories') {
      rhymesOnly = false;
    } else if (filter == 'videos') {
      videosOnly = true;
    }

    final filtered = _repository.getStories(
      rhymesOnly: rhymesOnly,
      videosOnly: videosOnly,
      language: state.selectedLanguage == 'All' ? null : state.selectedLanguage,
    );

    emit(
      state.copyWith(
        selectedFilter: filter,
        isRhymesTab: filter == 'rhymes',
        stories: filtered,
      ),
    );
  }

  void setLanguage(String language) {
    bool? rhymesOnly;
    bool? videosOnly;
    if (state.selectedFilter == 'rhymes') {
      rhymesOnly = true;
    } else if (state.selectedFilter == 'stories') {
      rhymesOnly = false;
    } else if (state.selectedFilter == 'videos') {
      videosOnly = true;
    }

    final filtered = _repository.getStories(
      rhymesOnly: rhymesOnly,
      videosOnly: videosOnly,
      language: language == 'All' ? null : language,
    );

    emit(state.copyWith(selectedLanguage: language, stories: filtered));
  }

  void switchTab(bool rhymesTab) {
    setFilter(rhymesTab ? 'rhymes' : 'stories');
  }

  void openStory(Story story) {
    emit(
      state.copyWith(
        currentStory: story,
        currentPageIndex: 0,
        isAudioPlaying: false,
        playbackProgress: 0.0,
      ),
    );
  }

  void toggleAudio() {
    emit(state.copyWith(isAudioPlaying: !state.isAudioPlaying));
  }

  void setPlaybackProgress(double progress) {
    emit(state.copyWith(playbackProgress: progress.clamp(0.0, 1.0)));
  }

  void nextPage() {
    if (state.currentStory != null &&
        state.currentPageIndex < state.currentStory!.pages.length - 1) {
      emit(state.copyWith(currentPageIndex: state.currentPageIndex + 1));
    }
  }

  void previousPage() {
    if (state.currentPageIndex > 0) {
      emit(state.copyWith(currentPageIndex: state.currentPageIndex - 1));
    }
  }
}
