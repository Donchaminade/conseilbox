import 'dart:convert'; // Import added for json.encode

import 'package:dio/dio.dart';

import '../models/conseil.dart';
import '../models/paginated_response.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';

class ConseilService {
  ConseilService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PaginatedResponse<Conseil>> fetchConseils({
    int page = 1,
    int limit = 10, // Changed from perPage to limit as per API doc
    String? status,
    String? author,
    String? location,
    String? search,
    String sortBy = 'created_at', // Added sortBy as per API doc
    String order = 'DESC', // Default changed to DESC as per API doc example
  }) async {
    final response = await _apiClient.get(
      'conseils/', // Updated endpoint
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort_by': sortBy,
        'order': order,
        'status': status,
        'author': author,
        'location': location,
        'search': search,
      }..removeWhere(
          (_, value) => value == null || (value is String && value.isEmpty)),
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('conseils')) {
      return PaginatedResponse<Conseil>.fromJson(
        data,
        (item) => Conseil.fromJson(item),
        dataKey: 'conseils', // Specify dataKey as 'conseils' for the list
      );
    }

    throw ApiException(message: 'Réponse inattendue du serveur');
  }

  Future<Conseil> fetchSingleConseil(String id) async {
    final response = await _apiClient.get(
      'conseils/read_single.php', // New endpoint for single conseil
      queryParameters: {'id': id},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // The single read API returns the Conseil object directly, not wrapped in 'data'
      return Conseil.fromJson(data);
    }
    throw ApiException(
        message: 'Réponse inattendue lors de la récupération du conseil');
  }

  Future<Conseil> createConseil(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      'conseils/index.php', // Updated endpoint
      data: json.encode(payload), // Send as JSON body, not FormData
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;
    // The API now returns the full created object.
    if (data is Map<String, dynamic>) {
      return Conseil.fromJson(data);
    }

    throw ApiException(message: 'Réponse inattendue lors de la création');
  }
}
