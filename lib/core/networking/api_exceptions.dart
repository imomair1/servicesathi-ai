import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');
      case DioExceptionType.connectionTimeout:
        return ApiException('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return ApiException('Receive timeout');
      case DioExceptionType.sendTimeout:
        return ApiException('Send timeout');
      case DioExceptionType.badResponse:
        return ApiException(
          _handleError(error.response?.statusCode, error.response?.data),
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.connectionError:
        return ApiException('Connection error. Please check your internet.');
      default:
        return ApiException('Something went wrong');
    }
  }

  static String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return error['message'] ?? 'Bad request';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You do not have permission.';
      case 404:
        return 'Not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message;
}
