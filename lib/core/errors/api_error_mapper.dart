import 'dart:convert';

import 'package:dio/dio.dart';

class ApiErrorMapper {
  const ApiErrorMapper._();

  static String fromDioException(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;

    final message = _extractMessage(response?.data);
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Превышено время ожидания. Проверьте соединение.',
      DioExceptionType.connectionError =>
        'Нет подключения к интернету.',
      DioExceptionType.cancel => 'Запрос отменён.',
      DioExceptionType.badResponse => _statusMessage(statusCode),
      _ => 'Произошла ошибка. Попробуйте снова.',
    };
  }

  static String? _extractMessage(Object? data) {
    if (data == null) {
      return null;
    }

    if (data is Map<String, dynamic>) {
      return _readMessageField(data);
    }

    if (data is String) {
      try {
        final decoded = json.decode(data);
        if (decoded is Map<String, dynamic>) {
          return _readMessageField(decoded);
        }
      } catch (_) {
        if (data.isNotEmpty) {
          return data;
        }
      }
    }

    return null;
  }

  static String? _readMessageField(Map<String, dynamic> json) {
    final message = json['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    final detail = json['detail'];
    if (detail is String && detail.isNotEmpty) {
      return detail;
    }

    return null;
  }

  static String _statusMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Неверные данные запроса.',
      401 => 'Неверный email или пароль.',
      403 => 'Доступ запрещён.',
      404 => 'Ресурс не найден.',
      409 => 'Пользователь с таким email уже существует.',
      422 => 'Проверьте введённые данные.',
      500 || 502 || 503 => 'Сервер временно недоступен.',
      _ => 'Произошла ошибка. Попробуйте снова.',
    };
  }
}
