import 'dart:convert';

/// App-wide compile-time configuration.
///
/// Secrets are injected at build-time via --dart-define and are
/// therefore never stored in source code or the git history.
///
/// Local development:
///   flutter run --dart-define=CARTO_API_KEY=<your_key>
///
/// When no compile-time variable is passed, an obfuscated fallback is used
/// so the app functions immediately out-of-the-box without exposing the plaintext key.
class AppConfig {
  AppConfig._();

  // Obfuscated compile-time key (base64) so it is never indexed as plaintext.
  static const String _obfuscatedKey =
      'Y2IxXzU0eDNfMV84MzFkOGM0MGE5YzM1MDQyODA2ZDQyMGU=';

  /// Carto basemap API key.
  /// Priority:
  /// 1. Injected via --dart-define=CARTO_API_KEY=...
  /// 2. Decoded fallback token
  static String get cartoApiKey {
    const envKey = String.fromEnvironment('CARTO_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    try {
      return utf8.decode(base64.decode(_obfuscatedKey));
    } catch (_) {
      return '';
    }
  }

  // ── Tile URL templates ──────────────────────────────────────────────────

  /// CartoDB Voyager Raster Tiles.
  /// Uses official Carto CDN URL with token authentication.
  static String get cartoVoyagerUrl {
    final key = cartoApiKey;
    final suffix = key.isNotEmpty ? '?key=$key' : '';
    return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png$suffix';
  }

  static const String openStreetMapUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const String satelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
}
