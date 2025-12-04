import '../models/publicite.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';

class PubliciteService {
  PubliciteService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Publicite>> fetchPublicites({int limit = 10}) async {
    final response = await _apiClient.get(
      '/publicites',
      queryParameters: {'limit': limit, 'only_active': '1'},
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
