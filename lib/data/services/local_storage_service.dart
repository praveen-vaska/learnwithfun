import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/child_profile.dart';

class LocalStorageService {
  static const String _keyProfile = 'lwf_child_profile';
  static const String _keyCompletedLessons = 'lwf_completed_lessons';
  static const String _keyCompletedChallenges = 'lwf_completed_challenges';
  static const String _keyUnlockedBadges = 'lwf_unlocked_badges';
  static const String _keyDailyMinutes = 'lwf_daily_minutes';
  static const String _keyMatchPairsUnlockedLevel =
      'lwf_match_pairs_unlocked_level';
  static const String _keyMatchPairsStars = 'lwf_match_pairs_stars';
  static const String _keyQuizUnlockedLevel = 'lwf_quiz_unlocked_level';
  static const String _keyQuizStars = 'lwf_quiz_stars';

  SharedPreferences? _prefs;
  String? _currentUserId;

  ChildProfile? _cachedProfile;
  Set<String>? _cachedLessons;
  Set<String>? _cachedChallenges;
  Set<String>? _cachedBadges;
  int? _cachedMatchPairsUnlockedLevel;
  Map<int, int>? _cachedMatchPairsStars;
  int? _cachedQuizUnlockedLevel;
  Map<int, int>? _cachedQuizStars;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Sets the active user ID scope. All data will be saved & loaded specifically for this user.
  void setScopeUser(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _cachedProfile = null;
      _cachedLessons = null;
      _cachedChallenges = null;
      _cachedBadges = null;
      _cachedMatchPairsUnlockedLevel = null;
      _cachedMatchPairsStars = null;
      _cachedQuizUnlockedLevel = null;
      _cachedQuizStars = null;
    }
  }

  String _userKey(String baseKey) {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      return baseKey;
    }
    return '${baseKey}_$_currentUserId';
  }

  // --- Profile Persistence ---

  ChildProfile? loadProfile() {
    if (_cachedProfile != null) return _cachedProfile;
    final raw = _prefs?.getString(_userKey(_keyProfile));
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final profile = ChildProfile(
        name: map['name'] as String? ?? 'Arab',
        age: map['age'] as int? ?? 6,
        ageBand: map['ageBand'] as String? ?? '6-8 Years',
        avatarAsset:
            map['avatarAsset'] as String? ??
            'assets/images/avatars/avatar_boy_1.svg',
        language: map['language'] as String? ?? 'English',
        level: map['level'] as int? ?? 4,
        currentXp: map['currentXp'] as int? ?? 450,
        nextLevelXp: map['nextLevelXp'] as int? ?? 600,
        streakDays: map['streakDays'] as int? ?? 5,
        stars: map['stars'] as int? ?? 5,
        completedLessonsCount: map['completedLessonsCount'] as int? ?? 28,
        completedQuizzesCount: map['completedQuizzesCount'] as int? ?? 8,
        accuracyPercent: (map['accuracyPercent'] as num?)?.toDouble() ?? 88.0,
        soundEnabled: map['soundEnabled'] as bool? ?? true,
        musicEnabled: map['musicEnabled'] as bool? ?? true,
        notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
        screenTimeLimitEnabled: map['screenTimeLimitEnabled'] as bool? ?? true,
        screenTimeLimitMinutes: map['screenTimeLimitMinutes'] as int? ?? 60,
        breakReminderEnabled: map['breakReminderEnabled'] as bool? ?? true,
      );
      _cachedProfile = profile;
      return profile;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(ChildProfile profile) async {
    _cachedProfile = profile;
    await init();
    final map = {
      'name': profile.name,
      'age': profile.age,
      'ageBand': profile.ageBand,
      'avatarAsset': profile.avatarAsset,
      'language': profile.language,
      'level': profile.level,
      'currentXp': profile.currentXp,
      'nextLevelXp': profile.nextLevelXp,
      'streakDays': profile.streakDays,
      'stars': profile.stars,
      'completedLessonsCount': profile.completedLessonsCount,
      'completedQuizzesCount': profile.completedQuizzesCount,
      'accuracyPercent': profile.accuracyPercent,
      'soundEnabled': profile.soundEnabled,
      'musicEnabled': profile.musicEnabled,
      'notificationsEnabled': profile.notificationsEnabled,
      'screenTimeLimitEnabled': profile.screenTimeLimitEnabled,
      'screenTimeLimitMinutes': profile.screenTimeLimitMinutes,
      'breakReminderEnabled': profile.breakReminderEnabled,
    };
    await _prefs?.setString(_userKey(_keyProfile), jsonEncode(map));
  }

  // --- Completed Lessons Persistence ---

  Set<String> loadCompletedLessons() {
    if (_cachedLessons != null) return _cachedLessons!;
    final list = _prefs?.getStringList(_userKey(_keyCompletedLessons));
    final set = list != null ? list.toSet() : <String>{};
    _cachedLessons = set;
    return set;
  }

  Future<void> saveCompletedLessons(Set<String> lessonIds) async {
    _cachedLessons = Set.from(lessonIds);
    await init();
    await _prefs?.setStringList(_userKey(_keyCompletedLessons), lessonIds.toList());
  }

  // --- Daily Challenges Persistence ---

  Set<String> loadCompletedChallenges() {
    if (_cachedChallenges != null) return _cachedChallenges!;
    final list = _prefs?.getStringList(_userKey(_keyCompletedChallenges));
    final set = list != null ? list.toSet() : <String>{};
    _cachedChallenges = set;
    return set;
  }

  Future<void> saveCompletedChallenges(Set<String> challengeIds) async {
    _cachedChallenges = Set.from(challengeIds);
    await init();
    await _prefs?.setStringList(_userKey(_keyCompletedChallenges), challengeIds.toList());
  }

  // --- Unlocked Badges Persistence ---

  Set<String> loadUnlockedBadges() {
    if (_cachedBadges != null) return _cachedBadges!;
    final list = _prefs?.getStringList(_userKey(_keyUnlockedBadges));
    final set = list != null ? list.toSet() : <String>{};
    _cachedBadges = set;
    return set;
  }

  Future<void> saveUnlockedBadges(Set<String> badgeIds) async {
    _cachedBadges = Set.from(badgeIds);
    await init();
    await _prefs?.setStringList(_userKey(_keyUnlockedBadges), badgeIds.toList());
  }

  // --- Screen Time Tracking ---

  int loadTodayScreenTimeMinutes() {
    return _prefs?.getInt(_userKey(_keyDailyMinutes)) ?? 25;
  }

  Future<void> recordScreenTimeMinutes(int minutes) async {
    await init();
    await _prefs?.setInt(_userKey(_keyDailyMinutes), minutes);
  }

  // --- Match Pairs Levels & Stars Persistence ---

  int loadMatchPairsUnlockedLevel() {
    if (_cachedMatchPairsUnlockedLevel != null) {
      return _cachedMatchPairsUnlockedLevel!;
    }
    final level = _prefs?.getInt(_userKey(_keyMatchPairsUnlockedLevel)) ?? 1;
    _cachedMatchPairsUnlockedLevel = level;
    return level;
  }

  Future<void> saveMatchPairsUnlockedLevel(int level) async {
    final current = loadMatchPairsUnlockedLevel();
    if (level > current) {
      _cachedMatchPairsUnlockedLevel = level;
      await init();
      await _prefs?.setInt(_userKey(_keyMatchPairsUnlockedLevel), level);
    }
  }

  Map<int, int> loadMatchPairsStars() {
    if (_cachedMatchPairsStars != null) return _cachedMatchPairsStars!;
    final raw = _prefs?.getString(_userKey(_keyMatchPairsStars));
    if (raw == null) {
      _cachedMatchPairsStars = {};
      return {};
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      final map = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
      _cachedMatchPairsStars = map;
      return map;
    } catch (_) {
      _cachedMatchPairsStars = {};
      return {};
    }
  }

  Future<void> saveMatchPairsStars(int level, int stars) async {
    final map = Map<int, int>.from(loadMatchPairsStars());
    final currentStars = map[level] ?? 0;
    if (stars > currentStars) {
      map[level] = stars;
      _cachedMatchPairsStars = map;
      await init();
      final encoded = jsonEncode(map.map((k, v) => MapEntry(k.toString(), v)));
      await _prefs?.setString(_userKey(_keyMatchPairsStars), encoded);
    }
  }

  // --- Quiz Levels & Stars Persistence ---

  int loadQuizUnlockedLevel() {
    if (_cachedQuizUnlockedLevel != null) {
      return _cachedQuizUnlockedLevel!;
    }
    final level = _prefs?.getInt(_userKey(_keyQuizUnlockedLevel)) ?? 1;
    _cachedQuizUnlockedLevel = level;
    return level;
  }

  Future<void> saveQuizUnlockedLevel(int level) async {
    final current = loadQuizUnlockedLevel();
    if (level > current) {
      _cachedQuizUnlockedLevel = level;
      await init();
      await _prefs?.setInt(_userKey(_keyQuizUnlockedLevel), level);
    }
  }

  Map<int, int> loadQuizStars() {
    if (_cachedQuizStars != null) return _cachedQuizStars!;
    final raw = _prefs?.getString(_userKey(_keyQuizStars));
    if (raw == null) {
      _cachedQuizStars = {};
      return {};
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      final map = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
      _cachedQuizStars = map;
      return map;
    } catch (_) {
      _cachedQuizStars = {};
      return {};
    }
  }

  Future<void> saveQuizStars(int level, int stars) async {
    final map = Map<int, int>.from(loadQuizStars());
    final currentStars = map[level] ?? 0;
    if (stars > currentStars) {
      map[level] = stars;
      _cachedQuizStars = map;
      await init();
      final encoded = jsonEncode(map.map((k, v) => MapEntry(k.toString(), v)));
      await _prefs?.setString(_userKey(_keyQuizStars), encoded);
    }
  }

  SharedPreferences? get prefs => _prefs;

  int getQuizUnlockedLevel() => loadQuizUnlockedLevel();
  Future<void> setQuizUnlockedLevel(int level) => saveQuizUnlockedLevel(level);

  int getMiniGameLevelStars(int level) => loadMatchPairsStars()[level] ?? 0;
  Future<void> setMiniGameLevelStars(int level, int stars) => saveMatchPairsStars(level, stars);
}
