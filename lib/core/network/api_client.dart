import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Single point of contact with the ElaraWave Rider API.
/// No screen/controller should ever hardcode this base URL or build
/// requests directly against dio/http.
class ApiClient {
  static const String baseUrl = 'http://18.170.4.157/elara/api/riderv1/';

  final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw const ApiException('Unexpected response from server.');
    } on DioException catch (e) {
      throw ApiException(_messageFor(e));
    }
  }

  String _messageFor(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The request timed out. Please check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'Could not connect. Please check your internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
