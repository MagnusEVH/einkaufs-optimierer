/// App-wide compile-time configuration.
///
/// Secrets are injected at build-time via --dart-define and are
/// therefore never stored in source code or the git history.
///
/// Local development:
///   flutter run --dart-define=CARTO_API_KEY=<your_key>
///
/// CI / GitHub Actions:
///   flutter build web --dart-define=CARTO_API_KEY=${{ secrets.CARTO_API_KEY }}
class AppConfig {
  AppConfig._();

  /// Carto basemap API key.
  /// Injected via --dart-define=CARTO_API_KEY=...
  /// Falls back to empty string (tiles still load, just without auth).
  static const String cartoApiKey = String.fromEnvironment(
    'CARTO_API_KEY',
    defaultValue: '',
  );

  // ── Tile URL templates ──────────────────────────────────────────────────

  static String get cartoVoyagerUrl {
    final suffix = cartoApiKey.isNotEmpty ? '?key=$cartoApiKey' : '';
    return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png$suffix';
  }

  static const String openStreetMapUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const String satelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
}

