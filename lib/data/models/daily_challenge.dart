import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DailyChallengeItem extends Equatable {
  final String id;
  final String title;
  final int xpReward;
  final bool isCompleted;
  final IconData icon;

  const DailyChallengeItem({
    required this.id,
    required this.title,
    required this.xpReward,
    this.isCompleted = false,
    this.icon = Icons.star_rounded,
  });

  DailyChallengeItem copyWith({
    String? id,
    String? title,
    int? xpReward,
    bool? isCompleted,
    IconData? icon,
  }) {
    return DailyChallengeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [id, title, xpReward, isCompleted, icon];
}
