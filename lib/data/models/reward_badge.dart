import 'package:equatable/equatable.dart';

class RewardBadge extends Equatable {
  final String id;
  final String title;
  final String description;
  final String assetPath;
  final bool isUnlocked;
  final int requiredXp;

  const RewardBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    this.isUnlocked = false,
    this.requiredXp = 100,
  });

  RewardBadge copyWith({
    String? id,
    String? title,
    String? description,
    String? assetPath,
    bool? isUnlocked,
    int? requiredXp,
  }) {
    return RewardBadge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assetPath: assetPath ?? this.assetPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredXp: requiredXp ?? this.requiredXp,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    assetPath,
    isUnlocked,
    requiredXp,
  ];
}
