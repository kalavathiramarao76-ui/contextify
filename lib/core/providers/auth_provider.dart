import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

/// Authentication state.
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final AppUser? user;
  final bool isLoading;
  final String? error;

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Provides the [AuthService] singleton.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Manages authentication state throughout the app.
class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _auth;

  @override
  AuthState build() {
    _auth = ref.watch(authServiceProvider);
    return const AuthState();
  }

  /// Check if user is already authenticated (called on app start).
  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _auth.getMe();
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, clearUser: true);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, clearUser: true);
    }
  }

  /// Log in with email and password.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _auth.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Connection error. Please check your internet and try again.',
      );
    }
  }

  /// Create a new account.
  Future<void> signup(
      String email, String password, String fullName) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _auth.signup(email, password, fullName);
      state = state.copyWith(user: user, isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Connection error. Please check your internet and try again.',
      );
    }
  }

  /// Log out the current user.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _auth.logout();
    state = const AuthState();
  }

  /// Clear any displayed error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// The main auth provider.
final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
