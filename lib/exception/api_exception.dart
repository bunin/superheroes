import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  static const clientError = 'Client error happened';
  static const serverError = 'Server error happened';

  final String message;

  ApiException(this.message);

  factory ApiException.fromCode({required int code, String? message = ''}) {
    if (code > 499 && code < 600) {
      return ApiException(serverError);
    }
    if ((code > 399 && code < 500) ||
        (code == 200 && message != 'character with given name not found')) {
      return ApiException(clientError);
    }
    return ApiException(message ?? '');
  }

  @override
  String toString() {
    return message;
  }
}
