import 'package:flutter/foundation.dart';

/// Centralizes the logic that resolves which base URL the app should
/// target depending on the platform and optional dart-define overrides.
class ApiConfig {
  ApiConfig._();

  static const String _override =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Returns the effective base URL that should be used for all API calls.
  ///
  /// Order of precedence:
  /// 1. `--dart-define API_BASE_URL=http://...`
  /// 2. Platform-aware sensible default (10.0.2.2 for Android emulators,
  ///    localhost for everything else including desktop and web).
  static String get baseUrl {
    if (_override.isNotEmpty) {
      return _override;
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api';
      default:
        return 'http://127.0.0.1:8000/api';
    }
  }
}
