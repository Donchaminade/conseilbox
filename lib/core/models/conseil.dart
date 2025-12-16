class Conseil {
  Conseil({
    required this.id,
    required this.title,
    required this.content,
    this.anecdote,
    required this.author,
    this.location,
    required this.status,
    this.socialLink1,
    this.socialLink2,
    this.socialLink3,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String? anecdote;
  final String author;
  final String? location;
  final String status;
  final String? socialLink1;
  final String? socialLink2;
  final String? socialLink3;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPublished => status == 'published';

  factory Conseil.fromJson(Map<String, dynamic> json) {
    return Conseil(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      anecdote: json['anecdote'] as String?,
      author: json['author'] as String? ?? 'Anonyme',
      location: json['location'] as String?,
      status: json['status'] as String? ?? 'pending',
      socialLink1: json['social_link_1'] as String?,
      socialLink2: json['social_link_2'] as String?,
      socialLink3: json['social_link_3'] as String?,
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
