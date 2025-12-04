class Conseil {
  Conseil({
    required this.id,
    required this.title,
    required this.content,
    this.anecdote,
    required this.author,
    this.location,
    required this.status,
    required this.socialLinks,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String content;
  final String? anecdote;
  final String author;
  final String? location;
  final String status;
  final List<String> socialLinks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPublished => status == 'published';

  factory Conseil.fromJson(Map<String, dynamic> json) {
    return Conseil(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      anecdote: json['anecdote'] as String?,
      author: json['author'] as String? ?? 'Anonyme',
      location: json['location'] as String?,
      status: json['status'] as String? ?? 'pending',
      socialLinks: (json['social_links'] as List<dynamic>? ?? [])
          .map((link) => link.toString())
          .toList(),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // ignore: avoid_print
        print('Failed to parse date: "$value" -> $e');
        return null;
      }
    }
    // Also, handle cases where the API might send an integer timestamp.
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    return null;
  }
}
