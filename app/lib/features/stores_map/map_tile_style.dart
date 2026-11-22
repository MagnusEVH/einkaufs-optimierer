// app/lib/features/stores_map/map_tile_style.dart

import '../../core/config/app_config.dart';

enum TileStyle {
  voyager,
  openStreetMap,
  satellite,
}

/// Kachel-URL für den gewählten Kartenstil.
String tileUrlFor(TileStyle style) {
  switch (style) {
    case TileStyle.voyager:
      return AppConfig.cartoVoyagerUrl;
    case TileStyle.openStreetMap:
      return AppConfig.openStreetMapUrl;
    case TileStyle.satellite:
      return AppConfig.satelliteUrl;
  }
}

/// Kurzes Label für den Badge in der AppBar.
String tileStyleLabel(TileStyle style) => style == TileStyle.voyager
    ? 'CartoDB Voyager'
    : (style == TileStyle.satellite ? 'Satellit' : 'OSM');
