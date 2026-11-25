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
  static const String _keyAccessToken = 'lwf_user_access_token';

  SharedPreferences? _prefs;
  String? _currentUserId;

  String? get currentUserId => _currentUserId;

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

  // --- Token Persistence ---

  String? loadAccessToken() {
    return _prefs?.getString(_keyAccessToken);
  }

  Future<void> saveAccessToken(String token) async {
    await init();
    await _prefs?.setString(_keyAccessToken, token);
  }

  Future<void> clearAccessToken() async {
    await init();
    await _prefs?.remove(_keyAccessToken);
  }

  // --- Profile Persistence ---

  ChildProfile? loadProfile() {
    if (_cachedProfile != null) return _cachedProfile;
    final raw = _prefs?.getString(_userKey(_keyProfile));
    if (raw == null) {
      if (_currentUserId == 'demo_parent') {
        return null; // Will trigger initialProfile for demo
      }
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final profile = ChildProfile(
        name: map['name'] as String? ?? 'Learner',
        age: map['age'] as int? ?? 5,
        ageBand: map['ageBand'] as String? ?? '4-6 Years',
        avatarAsset:
            map['avatarAsset'] as String? ??
            'assets/images/avatars/avatar_boy_1.svg',
        language: map['language'] as String? ?? 'English',
        level: map['level'] as int? ?? 1,
        currentXp: map['currentXp'] as int? ?? 0,
        nextLevelXp: map['nextLevelXp'] as int? ?? 100,
        streakDays: map['streakDays'] as int? ?? 1,
        stars: map['stars'] as int? ?? 0,
        completedLessonsCount: map['completedLessonsCount'] as int? ?? 0,
        completedQuizzesCount: map['completedQuizzesCount'] as int? ?? 0,
        accuracyPercent: (map['accuracyPercent'] as num?)?.toDouble() ?? 100.0,
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
    final key = _userKey(_keyProfile);
    _cachedProfile = profile;
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
    final encoded = jsonEncode(map);
    if (_prefs != null) {
      await _prefs!.setString(key, encoded);
    } else {
      await init();
      await _prefs?.setString(key, encoded);
    }
  }

  // --- Completed Lessons Persistence ---

  Set<String> loadCompletedLessons() {
    if (_cachedLessons != null) return _cachedLessons!;
    final list = _prefs?.getStringList(_userKey(_keyCompletedLessons));
    if (list != null) {
      final set = list.toSet();
      _cachedLessons = set;
      return set;
    }
    if (_currentUserId == 'demo_parent') {
      const demoSet = {
        'a_apple',
        'b_ball',
        'c_cat',
        'd_dog',
        'e_elephant',
        'f_fish',
        'num_1',
        'num_2',
        'num_3',
        'num_4',
      };
      _cachedLessons = demoSet;
      return demoSet;
    }
    _cachedLessons = <String>{};
    return _cachedLessons!;
  }

  Future<void> saveCompletedLessons(Set<String> lessonIds) async {
    final key = _userKey(_keyCompletedLessons);
    _cachedLessons = Set.from(lessonIds);
    final list = lessonIds.toList();
    if (_prefs != null) {
      await _prefs!.setStringList(key, list);
    } else {
      await init();
      await _prefs?.setStringList(key, list);
    }
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
    final key = _userKey(_keyCompletedChallenges);
    _cachedChallenges = Set.from(challengeIds);
    final list = challengeIds.toList();
    if (_prefs != null) {
      await _prefs!.setStringList(key, list);
    } else {
      await init();
      await _prefs?.setStringList(key, list);
    }
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
    final key = _userKey(_keyUnlockedBadges);
    _cachedBadges = Set.from(badgeIds);
    final list = badgeIds.toList();
    if (_prefs != null) {
      await _prefs!.setStringList(key, list);
    } else {
      await init();
      await _prefs?.setStringList(key, list);
    }
  }

  // --- Screen Time Tracking ---

  int loadTodayScreenTimeMinutes() {
    return _prefs?.getInt(_userKey(_keyDailyMinutes)) ?? 25;
  }

  Future<void> recordScreenTimeMinutes(int minutes) async {
    final key = _userKey(_keyDailyMinutes);
    if (_prefs != null) {
      await _prefs!.setInt(key, minutes);
    } else {
      await init();
      await _prefs?.setInt(key, minutes);
    }
  }

  // --- Match Pairs Levels & Stars Persistence ---

  int loadMatchPairsUnlockedLevel() {
    if (_cachedMatchPairsUnlockedLevel != null) {
      return _cachedMatchPairsUnlockedLevel!;
    }
    final saved = _prefs?.getInt(_userKey(_keyMatchPairsUnlockedLevel));
    final level = saved ?? (_currentUserId == 'demo_parent' ? 4 : 1);
    _cachedMatchPairsUnlockedLevel = level;
    return level;
  }

  Future<void> saveMatchPairsUnlockedLevel(int level) async {
    final key = _userKey(_keyMatchPairsUnlockedLevel);
    final current = loadMatchPairsUnlockedLevel();
    if (level > current) {
      _cachedMatchPairsUnlockedLevel = level;
      if (_prefs != null) {
        await _prefs!.setInt(key, level);
      } else {
        await init();
        await _prefs?.setInt(key, level);
      }
    }
  }

  Map<int, int> loadMatchPairsStars() {
    if (_cachedMatchPairsStars != null) return _cachedMatchPairsStars!;
    final raw = _prefs?.getString(_userKey(_keyMatchPairsStars));
    if (raw == null) {
      final demoMap = _currentUserId == 'demo_parent'
          ? {1: 3, 2: 3, 3: 3}
          : <int, int>{};
      _cachedMatchPairsStars = demoMap;
      return demoMap;
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
    final key = _userKey(_keyMatchPairsStars);
    final map = Map<int, int>.from(loadMatchPairsStars());
    final currentStars = map[level] ?? 0;
    if (stars > currentStars) {
      map[level] = stars;
      _cachedMatchPairsStars = map;
      final encoded = jsonEncode(map.map((k, v) => MapEntry(k.toString(), v)));
      if (_prefs != null) {
        await _prefs!.setString(key, encoded);
      } else {
        await init();
        await _prefs?.setString(key, encoded);
      }
    }
  }

  // --- Quiz Levels & Stars Persistence ---

  int loadQuizUnlockedLevel() {
    if (_cachedQuizUnlockedLevel != null) {
      return _cachedQuizUnlockedLevel!;
    }
    final saved = _prefs?.getInt(_userKey(_keyQuizUnlockedLevel));
    final level = saved ?? (_currentUserId == 'demo_parent' ? 4 : 1);
    _cachedQuizUnlockedLevel = level;
    return level;
  }

  Future<void> saveQuizUnlockedLevel(int level) async {
    final key = _userKey(_keyQuizUnlockedLevel);
    final current = loadQuizUnlockedLevel();
    if (level > current) {
      _cachedQuizUnlockedLevel = level;
      if (_prefs != null) {
        await _prefs!.setInt(key, level);
      } else {
        await init();
        await _prefs?.setInt(key, level);
      }
    }
  }

  Map<int, int> loadQuizStars() {
    if (_cachedQuizStars != null) return _cachedQuizStars!;
    final raw = _prefs?.getString(_userKey(_keyQuizStars));
    if (raw == null) {
      final demoMap = _currentUserId == 'demo_parent'
          ? {1: 3, 2: 3, 3: 2}
          : <int, int>{};
      _cachedQuizStars = demoMap;
      return demoMap;
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
    final key = _userKey(_keyQuizStars);
    final map = Map<int, int>.from(loadQuizStars());
    final currentStars = map[level] ?? 0;
    if (stars > currentStars) {
      map[level] = stars;
      _cachedQuizStars = map;
      final encoded = jsonEncode(map.map((k, v) => MapEntry(k.toString(), v)));
      if (_prefs != null) {
        await _prefs!.setString(key, encoded);
      } else {
        await init();
        await _prefs?.setString(key, encoded);
      }
    }
  }

  SharedPreferences? get prefs => _prefs;

  int getQuizUnlockedLevel() => loadQuizUnlockedLevel();
  Future<void> setQuizUnlockedLevel(int level) => saveQuizUnlockedLevel(level);

  int getMiniGameLevelStars(int level) => loadMatchPairsStars()[level] ?? 0;
  Future<void> setMiniGameLevelStars(int level, int stars) => saveMatchPairsStars(level, stars);
}
