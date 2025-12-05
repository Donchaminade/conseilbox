import '../models/publicite.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';

class PubliciteService {
  PubliciteService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Publicite>> fetchPublicites({
    int limit = 10,
    String? search, // Nouveau paramètre
    String? order,  // Nouveau paramètre
    String? status, // Nouveau paramètre
  }) async {
    final Map<String, dynamic> queryParameters = {
      'limit': limit,
      'only_active': '1',
    };

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (order != null && order.isNotEmpty) {
      queryParameters['order'] = order;
    }
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    final response = await _apiClient.get(
      '/publicites',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(Publicite.fromJson)
            .toList(growable: false);
      }
    }

    throw ApiException(message: 'Impossible de lire les publicités.');
  }
}
