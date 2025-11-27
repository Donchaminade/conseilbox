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
    int perPage = 10,
    String? status,
    String? author,
    String? location,
    String? search,
    String order = 'latest',
  }) async {
    final response = await _apiClient.get(
      '/conseils',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'status': status,
        'author': author,
        'location': location,
        'search': search,
        'order': order,
      }..removeWhere(
          (_, value) => value == null || (value is String && value.isEmpty)),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return PaginatedResponse<Conseil>.fromJson(
        data,
        (item) => Conseil.fromJson(item),
      );
    }

    throw ApiException(message: 'Réponse inattendue du serveur');
  }

  Future<Conseil> createConseil(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      '/conseils',
      data: FormData.fromMap(payload),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final conseilData = data['data'];
      if (conseilData is Map<String, dynamic>) {
        return Conseil.fromJson(conseilData);
      }
      if (!data.containsKey('data')) {
        return Conseil.fromJson(data);
      }
    }

    throw ApiException(message: 'Réponse inattendue lors de la création');
  }
}
