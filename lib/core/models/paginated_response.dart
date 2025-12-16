import 'dart:math';

class PaginatedResponse<T> {
  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
  int get nextPage => hasMore ? currentPage + 1 : currentPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) mapper, {
    String dataKey = 'data', // Default dataKey to 'data', but allow override
  }) {
    final List<dynamic> dataList = json[dataKey] as List<dynamic>? ?? [];

    int toInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    final int total = toInt(json['total']);
    final int currentPage = toInt(json['page']);
    final int limit = toInt(json['limit']);
    final int lastPage = (limit > 0) ? (total / limit).ceil() : 1;


    return PaginatedResponse<T>(
      items: dataList
          .whereType<Map<String, dynamic>>()
          .map(mapper)
          .toList(growable: false),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: limit,
      total: total,
    );
  }
}

