import 'package:equatable/equatable.dart';

import '../../core/constants/asset_paths.dart';

class ChildProfile extends Equatable {
  final String name;
  final int age;
  final String ageBand;
  final String avatarAsset;
  final String language;
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int streakDays;
  final int stars;
  final int completedLessonsCount;
  final int completedQuizzesCount;
  final double accuracyPercent;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool notificationsEnabled;
  final bool screenTimeLimitEnabled;
  final int screenTimeLimitMinutes;
  final bool breakReminderEnabled;

  const ChildProfile({
    this.name = 'Arab',
    this.age = 6,
    this.ageBand = '6-8 Years',
    this.avatarAsset = AssetPaths.avatarBoy1,
    this.language = 'English',
    this.level = 4,
    this.currentXp = 450,
    this.nextLevelXp = 600,
    this.streakDays = 5,
    this.stars = 5,
    this.completedLessonsCount = 28,
    this.completedQuizzesCount = 8,
    this.accuracyPercent = 88.0,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.notificationsEnabled = true,
    this.screenTimeLimitEnabled = true,
    this.screenTimeLimitMinutes = 60,
    this.breakReminderEnabled = true,
  });

  ChildProfile copyWith({
    String? name,
    int? age,
    String? ageBand,
    String? avatarAsset,
    String? language,
    int? level,
    int? currentXp,
    int? nextLevelXp,
    int? streakDays,
    int? stars,
    int? completedLessonsCount,
    int? completedQuizzesCount,
    double? accuracyPercent,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? notificationsEnabled,
    bool? screenTimeLimitEnabled,
    int? screenTimeLimitMinutes,
    bool? breakReminderEnabled,
  }) {
    return ChildProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      ageBand: ageBand ?? this.ageBand,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      language: language ?? this.language,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      streakDays: streakDays ?? this.streakDays,
      stars: stars ?? this.stars,
      completedLessonsCount:
          completedLessonsCount ?? this.completedLessonsCount,
      completedQuizzesCount:
          completedQuizzesCount ?? this.completedQuizzesCount,
      accuracyPercent: accuracyPercent ?? this.accuracyPercent,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      screenTimeLimitEnabled:
          screenTimeLimitEnabled ?? this.screenTimeLimitEnabled,
      screenTimeLimitMinutes:
          screenTimeLimitMinutes ?? this.screenTimeLimitMinutes,
      breakReminderEnabled: breakReminderEnabled ?? this.breakReminderEnabled,
    );
  }

  @override
  List<Object?> get props => [
    name,
    age,
    ageBand,
    avatarAsset,
    language,
    level,
    currentXp,
    nextLevelXp,
    streakDays,
    stars,
    completedLessonsCount,
    completedQuizzesCount,
    accuracyPercent,
    soundEnabled,
    musicEnabled,
    notificationsEnabled,
    screenTimeLimitEnabled,
    screenTimeLimitMinutes,
    breakReminderEnabled,
  ];
}
