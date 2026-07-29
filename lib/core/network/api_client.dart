import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Single point of contact with the ElaraWave Rider API.
/// No screen/controller should ever hardcode this base URL or build
/// requests directly against dio/http.
class ApiClient {
  /// Host and API path segments. The company slug sits between them:
  /// `https://elarawavesystem.com/<company>/api/riderv1/`.
  static const String host = 'https://elarawavesystem.com';
  static const String apiPath = 'api/riderv1';

  /// Builds the full base URL for a given company slug (e.g. "demo").
  /// Falls back to just the host when no company is set yet.
  static String baseUrlFor(String company) {
    final c = company.trim();
    if (c.isEmpty) return '$host/';
    return '$host/$c/$apiPath/';
  }

  final Dio _dio;
  String _company;

  String get company => _company;

  ApiClient({String company = ''})
      : _company = company.trim(),
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrlFor(company),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Full resolved URL (baseUrl + path + query parameters).
          developer.log(
            '[API] → ${options.method} ${options.uri}',
            name: 'ApiClient',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            '[API] ← ${response.statusCode} ${response.requestOptions.uri}',
            name: 'ApiClient',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          developer.log(
            '[API] ✕ ${error.response?.statusCode ?? ''} '
            '${error.requestOptions.uri}',
            name: 'ApiClient',
          );
          handler.next(error);
        },
      ),
    );
  }

  /// Points the client at a different company tenant. Must be called (via the
  /// login flow or app bootstrap) before any authenticated request.
  void setCompany(String company) {
    _company = company.trim();
    _dio.options.baseUrl = baseUrlFor(_company);
  }

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

  /// POSTs a multipart/form-data body. [fields] are plain string form fields;
  /// [files] maps a field name to a local file path uploaded as multipart
  /// (e.g. the profile photo). Files are attached only when a non-empty path
  /// is provided.
  Future<Map<String, dynamic>> postForm(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic> fields = const {},
    Map<String, String?> files = const {},
  }) async {
    try {
      final formMap = <String, dynamic>{
        for (final entry in fields.entries) entry.key: '${entry.value}',
      };
      for (final entry in files.entries) {
        final filePath = entry.value;
        if (filePath != null && filePath.trim().isNotEmpty) {
          formMap[entry.key] = await MultipartFile.fromFile(filePath);
        }
      }

      final response = await _dio.post(
        path,
        queryParameters: queryParameters,
        data: FormData.fromMap(formMap),
      );
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
