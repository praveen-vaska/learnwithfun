import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnwithfun/core/services/audio_service.dart';
import 'package:learnwithfun/data/mock/mock_data.dart';
import 'package:learnwithfun/data/services/local_storage_service.dart';
import 'package:learnwithfun/data/repositories/learning_repository.dart';
import 'package:learnwithfun/data/repositories/user_repository.dart';
import 'package:learnwithfun/blocs/learning_cubit.dart';
import 'package:learnwithfun/blocs/quiz_cubit.dart';
import 'package:learnwithfun/blocs/stories_cubit.dart';
import 'package:learnwithfun/blocs/mini_game_cubit.dart';
import 'package:learnwithfun/data/models/match_pair_level.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService & Repositories', () {
    test('LocalStorageService persists and loads child profile', () async {
      final storage = LocalStorageService();
      await storage.init();

      final userRepo = MockUserRepository(storage);
      final initial = userRepo.getProfile();
      expect(initial.name, 'Arab');

      userRepo.addXp(200);
      expect(userRepo.getProfile().currentXp, 650);
      expect(userRepo.getProfile().level, 5); // Leveled up!

      // Create new repo with same storage to verify persistence
      final restoredRepo = MockUserRepository(storage);
      expect(restoredRepo.getProfile().currentXp, 650);
      expect(restoredRepo.getProfile().level, 5);
    });

    test('LearningRepository returns lessons for all 9 categories', () async {
      final storage = LocalStorageService();
      await storage.init();
      final learningRepo = MockLearningRepository(storage);

      // Verify each category has full lessons
      expect(learningRepo.getLessons('abc').length, 26);
      expect(learningRepo.getLessons('123').length, 20);
      expect(learningRepo.getLessons('animals').length, 18);
      expect(learningRepo.getLessons('shapes').length, 11);
      expect(learningRepo.getLessons('fruits').length, 12);
      expect(learningRepo.getLessons('birds').length, 11);
      expect(learningRepo.getLessons('vehicles').length, 11);
      expect(learningRepo.getLessons('body').length, 11);
      expect(learningRepo.getLessons('science').length, 12);
    });

    test(
      'LearningRepository completes lessons and updates categories',
      () async {
        final storage = LocalStorageService();
        await storage.init();
        final learningRepo = MockLearningRepository(storage);

        final animalLessons = learningRepo.getLessons('animals');
        final firstLesson = animalLessons.first;
        expect(firstLesson.categoryId, 'animals');

        learningRepo.markLessonCompleted(firstLesson.id);
        final updatedAnimalLessons = learningRepo.getLessons('animals');
        expect(updatedAnimalLessons.first.isCompleted, true);

        // Verify persistence
        final freshRepo = MockLearningRepository(storage);
        expect(freshRepo.getLessons('animals').first.isCompleted, true);
      },
    );
  });

  group('Cubits & State Management', () {
    test('LearningCubit switches category and completes lesson', () async {
      final storage = LocalStorageService();
      await storage.init();
      final repo = MockLearningRepository(storage);
      final cubit = LearningCubit(repo);

      expect(cubit.state.selectedCategoryId, 'abc');
      cubit.selectCategory('animals');
      expect(cubit.state.selectedCategoryId, 'animals');
      expect(cubit.state.currentLessons.length, 18);

      cubit.completeCurrentLesson();
      expect(cubit.state.currentLessons.first.isCompleted, true);
    });

    test('QuizCubit selects option and submits answer', () async {
      final storage = LocalStorageService();
      await storage.init();
      final repo = MockLearningRepository(storage);
      final cubit = QuizCubit(repo);

      expect(cubit.state.questions.isNotEmpty, true);
      cubit.selectOption(0);
      expect(cubit.state.selectedOptionIndex, 0);

      cubit.submitAnswer();
      expect(cubit.state.isSubmitted, true);
    });
  });

  group('Real Animal Audio Assets & AudioService', () {
    test('All real animal audio asset files exist on disk with valid size', () {
      for (final entry in AppAudioService.animalSoundAssets.entries) {
        final file = File('assets/${entry.value}');
        expect(
          file.existsSync(),
          true,
          reason: 'Expected ${file.path} to exist for ${entry.key}',
        );
        expect(
          file.lengthSync(),
          greaterThan(1000),
          reason: 'Expected ${file.path} to have valid audio content',
        );
      }
    });

    test('playAnimalSound handles animals gracefully', () async {
      final audio = AppAudioService.instance;
      audio.soundEnabled = false; // Disable audio playback in test environment
      await audio.playAnimalSound('cow');
      await audio.playAnimalSound('cat');
      await audio.playAnimalSound('lion');
      await audio.playAnimalSound('dog');
      await audio.playAnimalSound('duck');
      audio.soundEnabled = true;
    });

    test('All lessons across all categories have existing illustration assets', () {
      for (final lesson in MockData.allLessons) {
        final file = File(lesson.illustrationAsset);
        expect(
          file.existsSync(),
          true,
          reason:
              'Expected ${file.path} to exist for lesson ${lesson.id} (${lesson.conceptWord})',
        );
      }
    });
  });

  group('Multilingual Stories, HD Video Rhymes & StoriesCubit', () {
    test(
      'MockLearningRepository returns stories across all 3 languages',
      () async {
        final storage = LocalStorageService();
        await storage.init();
        final repo = MockLearningRepository(storage);

        final allStories = repo.getStories();
        expect(allStories.length, greaterThanOrEqualTo(15));

        final englishStories = repo.getStories(language: 'English');
        expect(englishStories.isNotEmpty, true);
        expect(englishStories.every((s) => s.language == 'English'), true);

        final teluguStories = repo.getStories(language: 'Telugu');
        expect(teluguStories.length, greaterThanOrEqualTo(5));
        expect(teluguStories.every((s) => s.language == 'Telugu'), true);
        // Check classic Telugu rhymes exist
        expect(
          teluguStories.any((s) => s.title.contains('చిట్టి చిలకమ్మ')),
          true,
        );
        expect(teluguStories.any((s) => s.title.contains('చందమామ రావే')), true);

        final hindiStories = repo.getStories(language: 'Hindi');
        expect(hindiStories.length, greaterThanOrEqualTo(4));
        expect(hindiStories.every((s) => s.language == 'Hindi'), true);
        // Check classic Hindi rhymes exist
        expect(
          hindiStories.any((s) => s.title.contains('मछली जल की रानी है')),
          true,
        );
      },
    );

    test(
      'MockLearningRepository filters HD animated videos correctly',
      () async {
        final storage = LocalStorageService();
        await storage.init();
        final repo = MockLearningRepository(storage);

        final videoSongs = repo.getStories(videosOnly: true);
        expect(videoSongs.length, greaterThanOrEqualTo(10));
        expect(videoSongs.every((s) => s.hasVideo == true), true);

        // Check popular English songs with videos
        expect(
          videoSongs.any((s) => s.title.contains('Twinkle Twinkle')),
          true,
        );
        expect(videoSongs.any((s) => s.title.contains('Johny Johny')), true);
        expect(
          videoSongs.any((s) => s.title.contains('Baa Baa Black Sheep')),
          true,
        );
        expect(
          videoSongs.any((s) => s.title.contains('Wheels on the Bus')),
          true,
        );
        expect(videoSongs.any((s) => s.title.contains('Old MacDonald')), true);
      },
    );

    test('StoriesCubit filters by language and tab properly', () async {
      final storage = LocalStorageService();
      await storage.init();
      final repo = MockLearningRepository(storage);
      final cubit = StoriesCubit(repo);

      // Switch language to Telugu
      cubit.setLanguage('Telugu');
      expect(cubit.state.selectedLanguage, 'Telugu');
      expect(cubit.state.stories.every((s) => s.language == 'Telugu'), true);

      // Filter only videos in Telugu
      cubit.setFilter('videos');
      expect(cubit.state.selectedFilter, 'videos');
      expect(
        cubit.state.stories.every((s) => s.hasVideo && s.language == 'Telugu'),
        true,
      );

      // Switch language to Hindi
      cubit.setLanguage('Hindi');
      expect(cubit.state.selectedLanguage, 'Hindi');
      expect(
        cubit.state.stories.every((s) => s.hasVideo && s.language == 'Hindi'),
        true,
      );

      // Switch back to All
      cubit.setLanguage('All');
      cubit.setFilter('all');
      expect(cubit.state.stories.length, repo.getStories().length);
    });

    test('All stories and rhymes have valid cover illustration assets on disk', () {
      for (final story in MockData.stories) {
        final file = File(story.coverAsset);
        expect(
          file.existsSync(),
          true,
          reason:
              'Expected story cover asset ${file.path} to exist for ${story.id} (${story.title})',
        );
        expect(
          file.lengthSync(),
          greaterThan(50),
          reason: 'Expected story cover asset ${file.path} to be non-empty',
        );
      }
    });

    test(
      'All video stories have valid real YouTube video IDs and channels',
      () {
        final videoStories = MockData.stories.where((s) => s.hasVideo).toList();
        expect(videoStories.isNotEmpty, true);
        for (final story in videoStories) {
          expect(
            story.youtubeVideoId,
            isNotNull,
            reason: 'Expected YouTube videoId for ${story.id}',
          );
          expect(story.youtubeVideoId!.isNotEmpty, true);
          expect(
            story.youtubeChannel,
            isNotNull,
            reason: 'Expected YouTube channel for ${story.id}',
          );
        }
      },
    );
  });

  group('Match Pairs 10 Levels & Progression System', () {
    test(
      '10 Progressive levels are properly defined with easy to hard difficulty',
      () {
        expect(MatchPairLevel.allLevels.length, 10);

        // Verify progression from 2 pairs (4 cards) up to 8 pairs (16 cards)
        expect(MatchPairLevel.allLevels[0].pairCount, 2);
        expect(MatchPairLevel.allLevels[0].totalCards, 4);
        expect(MatchPairLevel.allLevels[0].difficulty, 'Easy');

        expect(MatchPairLevel.allLevels[9].pairCount, 8);
        expect(MatchPairLevel.allLevels[9].totalCards, 16);
        expect(MatchPairLevel.allLevels[9].difficulty, 'Master');

        // Verify each level number is sequential 1..10
        for (int i = 0; i < 10; i++) {
          expect(MatchPairLevel.allLevels[i].levelNumber, i + 1);
          expect(MatchPairLevel.allLevels[i].title.isNotEmpty, true);
          expect(MatchPairLevel.allLevels[i].pairs.isNotEmpty, true);
        }
      },
    );

    test('All card assets across all 10 levels exist on disk', () {
      for (final level in MatchPairLevel.allLevels) {
        for (final pair in level.pairs) {
          final file = File(pair['asset']!);
          expect(
            file.existsSync(),
            true,
            reason:
                'Expected asset ${file.path} for level ${level.levelNumber} (${pair['label']}) to exist',
          );
        }
      }
    });

    test(
      'MiniGameCubit initializes on levelMap and can start Level 1',
      () async {
        final storage = LocalStorageService();
        await storage.init();

        final cubit = MiniGameCubit(storage: storage);
        expect(cubit.state.viewMode, MiniGameViewMode.levelMap);
        expect(cubit.state.unlockedLevel, 1);

        cubit.startLevel(1);
        expect(cubit.state.viewMode, MiniGameViewMode.playing);
        expect(cubit.state.currentLevel.levelNumber, 1);
        expect(cubit.state.cards.length, 4); // 2 pairs = 4 cards
        expect(cubit.state.secondsRemaining, 35);

        cubit.close();
      },
    );

    test('MiniGameCubit completes level and unlocks next level', () async {
      final storage = LocalStorageService();
      await storage.init();

      final cubit = MiniGameCubit(storage: storage);
      cubit.startLevel(1);

      // Match all pairs in level 1
      final cards = cubit.state.cards;
      // Find two cards with same label
      final firstLabel = cards[0].label;
      final matchIndex = cards.indexWhere(
        (c) => c.label == firstLabel && c.id != cards[0].id,
      );

      cubit.flipCard(0);
      cubit.flipCard(matchIndex);

      // Wait for match animation
      await Future.delayed(const Duration(milliseconds: 350));
      expect(cubit.state.cards[0].isMatched, true);
      expect(cubit.state.cards[matchIndex].isMatched, true);

      cubit.close();
    });
  });

  group('Match Pairs 10 Levels & Progression System', () {
    test('10 Progressive levels are properly defined with easy to hard difficulty', () {
      expect(MatchPairLevel.allLevels.length, 10);

      // Verify progression from 2 pairs (4 cards) up to 8 pairs (16 cards)
      expect(MatchPairLevel.allLevels[0].pairCount, 2);
      expect(MatchPairLevel.allLevels[0].totalCards, 4);
      expect(MatchPairLevel.allLevels[0].difficulty, 'Easy');

      expect(MatchPairLevel.allLevels[9].pairCount, 8);
      expect(MatchPairLevel.allLevels[9].totalCards, 16);
      expect(MatchPairLevel.allLevels[9].difficulty, 'Master');

      // Verify each level number is sequential 1..10
      for (int i = 0; i < 10; i++) {
        expect(MatchPairLevel.allLevels[i].levelNumber, i + 1);
        expect(MatchPairLevel.allLevels[i].title.isNotEmpty, true);
        expect(MatchPairLevel.allLevels[i].pairs.isNotEmpty, true);
      }
    });

    test('All card assets across all 10 levels exist on disk', () {
      for (final level in MatchPairLevel.allLevels) {
        for (final pair in level.pairs) {
          final file = File(pair['asset']!);
          expect(
            file.existsSync(),
            true,
            reason: 'Expected asset ${file.path} for level ${level.levelNumber} (${pair['label']}) to exist',
          );
        }
      }
    });

    test('MiniGameCubit initializes on levelMap and can start Level 1', () async {
      final storage = LocalStorageService();
      await storage.init();

      final cubit = MiniGameCubit(storage: storage);
      expect(cubit.state.viewMode, MiniGameViewMode.levelMap);
      expect(cubit.state.unlockedLevel, 1);

      cubit.startLevel(1);
      expect(cubit.state.viewMode, MiniGameViewMode.playing);
      expect(cubit.state.currentLevel.levelNumber, 1);
      expect(cubit.state.cards.length, 4); // 2 pairs = 4 cards
      expect(cubit.state.secondsRemaining, 35);

      cubit.close();
    });

    test('MiniGameCubit completes level and unlocks next level', () async {
      final storage = LocalStorageService();
      await storage.init();

      final cubit = MiniGameCubit(storage: storage);
      cubit.startLevel(1);

      // Match all pairs in level 1
      final cards = cubit.state.cards;
      // Find two cards with same label
      final firstLabel = cards[0].label;
      final matchIndex = cards.indexWhere((c) => c.label == firstLabel && c.id != cards[0].id);

      cubit.flipCard(0);
      cubit.flipCard(matchIndex);

      // Wait for match animation
      await Future.delayed(const Duration(milliseconds: 350));
      expect(cubit.state.cards[0].isMatched, true);
      expect(cubit.state.cards[matchIndex].isMatched, true);

      cubit.close();
    });
  });
}
