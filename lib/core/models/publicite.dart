import '../network/api_config.dart'; // Ajouté

class Publicite {
  Publicite({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.targetUrl,
    required this.isActive,
    this.startDate, // Ajouté
    this.endDate, // Ajouté
    this.createdAt,
    this.updatedAt, // Ajouté
  });

  final String id; // Changed from int to String
  final String title;
  final String content;
  final String? imageUrl;
  final String? targetUrl;
  final bool isActive;
  final DateTime? startDate; // Ajouté
  final DateTime? endDate; // Ajouté
  final DateTime? createdAt;
  final DateTime? updatedAt; // Ajouté

  factory Publicite.fromJson(Map<String, dynamic> json) {
    String? relativeImageUrl = json['image_url'] as String?;
    String? fullImageUrl;

    if (relativeImageUrl != null && relativeImageUrl.isNotEmpty) {
      // Supprimer 'publicites/' si présent, puis ajouter la base URL
      String cleanPath = relativeImageUrl.startsWith('publicites/')
          ? relativeImageUrl.substring('publicites/'.length)
          : relativeImageUrl;
      fullImageUrl = ApiConfig.baseImageUrl + cleanPath;
    }

    return Publicite(
      id: json['id'].toString(), // Safely convert to String
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: fullImageUrl, // Utilisez l'URL complète ici
      targetUrl: json['target_url'] as String?,
      isActive: (json['is_active'] as int?) == 1,
      startDate: _parseDate(json['start_date']), // Ajouté
      endDate: _parseDate(json['end_date']), // Ajouté
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']), // Ajouté
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // ignore: avoid_print
        print('Failed to parse date for Publicite: "$value" -> $e');
        return null;
      }
    }
    return null;
  }
}
