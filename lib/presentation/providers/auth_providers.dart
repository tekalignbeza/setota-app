import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/jwt_utils.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/services/auth_service.dart';
import 'dio_provider.dart';

// ── Repository & Service Providers ───────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.read(dioProvider),
    secureStorage: ref.read(flutterSecureStorageProvider),
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(repository: ref.read(authRepositoryProvider));
});

// ── Auth State ───────────────────────────────────────────────────

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final AuthModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

// ── Auth Notifier ────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;
  Timer? _tokenRefreshTimer;

  AuthNotifier({
    required AuthService authService,
    required FlutterSecureStorage secureStorage,
  })  : _authService = authService,
        _secureStorage = secureStorage,
        super(const AuthState());

  /// Checks initial auth state on app start.
  Future<void> checkAuthState() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final token =
            await _secureStorage.read(key: AppConstants.accessTokenKey);
        if (token != null) {
          _scheduleTokenRefresh(token);
        }

        final userId = await _authService.getCurrentUserId();
        final customerId = await _authService.getCustomerId();
        final email =
            await _secureStorage.read(key: '${AppConstants.userIdKey}_email');

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: AuthModel(
            userId: userId,
            customerId: customerId,
            email: email,
            accessToken: token,
          ),
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  /// Logs in with the given credentials.
  Future<void> login(LoginRequest request) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

      final auth = await _authService.login(request);

      if (auth.accessToken != null) {
        _scheduleTokenRefresh(auth.accessToken!);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: auth,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractErrorMessage(e),
      );
    }
  }

  /// Registers a new customer.
  Future<void> register(RegisterRequest request) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

      final auth = await _authService.register(request);

      if (auth.accessToken != null) {
        _scheduleTokenRefresh(auth.accessToken!);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: auth,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractErrorMessage(e),
      );
    }
  }

  /// Logs out and clears auth state.
  Future<void> logout() async {
    _tokenRefreshTimer?.cancel();
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Sends a forgot-password email.
  Future<void> forgotPassword(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      await _authService.forgotPassword(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractErrorMessage(e),
      );
    }
  }

  /// Resets the password using a token.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      await _authService.resetPassword(
          token: token, newPassword: newPassword);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractErrorMessage(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // ── Private Helpers ──────────────────────────────────────────

  void _scheduleTokenRefresh(String token) {
    _tokenRefreshTimer?.cancel();

    final exp = JwtUtils.extractExpiration(token);
    if (exp == null) return;

    final expirationDate =
        DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    final now = DateTime.now().toUtc();
    final refreshAt = expirationDate
        .subtract(const Duration(seconds: AppConstants.tokenRefreshBufferSeconds));
    final duration = refreshAt.difference(now);

    if (duration.isNegative) {
      _performTokenRefresh();
      return;
    }

    _tokenRefreshTimer = Timer(duration, _performTokenRefresh);
  }

  Future<void> _performTokenRefresh() async {
    try {
      final auth = await _authService.refreshToken();
      if (auth.accessToken != null) {
        _scheduleTokenRefresh(auth.accessToken!);
      }
      state = state.copyWith(user: auth);
    } catch (_) {
      await logout();
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('DioException')) {
        return 'Network error. Please check your connection.';
      }
      return msg.replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred.';
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }
}

// ── Provider ─────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authService: ref.read(authServiceProvider),
    secureStorage: ref.read(flutterSecureStorageProvider),
  );
});
