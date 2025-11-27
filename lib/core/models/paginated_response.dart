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
    T Function(Map<String, dynamic> item) mapper,
  ) {
    final List<dynamic> dataList = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    int toInt(dynamic value, {int fallback = 1}) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    return PaginatedResponse<T>(
      items: dataList
          .whereType<Map<String, dynamic>>()
          .map(mapper)
          .toList(growable: false),
      currentPage: toInt(meta['current_page']),
      lastPage: toInt(meta['last_page']),
      perPage: toInt(meta['per_page'], fallback: 15),
      total: toInt(meta['total'], fallback: dataList.length),
    );
  }
}
