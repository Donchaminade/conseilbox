import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/paginated_response.dart';
import '../models/publicite.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';

class PubliciteService {
  PubliciteService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PaginatedResponse<Publicite>> fetchPublicites({
    int page = 1,
    int limit = 10,
    String? search,
    String sortBy = 'created_at',
    String order = 'DESC',
  }) async {
    final response = await _apiClient.get(
      'publicites/index.php', // Endpoint for listing publicites
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort_by': sortBy,
        'order': order,
        'search': search,
      }..removeWhere(
          (_, value) => value == null || (value is String && value.isEmpty)),
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('publicites')) {
      return PaginatedResponse<Publicite>.fromJson(
        data,
        (item) => Publicite.fromJson(item),
        dataKey: 'publicites', // Specify dataKey as 'publicites'
      );
    }

    throw ApiException(
        message: 'Réponse inattendue du serveur pour les publicités');
  }

  Future<Publicite> fetchSinglePublicite(String id) async {
    final response = await _apiClient.get(
      'publicites/read_single.php', // Endpoint for single publicite
      queryParameters: {'id': id},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // The single read API returns the Publicite object directly
      return Publicite.fromJson(data);
    }
    throw ApiException(
        message: 'Réponse inattendue lors de la récupération de la publicité');
  }

  Future<Publicite> createPublicite(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      'publicites/index.php', // Endpoint for creating publicite
      data: json.encode(payload), // Send as JSON body
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // The create API returns a message and id
      if (data.containsKey('id')) {
        return fetchSinglePublicite(data['id'].toString());
      }
    }

    throw ApiException(
        message: 'Réponse inattendue lors de la création de la publicité');
  }
}
