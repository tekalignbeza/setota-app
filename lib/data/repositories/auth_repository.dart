import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/jwt_utils.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  /// Logs in with email and password.
  Future<AuthModel> login(LoginRequest request) async {
    final response = await _dio.post(
      AppConstants.loginEndpoint,
      data: request.toJson(),
    );

    final auth = AuthModel.fromJson(response.data);
    await _persistTokens(auth);
    return auth;
  }

  /// Registers a new customer account.
  Future<AuthModel> register(RegisterRequest request) async {
    final response = await _dio.post(
      AppConstants.registerEndpoint,
      data: request.toJson(),
    );

    final auth = AuthModel.fromJson(response.data);
    await _persistTokens(auth);
    return auth;
  }

  /// Refreshes the access token using the stored refresh token.
  Future<AuthModel> refreshToken() async {
    final refreshToken =
        await _secureStorage.read(key: AppConstants.refreshTokenKey);

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    final response = await _dio.post(
      AppConstants.refreshTokenEndpoint,
      data: {'refreshToken': refreshToken},
    );

    final auth = AuthModel.fromJson(response.data);
    await _persistTokens(auth);
    return auth;
  }

  /// Logs out and clears all stored tokens.
  Future<void> logout() async {
    try {
      final token =
          await _secureStorage.read(key: AppConstants.accessTokenKey);
      if (token != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
    } catch (_) {
      // Ignore errors during logout API call
    } finally {
      await _clearTokens();
    }
  }

  /// Sends a forgot-password request.
  Future<void> forgotPassword(String email) async {
    await _dio.post(
      AppConstants.forgotPasswordEndpoint,
      data: {'email': email},
    );
  }

  /// Resets the password using a token.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dio.post(
      AppConstants.resetPasswordEndpoint,
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );
  }

  /// Validates the current access token.
  Future<bool> validateToken() async {
    try {
      final token =
          await _secureStorage.read(key: AppConstants.accessTokenKey);
      if (token == null || token.isEmpty) return false;

      final response = await _dio.get(
        AppConstants.validateTokenEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Returns the stored user ID.
  Future<String?> getCurrentUserId() async {
    return _secureStorage.read(key: AppConstants.userIdKey);
  }

  /// Returns the stored customer ID.
  Future<String?> getCustomerId() async {
    return _secureStorage.read(key: AppConstants.customerIdKey);
  }

  /// Returns the stored access token.
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  /// Returns true if the user is logged in with a non-expired token.
  Future<bool> isLoggedIn() async {
    final token =
        await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token == null || token.isEmpty) return false;
    return !JwtUtils.isExpired(token);
  }

  /// Returns true if the stored access token is still valid.
  Future<bool> isTokenValid() async {
    final token =
        await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token == null || token.isEmpty) return false;
    return !JwtUtils.isExpired(
      token,
      bufferSeconds: AppConstants.tokenRefreshBufferSeconds,
    );
  }

  // ── Private Helpers ────────────────────────────────────────────

  Future<void> _persistTokens(AuthModel auth) async {
    if (auth.accessToken != null) {
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: auth.accessToken!,
      );
    }
    if (auth.refreshToken != null) {
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: auth.refreshToken!,
      );
    }
    if (auth.userId != null) {
      await _secureStorage.write(
        key: AppConstants.userIdKey,
        value: auth.userId!,
      );
    }
    if (auth.customerId != null) {
      await _secureStorage.write(
        key: AppConstants.customerIdKey,
        value: auth.customerId!,
      );
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _secureStorage.delete(key: AppConstants.userIdKey);
    await _secureStorage.delete(key: AppConstants.customerIdKey);
  }
}
