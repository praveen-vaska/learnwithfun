import '../../core/services/audio_service.dart';
import '../mock/mock_data.dart';
import '../models/app_user.dart';
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
  void loadForUser(AppUser? user);
  void loadForGuest();
}

class MockUserRepository implements UserRepository {
  final LocalStorageService? _storage;
  late ChildProfile _profile;
  final Map<String, ChildProfile> _userProfiles = {};

  MockUserRepository([this._storage]) {
    loadForUser(null);
  }

  @override
  ChildProfile getProfile() => _profile;

  @override
  void loadForUser(AppUser? user) {
    if (user == null) {
      _storage?.setScopeUser(null);
      final saved = _storage?.loadProfile();
      _profile = saved ?? MockData.initialProfile;
      _syncAudio();
      return;
    }

    _storage?.setScopeUser(user.id);
    if (_userProfiles.containsKey(user.id)) {
      _profile = _userProfiles[user.id]!;
      _syncAudio();
      return;
    }
    final saved = _storage?.loadProfile();
    if (saved != null) {
      _profile = saved;
      _userProfiles[user.id] = saved;
    } else if (user.id == 'demo_parent') {
      _profile = MockData.initialProfile;
      _userProfiles[user.id] = _profile;
      _storage?.saveProfile(_profile);
    } else {
      // Fresh new profile strictly isolated for this registered user
      _profile = ChildProfile(
        name: user.name.trim().isNotEmpty ? user.name.trim() : 'Little Explorer',
        age: 5,
        ageBand: '4-6 Years',
        avatarAsset: user.avatarAsset.isNotEmpty
            ? user.avatarAsset
            : 'assets/images/avatars/avatar_boy_1.svg',
        language: 'English',
        level: 1,
        currentXp: 0,
        nextLevelXp: 100,
        streakDays: 1,
        stars: 0,
        completedLessonsCount: 0,
        completedQuizzesCount: 0,
        accuracyPercent: 100.0,
        soundEnabled: true,
        musicEnabled: true,
        notificationsEnabled: true,
        screenTimeLimitEnabled: true,
        screenTimeLimitMinutes: 60,
        breakReminderEnabled: true,
      );
      _userProfiles[user.id] = _profile;
      _storage?.saveProfile(_profile);
    }
    _syncAudio();
  }

  @override
  void loadForGuest() {
    _storage?.setScopeUser('guest');
    if (_userProfiles.containsKey('guest')) {
      _profile = _userProfiles['guest']!;
      _syncAudio();
      return;
    }
    final saved = _storage?.loadProfile();
    if (saved != null) {
      _profile = saved;
      _userProfiles['guest'] = saved;
    } else {
      _profile = const ChildProfile(
        name: 'Guest Explorer',
        age: 5,
        ageBand: '4-6 Years',
        avatarAsset: 'assets/images/avatars/avatar_cat.svg',
        language: 'English',
        level: 1,
        currentXp: 0,
        nextLevelXp: 100,
        streakDays: 1,
        stars: 0,
        completedLessonsCount: 0,
        completedQuizzesCount: 0,
        accuracyPercent: 100.0,
        soundEnabled: true,
        musicEnabled: true,
        notificationsEnabled: true,
        screenTimeLimitEnabled: true,
        screenTimeLimitMinutes: 60,
        breakReminderEnabled: true,
      );
      _userProfiles['guest'] = _profile;
      _storage?.saveProfile(_profile);
    }
    _syncAudio();
  }

  void _syncAudio() {
    AppAudioService.instance.soundEnabled = _profile.soundEnabled;
    AppAudioService.instance.musicEnabled = _profile.musicEnabled;
  }

  @override
  void updateProfile(ChildProfile profile) {
    _profile = profile;
    final userId = _storage?.currentUserId;
    if (userId != null) {
      _userProfiles[userId] = profile;
    }
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
    final userId = _storage?.currentUserId;
    if (userId != null) {
      _userProfiles[userId] = _profile;
    }
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
