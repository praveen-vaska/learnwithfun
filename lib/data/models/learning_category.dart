import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LearningCategory extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final Color bgColor;
  final int totalLessons;
  final int completedLessons;

  const LearningCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.bgColor,
    required this.totalLessons,
    this.completedLessons = 0,
  });

  double get progress =>
      totalLessons > 0 ? (completedLessons / totalLessons) : 0.0;

  LearningCategory copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? assetPath,
    Color? bgColor,
    int? totalLessons,
    int? completedLessons,
  }) {
    return LearningCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      assetPath: assetPath ?? this.assetPath,
      bgColor: bgColor ?? this.bgColor,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    assetPath,
    bgColor,
    totalLessons,
    completedLessons,
  ];
}
