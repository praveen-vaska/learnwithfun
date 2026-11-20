import '../../core/services/audio_service.dart';
import '../mock/mock_data.dart';
import '../models/child_profile.dart';
import '../services/local_storage_service.dart';

abstract class UserRepository {
  ChildProfile getProfile();
  void updateProfile(ChildProfile profile);
  void addXp(int xp);
  void updateAvatar(String avatarAsset);
  void updateLanguage(String language);
  void toggleSound(bool enabled);
  void toggleMusic(bool enabled);
  void toggleNotifications(bool enabled);
}

class MockUserRepository implements UserRepository {
  final LocalStorageService? _storage;
  late ChildProfile _profile;

  MockUserRepository([this._storage]) {
    final saved = _storage?.loadProfile();
    _profile = saved ?? MockData.initialProfile;
    // Sync audio service with sound settings
    AppAudioService.instance.soundEnabled = _profile.soundEnabled;
    AppAudioService.instance.musicEnabled = _profile.musicEnabled;
  }

  @override
  ChildProfile getProfile() => _profile;

  @override
  void updateProfile(ChildProfile profile) {
    _profile = profile;
    AppAudioService.instance.soundEnabled = _profile.soundEnabled;
    AppAudioService.instance.musicEnabled = _profile.musicEnabled;
    _storage?.saveProfile(_profile);
  }

  @override
  void addXp(int xp) {
    int newXp = _profile.currentXp + xp;
    int newLevel = _profile.level;
    int nextLevelXp = _profile.nextLevelXp;

    if (newXp >= nextLevelXp) {
      newLevel += 1;
      nextLevelXp += 200;
    }

    _profile = _profile.copyWith(
      currentXp: newXp,
      level: newLevel,
      nextLevelXp: nextLevelXp,
    );
    _storage?.saveProfile(_profile);
  }

  @override
  void updateAvatar(String avatarAsset) {
    _profile = _profile.copyWith(avatarAsset: avatarAsset);
    _storage?.saveProfile(_profile);
  }

  @override
  void updateLanguage(String language) {
    _profile = _profile.copyWith(language: language);
    _storage?.saveProfile(_profile);
  }

  @override
  void toggleSound(bool enabled) {
    _profile = _profile.copyWith(soundEnabled: enabled);
    AppAudioService.instance.soundEnabled = enabled;
    _storage?.saveProfile(_profile);
  }

  @override
  void toggleMusic(bool enabled) {
    _profile = _profile.copyWith(musicEnabled: enabled);
    AppAudioService.instance.musicEnabled = enabled;
    _storage?.saveProfile(_profile);
  }

  @override
  void toggleNotifications(bool enabled) {
    _profile = _profile.copyWith(notificationsEnabled: enabled);
    _storage?.saveProfile(_profile);
  }
}
