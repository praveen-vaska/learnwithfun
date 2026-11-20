import 'package:equatable/equatable.dart';

class DailyActivity extends Equatable {
  final String dayName;
  final int minutesSpent;
  final double normalizedHeight;

  const DailyActivity({
    required this.dayName,
    required this.minutesSpent,
    required this.normalizedHeight,
  });

  @override
  List<Object?> get props => [dayName, minutesSpent, normalizedHeight];
}

class CategoryPerformance extends Equatable {
  final String categoryName;
  final int accuracyPercentage;
  final int colorHex;

  const CategoryPerformance({
    required this.categoryName,
    required this.accuracyPercentage,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [categoryName, accuracyPercentage, colorHex];
}

class ParentStats extends Equatable {
  final String childName;
  final int childAge;
  final String timeSpentThisWeek;
  final int lessonsCompleted;
  final int quizAccuracy;
  final int currentStreakDays;
  final int overallProgressPercent;
  final List<DailyActivity> weeklyActivity;
  final List<CategoryPerformance> categoryPerformances;

  const ParentStats({
    this.childName = 'Arab',
    this.childAge = 6,
    this.timeSpentThisWeek = '2h 15m',
    this.lessonsCompleted = 28,
    this.quizAccuracy = 88,
    this.currentStreakDays = 5,
    this.overallProgressPercent = 75,
    this.weeklyActivity = const [
      DailyActivity(dayName: 'Mon', minutesSpent: 25, normalizedHeight: 0.5),
      DailyActivity(dayName: 'Tue', minutesSpent: 35, normalizedHeight: 0.7),
      DailyActivity(dayName: 'Wed', minutesSpent: 20, normalizedHeight: 0.4),
      DailyActivity(dayName: 'Thu', minutesSpent: 45, normalizedHeight: 0.9),
      DailyActivity(dayName: 'Fri', minutesSpent: 30, normalizedHeight: 0.6),
      DailyActivity(dayName: 'Sat', minutesSpent: 50, normalizedHeight: 1.0),
      DailyActivity(dayName: 'Sun', minutesSpent: 22, normalizedHeight: 0.45),
    ],
    this.categoryPerformances = const [
      CategoryPerformance(
        categoryName: 'ABC Alphabets',
        accuracyPercentage: 90,
        colorHex: 0xFF7952F5,
      ),
      CategoryPerformance(
        categoryName: '123 Numbers',
        accuracyPercentage: 80,
        colorHex: 0xFF3B82F6,
      ),
      CategoryPerformance(
        categoryName: 'Animals World',
        accuracyPercentage: 70,
        colorHex: 0xFFF59E0B,
      ),
      CategoryPerformance(
        categoryName: 'Shapes & Colors',
        accuracyPercentage: 85,
        colorHex: 0xFF10B981,
      ),
    ],
  });

  @override
  List<Object?> get props => [
    childName,
    childAge,
    timeSpentThisWeek,
    lessonsCompleted,
    quizAccuracy,
    currentStreakDays,
    overallProgressPercent,
    weeklyActivity,
    categoryPerformances,
  ];
}
