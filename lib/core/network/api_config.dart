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

    // Hardcode the local network IP for reliable debugging across devices.
    return 'http://192.168.1.90:8000/api';
  }

  // Ajouté pour la base URL des images
  static String get baseImageUrl {
    return 'http://192.168.1.90:8000/storage/';
  }
}
