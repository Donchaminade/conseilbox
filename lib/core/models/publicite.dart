class Publicite {
  Publicite({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.targetUrl,
    required this.isActive,
    this.createdAt,
  });

  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? targetUrl;
  final bool isActive;
  final DateTime? createdAt;

  factory Publicite.fromJson(Map<String, dynamic> json) {
    return Publicite(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      targetUrl: json['target_url'] as String?,
      isActive: (json['is_active'] as bool?) ?? false,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
