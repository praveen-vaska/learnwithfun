import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> loginWithPhone({
    required String phone,
    required String password,
  });
  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  });
  Future<AppUser> register({
    required String name,
    String? email,
    String? phone,
    required String password,
  });
  Future<void> logout();
  Future<bool> resetPassword({
    String? email,
    String? phone,
    required String newPassword,
  });
}

class LocalAuthRepository implements AuthRepository {
  static const String _keyUsers = 'lwf_registered_users';
  static const String _keyCurrentSession = 'lwf_current_user_session';

  SharedPreferences? _prefs;
  AppUser? _cachedCurrentUser;

  AppUser? get currentUser => _cachedCurrentUser;

  LocalAuthRepository([dynamic storageOrPrefs]) {
    if (storageOrPrefs is SharedPreferences) {
      _prefs = storageOrPrefs;
    } else if (storageOrPrefs != null) {
      try {
        final candidate = (storageOrPrefs as dynamic).prefs;
        if (candidate is SharedPreferences) {
          _prefs = candidate;
        }
      } catch (_) {}
    }
  }

  Future<AppUser> signInWithPhone(String phone, String password) async {
    final user = await loginWithPhone(phone: phone, password: password);
    _cachedCurrentUser = user;
    return user;
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    final user = await loginWithEmail(email: email, password: password);
    _cachedCurrentUser = user;
    return user;
  }

  Future<AppUser> registerWithPhone({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    final user = await register(
      name: name,
      phone: phoneNumber,
      password: password,
    );
    _cachedCurrentUser = user;
    return user;
  }

  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await register(
      name: name,
      email: email,
      password: password,
    );
    _cachedCurrentUser = user;
    return user;
  }

  Future<void> signOut() async {
    await logout();
    _cachedCurrentUser = null;
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Simple, deterministic password hash for local storage
  String _hashPassword(String password) {
    // Simple custom hash string
    int hash = 5381;
    for (int i = 0; i < password.length; i++) {
      hash = ((hash << 5) + hash) + password.codeUnitAt(i);
    }
    return hash.toRadixString(16);
  }

  Future<Map<String, AppUser>> _loadUsers() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyUsers);
    final Map<String, AppUser> users = {};

    if (raw != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        for (final entry in decoded.entries) {
          users[entry.key] = AppUser.fromJson(entry.value as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    // Seed default demo user for effortless out-of-the-box testing
    if (!users.containsKey('demo_parent')) {
      final demoUser = AppUser(
        id: 'demo_parent',
        name: 'Parent Arab',
        email: 'parent@learnwithfun.com',
        phone: '9876543210',
        passwordHash: _hashPassword('password123'),
        createdAt: DateTime.now(),
      );
      users['demo_parent'] = demoUser;
      await _saveUsers(users);
    }

    return users;
  }

  Future<void> _saveUsers(Map<String, AppUser> users) async {
    final prefs = await _getPrefs();
    final map = users.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_keyUsers, jsonEncode(map));
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyCurrentSession);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AppUser.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+|-'), '').trim();
    final users = await _loadUsers();

    AppUser? matchedUser;
    for (final user in users.values) {
      if (user.phone == cleanPhone) {
        matchedUser = user;
        break;
      }
    }

    if (matchedUser == null) {
      throw AuthException('No account found with mobile number $cleanPhone. Please sign up first.');
    }

    if (matchedUser.passwordHash != _hashPassword(password)) {
      throw AuthException('Incorrect password. Please try again.');
    }

    final prefs = await _getPrefs();
    await prefs.setString(_keyCurrentSession, jsonEncode(matchedUser.toJson()));
    return matchedUser;
  }

  @override
  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final users = await _loadUsers();

    AppUser? matchedUser;
    for (final user in users.values) {
      if (user.email?.toLowerCase() == cleanEmail) {
        matchedUser = user;
        break;
      }
    }

    if (matchedUser == null) {
      throw AuthException('No account found with email $cleanEmail. Please sign up first.');
    }

    if (matchedUser.passwordHash != _hashPassword(password)) {
      throw AuthException('Incorrect password. Please try again.');
    }

    final prefs = await _getPrefs();
    await prefs.setString(_keyCurrentSession, jsonEncode(matchedUser.toJson()));
    return matchedUser;
  }

  @override
  Future<AppUser> register({
    required String name,
    String? email,
    String? phone,
    required String password,
  }) async {
    final users = await _loadUsers();
    final cleanPhone = phone?.replaceAll(RegExp(r'\s+|-'), '').trim();
    final cleanEmail = email?.trim().toLowerCase();

    // Check duplicate phone
    if (cleanPhone != null && cleanPhone.isNotEmpty) {
      for (final user in users.values) {
        if (user.phone == cleanPhone) {
          throw AuthException('Mobile number $cleanPhone is already registered. Please log in.');
        }
      }
    }

    // Check duplicate email
    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      for (final user in users.values) {
        if (user.email?.toLowerCase() == cleanEmail) {
          throw AuthException('Email $cleanEmail is already registered. Please log in.');
        }
      }
    }

    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = AppUser(
      id: userId,
      name: name.trim(),
      email: cleanEmail,
      phone: cleanPhone,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    users[userId] = newUser;
    await _saveUsers(users);

    final prefs = await _getPrefs();
    await prefs.setString(_keyCurrentSession, jsonEncode(newUser.toJson()));
    return newUser;
  }

  @override
  Future<void> logout() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyCurrentSession);
  }

  @override
  Future<bool> resetPassword({
    String? email,
    String? phone,
    required String newPassword,
  }) async {
    final users = await _loadUsers();
    final cleanPhone = phone?.replaceAll(RegExp(r'\s+|-'), '').trim();
    final cleanEmail = email?.trim().toLowerCase();

    AppUser? targetUser;
    for (final user in users.values) {
      if (cleanPhone != null && user.phone == cleanPhone) {
        targetUser = user;
        break;
      }
      if (cleanEmail != null && user.email?.toLowerCase() == cleanEmail) {
        targetUser = user;
        break;
      }
    }

    if (targetUser == null) {
      throw Exception('No account found for password reset.');
    }

    final updatedUser = targetUser.copyWith(
      passwordHash: _hashPassword(newPassword),
    );
    users[targetUser.id] = updatedUser;
    await _saveUsers(users);
    return true;
  }
}
