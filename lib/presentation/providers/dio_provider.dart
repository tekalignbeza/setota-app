import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/jwt_utils.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout:
        const Duration(seconds: AppConstants.connectionTimeoutSeconds),
    receiveTimeout:
        const Duration(seconds: AppConstants.receiveTimeoutSeconds),
    sendTimeout: const Duration(seconds: AppConstants.sendTimeoutSeconds),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  final secureStorage = ref.read(flutterSecureStorageProvider);

  // Auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Skip auth for public endpoints
      final skipAuthPaths = [
        AppConstants.loginEndpoint,
        AppConstants.registerEndpoint,
        AppConstants.refreshTokenEndpoint,
        AppConstants.checkoutCallbackEndpoint,
      ];

      final shouldSkip = skipAuthPaths.any(
        (path) => options.path.contains(path),
      );

      if (!shouldSkip) {
        final token =
            await secureStorage.read(key: AppConstants.accessTokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }

      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        // Attempt token refresh
        try {
          final refreshToken =
              await secureStorage.read(key: AppConstants.refreshTokenKey);
          if (refreshToken == null || refreshToken.isEmpty) {
            return handler.next(error);
          }

          final refreshDio = Dio(BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ));

          final response = await refreshDio.post(
            AppConstants.refreshTokenEndpoint,
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;

            if (newAccessToken != null) {
              await secureStorage.write(
                key: AppConstants.accessTokenKey,
                value: newAccessToken,
              );
            }
            if (newRefreshToken != null) {
              await secureStorage.write(
                key: AppConstants.refreshTokenKey,
                value: newRefreshToken,
              );
            }

            // Retry original request with new token
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(opts);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // Refresh failed — clear tokens
          await secureStorage.delete(key: AppConstants.accessTokenKey);
          await secureStorage.delete(key: AppConstants.refreshTokenKey);
          await secureStorage.delete(key: AppConstants.customerIdKey);
          await secureStorage.delete(key: AppConstants.userIdKey);
        }
      }

      handler.next(error);
    },
  ));

  // Error handling interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onError: (error, handler) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        handler.next(DioException(
          requestOptions: error.requestOptions,
          error: 'Connection timed out. Please check your internet connection.',
          type: error.type,
        ));
        return;
      }
      handler.next(error);
    },
  ));

  // Logger (only in development)
  if (!AppConstants.isProduction) {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: false,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: true,
    ));
  }

  return dio;
});
