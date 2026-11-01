import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/l10n_ext.dart' show NetworkException;
import '../../features/appointments/domain/appointment.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/domain/token_storage.dart';
import '../../features/documents/domain/medical_document.dart';

/// Thin Dio wrapper that adds the bearer token, refreshes it on `401` and
/// converts the backend's uniform error body into typed exceptions.
///
/// Error body: `{ "status": 409, "code": "SLOT_TAKEN", "message": "..." }`.
class ApiClient {
  ApiClient({required AppConfig config, required TokenStorage tokens, Dio? dio})
    // ignore: prefer_initializing_formals
    : _tokens = tokens,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: config.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Accept': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokens.readAccessToken();
          if (token != null && !options.path.startsWith('/auth/')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isAuthCall = error.requestOptions.path.startsWith('/auth/');
          if (error.response?.statusCode == 401 &&
              !isAuthCall &&
              await _refresh()) {
            try {
              final retry = await _dio.fetch<dynamic>(error.requestOptions);
              return handler.resolve(retry);
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokens;
  Future<bool>? _refreshing;

  Dio get dio => _dio;

  Future<bool> _refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final refresh = await _tokens.readRefreshToken();
    if (refresh == null) return false;
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final body = res.data!;
      await _tokens.saveTokens(
        access: body['accessToken'] as String,
        refresh: body['refreshToken'] as String?,
      );
      return true;
    } on DioException {
      await _tokens.clear();
      return false;
    }
  }

  /// Runs [call] and translates transport / API errors.
  Future<T> run<T>(Future<T> Function(Dio dio) call) async {
    try {
      return await call(_dio);
    } on DioException catch (e) {
      throw mapError(e);
    }
  }

  static Object mapError(DioException e) {
    final res = e.response;
    if (res == null) return const NetworkException();
    final data = res.data;
    final code = data is Map ? (data['code'] as String? ?? '') : '';
    switch (code) {
      case 'SLOT_TAKEN':
        return const BookingException(BookingFailure.slotTaken);
      case 'SLOT_IN_PAST':
        return const BookingException(BookingFailure.slotInPast);
      case 'OUTSIDE_SCHEDULE':
        return const BookingException(BookingFailure.outsideSchedule);
      case 'TOO_LATE_TO_CHANGE':
        return const BookingException(BookingFailure.tooLateToChange);
      case 'ALREADY_REVIEWED':
        return const BookingException(BookingFailure.alreadyReviewed);
      case 'NOT_COMPLETED':
        return const BookingException(BookingFailure.notCompleted);
      case 'INVALID_CREDENTIALS':
        return const AuthException(AuthFailure.invalidCredentials);
      case 'PHONE_TAKEN':
        return const AuthException(AuthFailure.phoneTaken);
      case 'ACCOUNT_NOT_FOUND':
        return const AuthException(AuthFailure.accountNotFound);
      case 'INVALID_OTP':
        return const AuthException(AuthFailure.invalidOtp);
      case 'CONSENT_REQUIRED':
        return const AuthException(AuthFailure.consentRequired);
      case 'FILE_EMPTY':
        return const UploadException(UploadFailure.empty);
      case 'FILE_TOO_LARGE':
        return const UploadException(UploadFailure.tooLarge);
      case 'FILE_TYPE_NOT_ALLOWED':
        return const UploadException(UploadFailure.unsupportedType);
    }
    if (res.statusCode == 404) {
      return const BookingException(BookingFailure.notFound);
    }
    return e;
  }
}
