import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/data/secure_storage.dart';
import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:fellow_traveller_mobile/core/router/router.dart';
import 'package:fellow_traveller_mobile/core/utils/talker.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';

const BASE_URL = 'https://your-api.example.com'; // move to env/config

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureTokenStorage);

  final SecureTokenStorage _secureTokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureTokenStorage.getToken();
    talker.info('Token present: ${token != null}');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/hal+json';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    talker.error(err);
    try {
      talker.error('DioException: ${err.response?.data}');
      if (err.response?.statusCode == 403) {
        final data = err.response?.data;

        String? message;
        if (data is Map<String, dynamic>) {
          message = data['message'] as String?;
        } else if (data is String) {
          try {
            final decoded = json.decode(data);
            if (decoded is Map<String, dynamic>) {
              message = decoded['message'] as String?;
            }
          } catch (_) {
            talker.error('Invalid JSON response: $data');
          }
        }

        if (message == 'token is not valid') {
          await _secureTokenStorage.deleteToken();
          if (rootNavigatorKey.currentContext?.mounted ?? false) {
            rootNavigatorKey.currentContext!.go(AppRoutesEnum.auth.path);
          }
        }
      }
    } catch (e) {
      talker.error('Error parsing error response: $e');
    }
    handler.next(err);
  }
}

class DioFactory {
  static Dio createDio(SecureTokenStorage secureTokenStorage) {
    final dio = Dio(BaseOptions(
      baseUrl: BASE_URL,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/hal+json',
      },
    ));

    dio.interceptors.addAll([
      AuthInterceptor(secureTokenStorage),
      TalkerDioLogger(talker: talker), // from talker_dio_logger
    ]);

    return dio;
  }
}