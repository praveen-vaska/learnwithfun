import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/local_storage_service.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AppUser user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated({this.message});
  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class GuestExplorer extends AuthState {
  const GuestExplorer();
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final LocalStorageService _storage;

  AuthCubit(
    AuthRepository authRepository,
    LocalStorageService storage,
  )   : _authRepository = authRepository,
        _storage = storage,
        super(AuthInitial());

  AuthCubit.fromNamed({
    required AuthRepository authRepository,
    required LocalStorageService storageService,
  }) : this(authRepository, storageService);

  Future<void> checkAuth() => checkAuthStatus();

  Future<void> checkAuthStatus() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _storage.setScopeUser(user.id);
        emit(Authenticated(user));
      } else {
        _storage.setScopeUser(null);
        emit(const Unauthenticated());
      }
    } catch (_) {
      _storage.setScopeUser(null);
      emit(const Unauthenticated());
    }
  }

  Future<void> loginWithPhone(String phone, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.loginWithPhone(
        phone: phone,
        password: password,
      );
      _storage.setScopeUser(user.id);
      emit(Authenticated(user));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.loginWithEmail(
        email: email,
        password: password,
      );
      _storage.setScopeUser(user.id);
      emit(Authenticated(user));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> register({
    required String name,
    String? email,
    String? phone,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _storage.setScopeUser(user.id);
      emit(Authenticated(user));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      _storage.setScopeUser(null);
      emit(const Unauthenticated());
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  void continueAsGuest() {
    _storage.setScopeUser('guest');
    emit(const GuestExplorer());
  }

  Future<bool> resetPassword({
    String? email,
    String? phone,
    required String newPassword,
  }) async {
    try {
      return await _authRepository.resetPassword(
        email: email,
        phone: phone,
        newPassword: newPassword,
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(msg));
      return false;
    }
  }

  void clearError() {
    if (state is AuthError) {
      emit(const Unauthenticated());
    }
  }
}
