class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  @override
  String toString() {
    final buffer = StringBuffer(message);
    if (statusCode != null) {
      buffer.write(' (status: $statusCode)');
    }
    return buffer.toString();
  }
}
