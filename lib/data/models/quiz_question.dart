import 'package:equatable/equatable.dart';

class QuizOption extends Equatable {
  final String label;
  final String illustrationAsset;

  const QuizOption({required this.label, required this.illustrationAsset});

  @override
  List<Object?> get props => [label, illustrationAsset];
}

class QuizQuestion extends Equatable {
  final String id;
  final String questionText;
  final String illustrationAsset;
  final List<QuizOption> options;
  final int correctOptionIndex;
  final int xpReward;
  final String audioPrompt;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.illustrationAsset,
    required this.options,
    required this.correctOptionIndex,
    this.xpReward = 10,
    this.audioPrompt = '',
  });

  @override
  List<Object?> get props => [
    id,
    questionText,
    illustrationAsset,
    options,
    correctOptionIndex,
    xpReward,
    audioPrompt,
  ];
}
