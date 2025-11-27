import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    String? baseUrl,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 12),
                headers: const {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _request(
        path,
        method: 'GET',
        queryParameters: queryParameters,
      );

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) =>
      _request(
        path,
        method: 'POST',
        queryParameters: queryParameters,
        data: data,
      );

  Future<Response<dynamic>> _request(
    String path, {
    required String method,
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      final status = response.statusCode ?? 500;
      if (status >= 200 && status < 300) {
        return response;
      }

      throw ApiException(
        message: _extractMessage(response.data) ?? 'Erreur inattendue',
        statusCode: status,
        details: _extractErrors(response.data),
      );
    } on DioException catch (error) {
      final response = error.response;
      final status = response?.statusCode;

      throw ApiException(
        message: _extractMessage(response?.data) ??
            error.message ??
            'Impossible de joindre le serveur',
        statusCode: status,
        details: _extractErrors(response?.data),
      );
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) {
        return data['message'] as String;
      }
      if (data['error'] is String) {
        return data['error'] as String;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map(
          (key, value) {
            if (value is List && value.isNotEmpty) {
              return MapEntry(key, value.first);
            }
            return MapEntry(key, value);
          },
        );
      }
    }
    return null;
  }
}
