import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/app_user.dart';
import '../data/models/child_profile.dart';
import '../data/repositories/user_repository.dart';

class UserCubit extends Cubit<ChildProfile> {
  final UserRepository _userRepository;

  UserCubit(this._userRepository) : super(_userRepository.getProfile());

  void loadForUser(AppUser? user) {
    _userRepository.loadForUser(user);
    emit(_userRepository.getProfile());
  }

  void loadForGuest() {
    _userRepository.loadForGuest();
    emit(_userRepository.getProfile());
  }

  void setProfile({
    required String name,
    required int age,
    required String ageBand,
    required String avatarAsset,
    required String language,
  }) {
    final updated = state.copyWith(
      name: name,
      age: age,
      ageBand: ageBand,
      avatarAsset: avatarAsset,
      language: language,
    );
    _userRepository.updateProfile(updated);
    emit(updated);
  }

  void updateAvatar(String avatarAsset) {
    _userRepository.updateAvatar(avatarAsset);
    emit(state.copyWith(avatarAsset: avatarAsset));
  }

  void updateLanguage(String language) {
    _userRepository.updateLanguage(language);
    emit(state.copyWith(language: language));
  }

  void addXp(int xp) {
    _userRepository.addXp(xp);
    emit(_userRepository.getProfile());
  }

  void toggleSound(bool enabled) {
    _userRepository.toggleSound(enabled);
    emit(state.copyWith(soundEnabled: enabled));
  }

  void toggleMusic(bool enabled) {
    _userRepository.toggleMusic(enabled);
    emit(state.copyWith(musicEnabled: enabled));
  }

  void toggleNotifications(bool enabled) {
    _userRepository.toggleNotifications(enabled);
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  void updateScreenTime({
    required bool enabled,
    required int minutes,
    required bool breakReminder,
  }) {
    final updated = state.copyWith(
      screenTimeLimitEnabled: enabled,
      screenTimeLimitMinutes: minutes,
      breakReminderEnabled: breakReminder,
    );
    _userRepository.updateProfile(updated);
    emit(updated);
  }
}
