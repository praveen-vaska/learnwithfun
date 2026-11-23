import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import 'quiz_question.dart';

class QuizLevel extends Equatable {
  final int levelNumber;
  final String title;
  final String subtitle;
  final String difficulty; // 'Very Easy', 'Easy', 'Medium', 'Hard', 'Very Hard'
  final Color themeColor;
  final IconData icon;
  final List<QuizQuestion> questions;
  final int xpReward;

  const QuizLevel({
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.themeColor,
    required this.icon,
    required this.questions,
    this.xpReward = 50,
  });

  @override
  List<Object?> get props => [
    levelNumber,
    title,
    subtitle,
    difficulty,
    themeColor,
    icon,
    questions,
    xpReward,
  ];
}
