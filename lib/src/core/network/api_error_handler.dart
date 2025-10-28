import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

class ApiError {
  final String message;
  final int? statusCode;
  final String? endpoint;
  final dynamic rawError;

  ApiError({
    required this.message,
    this.statusCode,
    this.endpoint,
    this.rawError,
  });

  @override
  String toString() => message;
}

class ApiErrorHandler {
  static const Map<int, String> _statusMessages = {
    400: 'Bad request. Please check your input.',
    401: 'Unauthorized access. Please login again.',
    403: 'Access denied. You do not have permission.',
    404: 'Resource not found.',
    408: 'Request timeout. Try again later.',
    422: 'Validation error. Please verify your input.',
    429: 'Too many requests. Please wait a moment.',
    500: 'Internal server error. Please try again later.',
    502: 'Bad gateway. Try again later.',
    503: 'Service unavailable. Try again later.',
    504: 'Gateway timeout. Try again later.',
  };

  /// Enable logging for debugging
  static bool enableLogging = true;

  static ApiError handleError(dynamic error) {
    if (error is! Exception) {
      return ApiError(message: 'Unexpected error occurred.', rawError: error);
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is SocketException) {
      return ApiError(message: 'No internet connection.', rawError: error);
    }

    if (error is TimeoutException) {
      return ApiError(message: 'Connection timed out.', rawError: error);
    }

    return ApiError(message: 'An unexpected error occurred.', rawError: error);
  }

  static ApiError _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final endpoint = e.requestOptions.uri.toString();

    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Connection timeout. Please check your network.';
        break;

      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;

      case DioExceptionType.badCertificate:
        message = 'Bad SSL certificate.';
        break;

      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet.';
        break;

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          message = 'No internet connection.';
        } else {
          message = 'Unexpected error occurred.';
        }
        break;

      case DioExceptionType.badResponse:
        message = _extractMessageFromResponse(e.response, statusCode);
        break;

      default:
        message = 'Something went wrong.';
    }

    if (enableLogging) {
      // ignore: avoid_print
      print('❌ API ERROR [$statusCode]: $message\n➡️ Endpoint: $endpoint');
    }

    return ApiError(
      message: message,
      statusCode: statusCode,
      endpoint: endpoint,
      rawError: e,
    );
  }

  static String _extractMessageFromResponse(Response? response, int? statusCode) {
    if (response == null) {
      return 'No response from server.';
    }

    // Custom API message extraction logic
    final data = response.data;
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] is Map && data['error']['message'] != null) {
        return data['error']['message'].toString();
      }
      if (data['error_description'] != null) {
        return data['error_description'].toString();
      }
    }

    if (statusCode != null && _statusMessages.containsKey(statusCode)) {
      return _statusMessages[statusCode]!;
    }

    return 'Something went wrong (${statusCode ?? 'Unknown Error'}).';
  }
}
