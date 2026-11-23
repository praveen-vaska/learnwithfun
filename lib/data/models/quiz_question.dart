import 'package:equatable/equatable.dart';

class QuizOption extends Equatable {
  final String label;
  final String illustrationAsset;
  final String? animalSound; // e.g. 'cow', 'cat', 'dog', etc.

  const QuizOption({
    required this.label,
    required this.illustrationAsset,
    this.animalSound,
  });

  @override
  List<Object?> get props => [label, illustrationAsset, animalSound];
}

class QuizQuestion extends Equatable {
  final String id;
  final String questionText;
  final String illustrationAsset;
  final List<QuizOption> options;
  final int correctOptionIndex;
  final int xpReward;
  final String audioPrompt;
  final String? humanPrompt; // Text read aloud by human TTS (e.g. "Which animal says...")
  final String? animalSound; // Real animal sound key (e.g. 'cow', 'cat', 'lion')
  final String? soundDescription; // e.g. "Moo 🐄"
  final String? difficulty; // 'Very Easy', 'Easy', 'Medium', 'Hard', 'Very Hard'
  final String? funFact;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.illustrationAsset,
    required this.options,
    required this.correctOptionIndex,
    this.xpReward = 10,
    this.audioPrompt = '',
    this.humanPrompt,
    this.animalSound,
    this.soundDescription,
    this.difficulty,
    this.funFact,
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
    humanPrompt,
    animalSound,
    soundDescription,
    difficulty,
    funFact,
  ];
}
