import 'package:dio/dio.dart';

/// User-facing message for API failures.
String friendlyDioErrorMessage(Object error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == 401) {
      return 'Session expired — please sign in again.';
    }
    if (status == 403) {
      return 'You do not have permission to perform this action.';
    }
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final nested = data['error'];
      if (nested is Map<String, dynamic>) {
        final message = nested['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'Network error — check your connection and try again.';
      default:
        break;
    }
  }
  return fallback;
}
