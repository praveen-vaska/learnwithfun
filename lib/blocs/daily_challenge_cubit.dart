import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/daily_challenge.dart';
import '../data/repositories/learning_repository.dart';

class DailyChallengeState extends Equatable {
  final List<DailyChallengeItem> challenges;
  final bool bonusClaimed;

  const DailyChallengeState({
    required this.challenges,
    this.bonusClaimed = false,
  });

  bool get allCompleted => challenges.every((c) => c.isCompleted);

  int get totalCompletedXp => challenges
      .where((c) => c.isCompleted)
      .fold(0, (sum, c) => sum + c.xpReward);

  DailyChallengeState copyWith({
    List<DailyChallengeItem>? challenges,
    bool? bonusClaimed,
  }) {
    return DailyChallengeState(
      challenges: challenges ?? this.challenges,
      bonusClaimed: bonusClaimed ?? this.bonusClaimed,
    );
  }

  @override
  List<Object?> get props => [challenges, bonusClaimed];
}

class DailyChallengeCubit extends Cubit<DailyChallengeState> {
  final LearningRepository _repository;

  DailyChallengeCubit(this._repository)
    : super(DailyChallengeState(challenges: _repository.getDailyChallenges()));

  void reloadForUser() {
    emit(DailyChallengeState(challenges: _repository.getDailyChallenges()));
  }

  void toggleChallenge(String id) {
    _repository.markChallengeCompleted(id);
    emit(state.copyWith(challenges: _repository.getDailyChallenges()));
  }

  void claimBonus() {
    emit(state.copyWith(bonusClaimed: true));
  }
}
