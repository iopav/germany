import 'package:dio/dio.dart';

class ErrorUtils {
  ErrorUtils._();

  static String dioFallbackMessage(
    DioException error, {
    required String operation,
  }) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The request to $operation timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please check your connection.';
      case DioExceptionType.cancel:
        return 'The request to $operation was cancelled.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == null) {
          return 'Failed to $operation. Please try again.';
        }
        return 'Failed to $operation with status code $statusCode.';
      default:
        return 'Failed to $operation. Please try again.';
    }
  }

  static String extractDioMessage(
    DioException error, {
    required String operation,
  }) {
    return extractMessage(
      error,
      fallback: dioFallbackMessage(error, operation: operation),
    );
  }

  static String extractMessage(
    Object error, {
    required String fallback,
  }) {
    if (error is DioException) {
      final fromResponse = _extractFromDynamic(error.response?.data);
      if (fromResponse.isNotEmpty) {
        return fromResponse;
      }

      final dioMessage = error.message?.trim() ?? '';
      final fromDioMessage = _extractFromDynamic(dioMessage);
      if (fromDioMessage.isNotEmpty) {
        return fromDioMessage;
      }
      if (dioMessage.isNotEmpty) {
        return dioMessage;
      }
    }

    final text = error.toString().replaceFirst('Exception: ', '').trim();
    final fromText = _extractFromDynamic(text);
    if (fromText.isNotEmpty) {
      return fromText;
    }
    if (text.isNotEmpty) {
      return text;
    }

    return fallback;
  }

  static String _extractFromDynamic(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    if (value is List) {
      final parts = value
          .map(_extractFromDynamic)
          .where((item) => item.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) {
        return parts.join(', ');
      }
      return '';
    }

    if (value is Map) {
      final detail = _extractFromDynamic(value['detail']);
      if (detail.isNotEmpty) {
        return detail;
      }

      final msg = _extractFromDynamic(value['msg']);
      if (msg.isNotEmpty) {
        return msg;
      }

      final message = _extractFromDynamic(value['message']);
      if (message.isNotEmpty) {
        return message;
      }
      return '';
    }

    return value.toString().trim();
  }
}
