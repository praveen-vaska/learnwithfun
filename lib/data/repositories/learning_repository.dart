import '../mock/mock_data.dart';
import '../models/learning_category.dart';
import '../models/lesson.dart';
import '../models/quiz_question.dart';
import '../models/daily_challenge.dart';
import '../models/reward_badge.dart';
import '../models/story.dart';
import '../models/notification_item.dart';
import '../models/parent_stats.dart';
import '../models/quiz_level.dart';
import '../services/local_storage_service.dart';

abstract class LearningRepository {
  List<LearningCategory> getCategories();
  List<Lesson> getLessons(String categoryId);
  void markLessonCompleted(String lessonId);
  List<QuizQuestion> getQuizQuestions();
  List<QuizLevel> getQuizLevels();
  QuizLevel? getQuizLevel(int levelNumber);
  int getQuizUnlockedLevel();
  void saveQuizUnlockedLevel(int level);
  Map<int, int> getQuizStars();
  void saveQuizStars(int level, int stars);
  List<DailyChallengeItem> getDailyChallenges();
  void markChallengeCompleted(String challengeId);
  List<RewardBadge> getBadges();
  void unlockBadge(String badgeId);
  List<Story> getStories({
    bool? rhymesOnly,
    String? language,
    bool? videosOnly,
  });
  List<NotificationItem> getNotifications();
  void markNotificationRead(String id);
  ParentStats getParentStats();
}

class MockLearningRepository implements LearningRepository {
  final LocalStorageService? _storage;
  List<LearningCategory> _categories = List.from(MockData.categories);
  late final List<Lesson> _lessons;
  late List<DailyChallengeItem> _challenges;
  late List<RewardBadge> _badges;
  final List<Story> _stories = List.from(MockData.stories);
  List<NotificationItem> _notifications = List.from(MockData.notifications);

  MockLearningRepository([this._storage]) {
    // 1. Initialize all lessons across all categories
    _lessons = List.from(MockData.allLessons);

    // 2. Hydrate completed lessons from persistence if available
    final savedCompleted = _storage?.loadCompletedLessons() ?? {};
    if (savedCompleted.isNotEmpty) {
      for (int i = 0; i < _lessons.length; i++) {
        if (savedCompleted.contains(_lessons[i].id)) {
          _lessons[i] = _lessons[i].copyWith(isCompleted: true);
        }
      }
    }

    // 3. Hydrate completed challenges from persistence
    _challenges = List.from(MockData.dailyChallenges);
    final savedChallenges = _storage?.loadCompletedChallenges() ?? {};
    if (savedChallenges.isNotEmpty) {
      _challenges = _challenges.map((c) {
        if (savedChallenges.contains(c.id)) {
          return c.copyWith(isCompleted: true);
        }
        return c;
      }).toList();
    }

    // 4. Hydrate unlocked badges from persistence
    _badges = List.from(MockData.badges);
    final savedBadges = _storage?.loadUnlockedBadges() ?? {};
    if (savedBadges.isNotEmpty) {
      _badges = _badges.map((b) {
        if (savedBadges.contains(b.id)) {
          return b.copyWith(isUnlocked: true);
        }
        return b;
      }).toList();
    }

    // 5. Update category completion counts
    _syncCategoryCounts();
  }

  void _syncCategoryCounts() {
    _categories = _categories.map((cat) {
      final total = _lessons.where((l) => l.categoryId == cat.id).length;
      final completed = _lessons
          .where((l) => l.categoryId == cat.id && l.isCompleted)
          .length;
      return cat.copyWith(
        totalLessons: total > 0 ? total : cat.totalLessons,
        completedLessons: completed,
      );
    }).toList();
  }

  @override
  List<LearningCategory> getCategories() => List.unmodifiable(_categories);

  @override
  List<Lesson> getLessons(String categoryId) {
    return _lessons.where((l) => l.categoryId == categoryId).toList();
  }

  @override
  void markLessonCompleted(String lessonId) {
    final index = _lessons.indexWhere((l) => l.id == lessonId);
    if (index != -1 && !_lessons[index].isCompleted) {
      _lessons[index] = _lessons[index].copyWith(isCompleted: true);
      _syncCategoryCounts();

      // Persist to local storage
      final completedIds = _lessons
          .where((l) => l.isCompleted)
          .map((l) => l.id)
          .toSet();
      _storage?.saveCompletedLessons(completedIds);
    }
  }

  @override
  List<QuizQuestion> getQuizQuestions() =>
      List.unmodifiable(MockData.quizQuestions);

  @override
  List<QuizLevel> getQuizLevels() => List.unmodifiable(MockData.quizLevels);

  @override
  QuizLevel? getQuizLevel(int levelNumber) {
    try {
      return MockData.quizLevels.firstWhere((l) => l.levelNumber == levelNumber);
    } catch (_) {
      return null;
    }
  }

  @override
  int getQuizUnlockedLevel() => _storage?.loadQuizUnlockedLevel() ?? 1;

  @override
  void saveQuizUnlockedLevel(int level) {
    _storage?.saveQuizUnlockedLevel(level);
  }

  @override
  Map<int, int> getQuizStars() => _storage?.loadQuizStars() ?? {};

  @override
  void saveQuizStars(int level, int stars) {
    _storage?.saveQuizStars(level, stars);
  }

  @override
  List<DailyChallengeItem> getDailyChallenges() =>
      List.unmodifiable(_challenges);

  @override
  void markChallengeCompleted(String challengeId) {
    _challenges = _challenges.map((c) {
      if (c.id == challengeId) {
        return c.copyWith(isCompleted: true);
      }
      return c;
    }).toList();

    final completedIds = _challenges
        .where((c) => c.isCompleted)
        .map((c) => c.id)
        .toSet();
    _storage?.saveCompletedChallenges(completedIds);
  }

  @override
  List<RewardBadge> getBadges() => List.unmodifiable(_badges);

  @override
  void unlockBadge(String badgeId) {
    _badges = _badges.map((b) {
      if (b.id == badgeId) {
        return b.copyWith(isUnlocked: true);
      }
      return b;
    }).toList();

    final unlockedIds = _badges
        .where((b) => b.isUnlocked)
        .map((b) => b.id)
        .toSet();
    _storage?.saveUnlockedBadges(unlockedIds);
  }

  @override
  List<Story> getStories({
    bool? rhymesOnly,
    String? language,
    bool? videosOnly,
  }) {
    return _stories.where((s) {
      if (rhymesOnly != null) {
        if (rhymesOnly && !s.isRhyme) return false;
        if (!rhymesOnly && s.isRhyme) return false;
      }
      if (videosOnly == true && !s.hasVideo) return false;
      if (language != null &&
          language != 'All' &&
          language.isNotEmpty &&
          s.language != language) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  List<NotificationItem> getNotifications() =>
      List.unmodifiable(_notifications);

  @override
  void markNotificationRead(String id) {
    _notifications = _notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  @override
  ParentStats getParentStats() => MockData.parentStats;
}
