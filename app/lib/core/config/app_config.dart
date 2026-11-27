/// App-wide compile-time configuration.
///
/// Secrets are injected at build-time via --dart-define and are
/// therefore never stored in source code or the git history.
///
/// Local development:
///   flutter run --dart-define=CARTO_API_KEY=<your_key>
///
/// Without the variable the map falls back to OpenStreetMap tiles.
class AppConfig {
  AppConfig._();

  /// Carto basemap API key, injected via --dart-define=CARTO_API_KEY=...
  /// Empty when not provided.
  static const String cartoApiKey =
      String.fromEnvironment('CARTO_API_KEY', defaultValue: '');

  /// Supabase-Projekt (Konten, Haushalte, gemeinsame Liste). Beides ist
  /// öffentlich (Publishable Key, Schutz über RLS), kommt aber trotzdem per
  /// --dart-define, damit Forks und Tests ohne Server laufen. Leer = nur lokal.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_KEY', defaultValue: '');

  /// Schema-Stand, den diese App kann. Liegt der Server darüber
  /// (min_app_version), zeigt die App "Bitte neu laden".
  static const int appSchemaVersion = 1;

  // ── Tile URL templates ──────────────────────────────────────────────────

  /// CartoDB Voyager Raster Tiles (token authentication).
  /// Falls back to OpenStreetMap when no CARTO_API_KEY was provided.
  static String get cartoVoyagerUrl {
    if (cartoApiKey.isEmpty) return openStreetMapUrl;
    return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=$cartoApiKey';
  }

  static const String openStreetMapUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const String satelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
}
