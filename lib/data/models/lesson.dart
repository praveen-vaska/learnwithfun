import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String categoryId;
  final int order;
  final String title;
  final String conceptWord;
  final String description;
  final String illustrationAsset;
  final String soundText;
  final bool isCompleted;

  const Lesson({
    required this.id,
    required this.categoryId,
    required this.order,
    required this.title,
    required this.conceptWord,
    required this.description,
    required this.illustrationAsset,
    required this.soundText,
    this.isCompleted = false,
  });

  Lesson copyWith({
    String? id,
    String? categoryId,
    int? order,
    String? title,
    String? conceptWord,
    String? description,
    String? illustrationAsset,
    String? soundText,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      order: order ?? this.order,
      title: title ?? this.title,
      conceptWord: conceptWord ?? this.conceptWord,
      description: description ?? this.description,
      illustrationAsset: illustrationAsset ?? this.illustrationAsset,
      soundText: soundText ?? this.soundText,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    order,
    title,
    conceptWord,
    description,
    illustrationAsset,
    soundText,
    isCompleted,
  ];
}
