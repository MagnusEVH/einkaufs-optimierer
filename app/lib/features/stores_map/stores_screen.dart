// app/lib/features/stores_map/stores_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/models/store.dart';
import '../../core/services/location_service.dart';
import '../optimizer/optimizer_screen.dart';

/// Enum to allow toggling between the offline Interactive Vector Map and native Google Maps
enum MapProvider {
  vectorInteractive,
  googleMapsNative,
}

enum RoadType {
  autobahn,
  federal,
  mainStreet,
  localStreet,
}

/// Extensible model for roads with optional names
class MapRoad {
  final String? name;
  final RoadType type;
  final List<Offset> geoPoints; // (lat, lng)

  const MapRoad({
    this.name,
    required this.type,
    required this.geoPoints,
  });
}

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  UserLocation? _location;
  bool _isLoading = true;
  bool _isMapView = true;
  String _activeDistrict = 'Alle';
  String _activeChainFilter = 'Alle';

  // Initially NO store is selected: user gets full, clean map view
  Store? _selectedStore;

  // Toggle for road names (can be toggled in AppBar or at deep zoom)
  bool _showRoadNames = false;

  // Map engine selection
  MapProvider _mapProvider = MapProvider.vectorInteractive;

  // InteractiveViewer Transformation Controller
  final TransformationController _transformationController = TransformationController();

  // Geographic Bounding Box for Mainz-Bingen & Rhein-Hunsrück-Kreis
  static const double minLat = 49.84;
  static const double maxLat = 50.29;
  static const double minLng = 7.34;
  static const double maxLng = 8.24;

  // Virtual Canvas Dimension for realistic scaling
  static const double virtualCanvasWidth = 2400.0;
  static const double virtualCanvasHeight = 1900.0;

  // Complete preloaded dataset for both Landkreise (30 real stores with authentic addresses & opening hours)
  final List<Store> _allStores = const [
    // ==========================================
    // LANDKREIS MAINZ-BINGEN (14 Stores)
    // ==========================================
    Store(
      id: 'mb-1',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Bingen-Büdesheim',
      address: 'Saarlandstraße 165, 55411 Bingen am Rhein',
      latitude: 49.9545,
      longitude: 7.9172,
      clusterNum: 10,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 80,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-2',
      chain: SupermarketChain.lidl,
      name: 'Lidl Bingen-Büdesheim',
      address: 'Saarlandstraße 171, 55411 Bingen am Rhein',
      latitude: 49.9542,
      longitude: 7.9160,
      clusterNum: 10,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 120,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-3',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Bingen',
      address: 'Mainzer Straße 44, 55411 Bingen am Rhein',
      latitude: 49.9658,
      longitude: 7.9045,
      clusterNum: 11,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 950,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),
    Store(
      id: 'mb-4',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Bingen',
      address: 'Vorstadt 10-12, 55411 Bingen am Rhein',
      latitude: 49.9662,
      longitude: 7.8965,
      clusterNum: 12,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 1400,
      openingHours: 'Mo–Sa 08:30–20:00 Uhr',
    ),
    Store(
      id: 'mb-5',
      chain: SupermarketChain.rossmann,
      name: 'Rossmann Bingen Innenstadt',
      address: 'Basilikastraße 3, 55411 Bingen am Rhein',
      latitude: 49.9670,
      longitude: 7.8940,
      clusterNum: 12,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 1450,
      openingHours: 'Mo–Sa 08:30–20:00 Uhr',
    ),
    Store(
      id: 'mb-6',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Ingelheim',
      address: 'Nahering 1, 55218 Ingelheim am Rhein',
      latitude: 49.9720,
      longitude: 8.0450,
      clusterNum: 13,
      postalCode: '55218',
      city: 'Ingelheim am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 9200,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-7',
      chain: SupermarketChain.lidl,
      name: 'Lidl Ingelheim',
      address: 'Konrad-Adenauer-Straße 44, 55218 Ingelheim',
      latitude: 49.9710,
      longitude: 8.0480,
      clusterNum: 13,
      postalCode: '55218',
      city: 'Ingelheim am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 9400,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-8',
      chain: SupermarketChain.rewe,
      name: 'REWE Center Ingelheim',
      address: 'Am Hahnenbusch 1, 55218 Ingelheim',
      latitude: 49.9745,
      longitude: 8.0530,
      clusterNum: 14,
      postalCode: '55218',
      city: 'Ingelheim am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 9800,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),
    Store(
      id: 'mb-9',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Ingelheim',
      address: 'Binger Straße 85, 55218 Ingelheim',
      latitude: 49.9730,
      longitude: 8.0520,
      clusterNum: 14,
      postalCode: '55218',
      city: 'Ingelheim am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 9700,
      openingHours: 'Mo–Sa 08:00–20:00 Uhr',
    ),
    Store(
      id: 'mb-10',
      chain: SupermarketChain.netto,
      name: 'Netto Gau-Algesheim',
      address: 'Appenheimer Str. 36, 55435 Gau-Algesheim',
      latitude: 49.9540,
      longitude: 8.0180,
      clusterNum: 15,
      postalCode: '55435',
      city: 'Gau-Algesheim',
      district: 'Mainz-Bingen',
      distanceMeters: 7400,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-11',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Gau-Algesheim',
      address: 'Schlossgasse 22, 55435 Gau-Algesheim',
      latitude: 49.9560,
      longitude: 8.0210,
      clusterNum: 15,
      postalCode: '55435',
      city: 'Gau-Algesheim',
      district: 'Mainz-Bingen',
      distanceMeters: 7600,
      openingHours: 'Mo–Sa 07:00–21:30 Uhr',
    ),
    Store(
      id: 'mb-12',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Nieder-Olm',
      address: 'Am Woog 2, 55268 Nieder-Olm',
      latitude: 49.9110,
      longitude: 8.1960,
      clusterNum: 16,
      postalCode: '55268',
      city: 'Nieder-Olm',
      district: 'Mainz-Bingen',
      distanceMeters: 22000,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-13',
      chain: SupermarketChain.lidl,
      name: 'Lidl Nieder-Olm',
      address: 'Oppenheimer Str. 18, 55268 Nieder-Olm',
      latitude: 49.9100,
      longitude: 8.1980,
      clusterNum: 16,
      postalCode: '55268',
      city: 'Nieder-Olm',
      district: 'Mainz-Bingen',
      distanceMeters: 22200,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-14',
      chain: SupermarketChain.rewe,
      name: 'REWE Center Gensingen',
      address: 'Binger Straße 83, 55457 Gensingen',
      latitude: 49.8960,
      longitude: 7.9280,
      clusterNum: 17,
      postalCode: '55457',
      city: 'Gensingen',
      district: 'Mainz-Bingen',
      distanceMeters: 6700,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),

    // ==========================================
    // RHEIN-HUNSRÜCK-KREIS (16 Stores)
    // ==========================================
    Store(
      id: 'rh-1',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount Oberwesel',
      address: 'Chrishausener Str. 2, 55430 Oberwesel',
      latitude: 50.1082,
      longitude: 7.7285,
      clusterNum: 20,
      postalCode: '55430',
      city: 'Oberwesel',
      district: 'Rhein-Hunsrück',
      distanceMeters: 18500,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-2',
      chain: SupermarketChain.rewe,
      name: 'REWE City Oberwesel',
      address: 'Koblenzer Str. 18, 55430 Oberwesel',
      latitude: 50.1105,
      longitude: 7.7260,
      clusterNum: 20,
      postalCode: '55430',
      city: 'Oberwesel',
      district: 'Rhein-Hunsrück',
      distanceMeters: 18700,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-3',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Boppard',
      address: 'Hellerwaldstr. 1, 56154 Boppard',
      latitude: 50.2310,
      longitude: 7.5760,
      clusterNum: 21,
      postalCode: '56154',
      city: 'Boppard',
      district: 'Rhein-Hunsrück',
      distanceMeters: 33000,
      openingHours: 'Mo–Sa 07:00–21:30 Uhr',
    ),
    Store(
      id: 'rh-4',
      chain: SupermarketChain.lidl,
      name: 'Lidl Boppard',
      address: 'Mainzer Str. 48, 56154 Boppard',
      latitude: 50.2280,
      longitude: 7.5840,
      clusterNum: 21,
      postalCode: '56154',
      city: 'Boppard',
      district: 'Rhein-Hunsrück',
      distanceMeters: 32600,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-5',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Boppard-Buchholz',
      address: 'Buchenauer Str. 6, 56154 Boppard',
      latitude: 50.2180,
      longitude: 7.5360,
      clusterNum: 22,
      postalCode: '56154',
      city: 'Boppard',
      district: 'Rhein-Hunsrück',
      distanceMeters: 34000,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-6',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Boppard',
      address: 'Heerstraße 145, 56154 Boppard',
      latitude: 50.2330,
      longitude: 7.5910,
      clusterNum: 23,
      postalCode: '56154',
      city: 'Boppard',
      district: 'Rhein-Hunsrück',
      distanceMeters: 33200,
      openingHours: 'Mo–Sa 08:30–20:00 Uhr',
    ),
    Store(
      id: 'rh-7',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Simmern',
      address: 'August-Horch-Straße 2, 55469 Simmern',
      latitude: 49.9880,
      longitude: 7.5310,
      clusterNum: 24,
      postalCode: '55469',
      city: 'Simmern',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28000,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-8',
      chain: SupermarketChain.lidl,
      name: 'Lidl Simmern',
      address: 'Bingener Str. 30, 55469 Simmern',
      latitude: 49.9860,
      longitude: 7.5340,
      clusterNum: 24,
      postalCode: '55469',
      city: 'Simmern',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28200,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-9',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Simmern',
      address: 'Am Simmerbach 3, 55469 Simmern',
      latitude: 49.9830,
      longitude: 7.5250,
      clusterNum: 25,
      postalCode: '55469',
      city: 'Simmern',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28500,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),
    Store(
      id: 'rh-10',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Simmern',
      address: 'Schmiedelstraße 2, 55469 Simmern',
      latitude: 49.9850,
      longitude: 7.5280,
      clusterNum: 25,
      postalCode: '55469',
      city: 'Simmern',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28300,
      openingHours: 'Mo–Sa 08:00–20:00 Uhr',
    ),
    Store(
      id: 'rh-11',
      chain: SupermarketChain.rossmann,
      name: 'Rossmann Simmern Schloßplatz',
      address: 'Schloßplatz 3, 55469 Simmern',
      latitude: 49.9820,
      longitude: 7.5210,
      clusterNum: 25,
      postalCode: '55469',
      city: 'Simmern',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28700,
      openingHours: 'Mo–Sa 08:30–20:00 Uhr',
    ),
    Store(
      id: 'rh-12',
      chain: SupermarketChain.netto,
      name: 'Netto Emmelshausen',
      address: 'Rhein-Mosel-Str. 98, 56281 Emmelshausen',
      latitude: 50.1560,
      longitude: 7.6380,
      clusterNum: 26,
      postalCode: '56281',
      city: 'Emmelshausen',
      district: 'Rhein-Hunsrück',
      distanceMeters: 27500,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-13',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Emmelshausen',
      address: 'Argenschwanger Weg 1, 56281 Emmelshausen',
      latitude: 50.1580,
      longitude: 7.6410,
      clusterNum: 26,
      postalCode: '56281',
      city: 'Emmelshausen',
      district: 'Rhein-Hunsrück',
      distanceMeters: 27700,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-14',
      chain: SupermarketChain.lidl,
      name: 'Lidl Emmelshausen',
      address: 'Liesenfelder Weg 14, 56281 Emmelshausen',
      latitude: 50.1540,
      longitude: 7.6430,
      clusterNum: 26,
      postalCode: '56281',
      city: 'Emmelshausen',
      district: 'Rhein-Hunsrück',
      distanceMeters: 27600,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-15',
      chain: SupermarketChain.netto,
      name: 'Netto Kastellaun',
      address: 'Zeller Str. 32, 56288 Kastellaun',
      latitude: 50.0710,
      longitude: 7.4380,
      clusterNum: 27,
      postalCode: '56288',
      city: 'Kastellaun',
      district: 'Rhein-Hunsrück',
      distanceMeters: 36000,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-16',
      chain: SupermarketChain.netto,
      name: 'Netto St. Goar / Werlau',
      address: 'An der Loreley 1, 56329 St. Goar',
      latitude: 50.1500,
      longitude: 7.7120,
      clusterNum: 28,
      postalCode: '56329',
      city: 'St. Goar',
      district: 'Rhein-Hunsrück',
      distanceMeters: 22500,
      openingHours: 'Mo–Sa 07:00–20:00 Uhr',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _location = loc;
        _isLoading = false;
        // User request: DO NOT preselect any store! Keep view clean!
        _selectedStore = null;
      });
      // Initial viewpoint centered around Bingen / Middle Rhine
      _focusOnLocation(49.96, 7.91, 1.05);
    }
  }

  /// Converts true GPS (lat, lng) to virtual map canvas pixel coordinates (x, y)
  static Offset projectGpsToCanvas(double lat, double lng, Size canvasSize) {
    final clampedLat = lat.clamp(minLat, maxLat);
    final clampedLng = lng.clamp(minLng, maxLng);

    final x = ((clampedLng - minLng) / (maxLng - minLng)) * canvasSize.width;
    final y = ((maxLat - clampedLat) / (maxLat - minLat)) * canvasSize.height;

    return Offset(x, y);
  }

  List<Store> get _filteredStores {
    return _allStores.where((s) {
      // 1. District isolation filter
      if (_activeDistrict != 'Alle' && s.district != _activeDistrict) {
        return false;
      }

      // 2. Supermarket chain filter
      if (_activeChainFilter == 'Discounter') {
        return s.chain == SupermarketChain.aldi_sued ||
            s.chain == SupermarketChain.lidl ||
            s.chain == SupermarketChain.netto;
      }
      if (_activeChainFilter == 'Supermarkt') {
        return s.chain == SupermarketChain.rewe;
      }
      if (_activeChainFilter == 'Drogerie') {
        return s.chain == SupermarketChain.dm || s.chain == SupermarketChain.rossmann;
      }
      if (_activeChainFilter == 'Cluster (<500m)') {
        return s.clusterNum != null;
      }

      return true;
    }).toList();
  }

  Color _getChainColor(SupermarketChain chain) {
    switch (chain) {
      case SupermarketChain.lidl:
        return const Color(0xFF0050AA);
      case SupermarketChain.aldi_sued:
      case SupermarketChain.aldi_nord:
        return const Color(0xFF001A9C);
      case SupermarketChain.rewe:
        return const Color(0xFFCC071E);
      case SupermarketChain.netto:
        return const Color(0xFFE2A800);
      case SupermarketChain.dm:
        return const Color(0xFF2F2482);
      case SupermarketChain.rossmann:
        return const Color(0xFFC8102E);
    }
  }

  String _getChainBadge(SupermarketChain chain) {
    switch (chain) {
      case SupermarketChain.lidl:
        return 'LIDL';
      case SupermarketChain.aldi_sued:
      case SupermarketChain.aldi_nord:
        return 'ALDI';
      case SupermarketChain.rewe:
        return 'REWE';
      case SupermarketChain.netto:
        return 'NETTO';
      case SupermarketChain.dm:
        return 'dm';
      case SupermarketChain.rossmann:
        return 'ROSS';
    }
  }

  void _planFromStore(Store store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OptimizerResultScreen(startStore: store),
      ),
    );
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone();
    matrix.multiply(Matrix4.diagonal3Values(1.3, 1.3, 1.0));
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    matrix.multiply(Matrix4.diagonal3Values(0.77, 0.77, 1.0));
    _transformationController.value = matrix;
  }

  void _focusOnLocation(double lat, double lng, [double zoom = 1.1]) {
    final target = projectGpsToCanvas(lat, lng, const Size(virtualCanvasWidth, virtualCanvasHeight));
    final tx = -target.dx * zoom + 200;
    final ty = -target.dy * zoom + 320;
    final matrix = Matrix4.identity()
      ..translateByDouble(tx, ty, 0.0, 1.0)
      ..multiply(Matrix4.diagonal3Values(zoom, zoom, 1.0));
    _transformationController.value = matrix;
  }

  void _onDistrictSelected(String district) {
    setState(() {
      _activeDistrict = district;
      _selectedStore = null; // Reset selection so user can look around freely
    });

    if (district == 'Mainz-Bingen') {
      _focusOnLocation(49.96, 7.95, 1.25);
    } else if (district == 'Rhein-Hunsrück') {
      _focusOnLocation(50.08, 7.60, 1.15);
    } else {
      _focusOnLocation(50.02, 7.78, 0.95);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userLoc = _location ?? LocationService.bingenLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Karte',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _activeDistrict == 'Alle' ? 'MZ-BIN & RH' : _activeDistrict,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
            Text(
              '${_filteredStores.length} Filialen • Tippe einen Laden an',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          // Toggle Road Names on/off
          IconButton(
            icon: Icon(
              _showRoadNames ? Icons.label_rounded : Icons.label_outline_rounded,
              color: _showRoadNames ? const Color(0xFF059669) : const Color(0xFF334155),
              size: 20,
            ),
            tooltip: _showRoadNames ? 'Straßennamen verbergen' : 'Straßennamen anzeigen',
            onPressed: () => setState(() => _showRoadNames = !_showRoadNames),
          ),

          // Engine Switcher
          PopupMenuButton<MapProvider>(
            icon: const Icon(Icons.layers_outlined, color: Color(0xFF334155)),
            tooltip: 'Karten-Engine',
            onSelected: (prov) => setState(() => _mapProvider = prov),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: MapProvider.vectorInteractive,
                child: Row(
                  children: [
                    Icon(Icons.brush_rounded, size: 18, color: Color(0xFF059669)),
                    SizedBox(width: 10),
                    Text('Interaktive Vektor-Karte (Aktiv)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: MapProvider.googleMapsNative,
                child: Row(
                  children: [
                    Icon(Icons.public_rounded, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 10),
                    Text('Google Maps (Vorbereitung)'),
                  ],
                ),
              ),
            ],
          ),

          // Toggle View (Map vs List)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  icon: Icon(Icons.map_rounded, size: 18),
                  tooltip: 'Kartenansicht',
                ),
                ButtonSegment<bool>(
                  value: false,
                  icon: Icon(Icons.format_list_bulleted, size: 18),
                  tooltip: 'Listenansicht',
                ),
              ],
              selected: {_isMapView},
              onSelectionChanged: (set) {
                setState(() => _isMapView = set.first);
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: const Color(0xFF059669),
                selectedForegroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
          : Stack(
              children: [
                Column(
                  children: [
                    // Top District & Chain Filter Chips Bar
                    _buildDistrictAndFilterBar(),

                    // Map Canvas or List View
                    Expanded(
                      child: _isMapView
                          ? (_mapProvider == MapProvider.vectorInteractive
                              ? _buildInteractiveVectorMapView(userLoc)
                              : _buildGoogleMapsPlaceholderView())
                          : _buildStoreListView(theme),
                    ),
                  ],
                ),

                // Floating Store Action Card when a store is tapped by user
                if (_selectedStore != null && _isMapView)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildSelectedStoreSheet(theme),
                  ),
              ],
            ),
    );
  }

  Widget _buildDistrictAndFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: District Isolation (Mainz-Bingen vs Rhein-Hunsrück)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Landkreis:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
                const SizedBox(width: 8),
                _buildDistrictChip('Alle', '${_allStores.length}'),
                _buildDistrictChip('Mainz-Bingen', '14'),
                _buildDistrictChip('Rhein-Hunsrück', '16'),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Row 2: Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('Alle'),
                _buildCategoryChip('Discounter'),
                _buildCategoryChip('Supermarkt'),
                _buildCategoryChip('Drogerie'),
                _buildCategoryChip('Cluster (<500m)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictChip(String districtName, String count) {
    final isSelected = _activeDistrict == districtName;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        selected: isSelected,
        label: Text('$districtName ($count)'),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF1E293B),
        ),
        selectedColor: const Color(0xFF0F172A),
        backgroundColor: const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
        ),
        onSelected: (_) => _onDistrictSelected(districtName),
      ),
    );
  }

  Widget _buildCategoryChip(String filterName) {
    final isSelected = _activeChainFilter == filterName;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(filterName),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
        selectedColor: const Color(0xFF059669),
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(
          color: isSelected ? const Color(0xFF059669) : Colors.grey.shade300,
        ),
        onSelected: (val) {
          setState(() {
            _activeChainFilter = filterName;
            _selectedStore = null;
          });
        },
      ),
    );
  }

  /// Full Interactive Vector Map with Boundless Scrolling & GPU RepaintBoundary
  Widget _buildInteractiveVectorMapView(UserLocation userLoc) {
    const canvasSize = Size(virtualCanvasWidth, virtualCanvasHeight);

    return Stack(
      children: [
        // Gesture-enabled Interactive Canvas (Pan & Pinch-to-Zoom on iPhone)
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.35,
          maxScale: 4.0,
          // Massive boundary margins: frees the map completely so user never hits invisible walls!
          boundaryMargin: const EdgeInsets.all(5000),
          panAxis: PanAxis.free,
          clipBehavior: Clip.none,
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // RepaintBoundary caches background paths & street network for smooth 60fps on iPhone!
                RepaintBoundary(
                  child: CustomPaint(
                    size: canvasSize,
                    painter: _RegionalVectorMapPainter(canvasSize, showRoadNames: _showRoadNames),
                  ),
                ),

                // GPS User Location Marker
                _buildUserLocationMarker(userLoc, canvasSize),

                // Store Map Pins positioned with exact GPS projection strictly on land
                ..._buildProjectedStorePins(canvasSize),
              ],
            ),
          ),
        ),

        // Floating Zoom and Navigation Controls (Right Edge)
        Positioned(
          right: 14,
          bottom: _selectedStore != null ? 220 : 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'map_zoom_in_pwa',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 3,
                tooltip: 'Heranzoomen',
                onPressed: _zoomIn,
                child: const Icon(Icons.add_rounded, size: 20),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'map_zoom_out_pwa',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 3,
                tooltip: 'Herauszoomen',
                onPressed: _zoomOut,
                child: const Icon(Icons.remove_rounded, size: 20),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'map_recenter_pwa',
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 4,
                tooltip: 'Mein Standort zentrieren',
                onPressed: () => _focusOnLocation(userLoc.latitude, userLoc.longitude, 1.4),
                child: const Icon(Icons.my_location_rounded, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserLocationMarker(UserLocation userLoc, Size canvasSize) {
    final pos = projectGpsToCanvas(userLoc.latitude, userLoc.longitude, canvasSize);

    return Positioned(
      left: pos.dx - 45,
      top: pos.dy - 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_pin, color: Colors.white, size: 12),
                SizedBox(width: 3),
                Text(
                  'Mein Standort',
                  style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2563EB),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProjectedStorePins(Size canvasSize) {
    return _filteredStores.map((store) {
      final pos = projectGpsToCanvas(store.latitude, store.longitude, canvasSize);
      final isSelected = _selectedStore?.id == store.id;
      final chainColor = _getChainColor(store.chain);
      final badge = _getChainBadge(store.chain);

      return Positioned(
        left: pos.dx - 36,
        top: pos.dy - 42,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _selectedStore = store;
            });
          },
          child: AnimatedScale(
            scale: isSelected ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Store Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.35 : 0.15),
                        blurRadius: isSelected ? 7 : 3,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: chainColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        store.city ?? '',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),

                // Map Pin Head
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isSelected ? 42 : 34,
                      color: chainColor,
                    ),
                    Positioned(
                      top: isSelected ? 7 : 5,
                      child: Container(
                        width: isSelected ? 16 : 13,
                        height: isSelected ? 16 : 13,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          store.chain == SupermarketChain.dm || store.chain == SupermarketChain.rossmann
                              ? Icons.sanitizer_outlined
                              : Icons.shopping_basket_rounded,
                          size: isSelected ? 10 : 8,
                          color: chainColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Modern Bottom Action Card when user selects a Store, including authentic Opening Hours & Close Button
  Widget _buildSelectedStoreSheet(ThemeData theme) {
    final store = _selectedStore!;
    final chainColor = _getChainColor(store.chain);
    final distanceMeters = store.distanceMeters?.toInt() ?? 250;
    final walkMinutes = (distanceMeters / 75).ceil();
    final driveMinutes = math.max(1, (distanceMeters / 400).ceil());

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Chain Icon, Name, Badge, and Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: chainColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: chainColor.withValues(alpha: 0.25)),
                ),
                child: Icon(
                  store.chain == SupermarketChain.dm || store.chain == SupermarketChain.rossmann
                      ? Icons.clean_hands_rounded
                      : Icons.storefront_rounded,
                  color: chainColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      store.address,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Close button to dismiss card
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                tooltip: 'Schließen',
                onPressed: () {
                  setState(() => _selectedStore = null);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Opening Hours Pill (User requirement: Öffnungszeiten werden prominent angezeigt!)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF86EFAC).withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded, size: 15, color: Color(0xFF15803D)),
                const SizedBox(width: 6),
                const Text(
                  'Geöffnet',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                ),
                const SizedBox(width: 6),
                Text(
                  '•  ${store.displayOpeningHours}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Details row: Walking / Driving times & Cluster
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_walk_rounded, size: 14, color: Color(0xFF475569)),
                    const SizedBox(width: 4),
                    Text(
                      '~$walkMinutes Min.',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_rounded, size: 14, color: Color(0xFF475569)),
                    const SizedBox(width: 4),
                    Text(
                      '~$driveMinutes Min.',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cluster ${store.clusterNum ?? '-'}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary Action Button: "Von diesem Laden ausplanen"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              icon: const Icon(Icons.alt_route_rounded, size: 20),
              label: const Text(
                'Von diesem Laden ausplanen 🚀',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () => _planFromStore(store),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreListView(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _filteredStores.length,
      itemBuilder: (ctx, index) {
        final store = _filteredStores[index];
        final chainColor = _getChainColor(store.chain);
        final isSelected = _selectedStore?.id == store.id;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isSelected ? const Color(0xFF059669) : Colors.black.withValues(alpha: 0.08),
              width: isSelected ? 2 : 1,
            ),
          ),
          color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: chainColor.withValues(alpha: 0.15),
                  child: Icon(
                    store.chain == SupermarketChain.dm || store.chain == SupermarketChain.rossmann
                        ? Icons.sanitizer_outlined
                        : Icons.storefront_rounded,
                    color: chainColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        store.address,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            store.displayOpeningHours,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                          ),
                          const Spacer(),
                          Text(
                            'Cluster ${store.clusterNum}',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFD1FAE5),
                    foregroundColor: const Color(0xFF065F46),
                  ),
                  tooltip: 'Von hier ausplanen',
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  onPressed: () => _planFromStore(store),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleMapsPlaceholderView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_rounded, color: Color(0xFF2563EB), size: 48),
            const SizedBox(height: 12),
            const Text(
              'Google Maps Modus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Die Umschaltung auf native Google Maps ist vorbereitet. Die Offline-Vektor-Karte ist aktuell für Mainz-Bingen & Rhein-Hunsrück optimiert.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _mapProvider = MapProvider.vectorInteractive),
              child: const Text('Zurück zur Vektor-Karte'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Regional Vector Painter drawing boundless terrain, accurate Rhine riverbed, and extensible street network
class _RegionalVectorMapPainter extends CustomPainter {
  final Size canvasSize;
  final bool showRoadNames;
  const _RegionalVectorMapPainter(this.canvasSize, {this.showRoadNames = false});

  Offset toPx(double lat, double lng) {
    return _StoresScreenState.projectGpsToCanvas(lat, lng, canvasSize);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Boundless Base Terrain: extends infinitely beyond canvas edges so user never sees borders!
    final bgPaint = Paint()..color = const Color(0xFFF2EFE9);
    canvas.drawRect(
      Rect.fromLTWH(-3000, -3000, size.width + 6000, size.height + 6000),
      bgPaint,
    );

    // 2. Natural Forests (Soonwald, Hunsrück, Binger Wald & Rheingau)
    final forestPaint = Paint()..color = const Color(0xFFDCEAD7);
    final forestPath = Path()
      ..moveTo(toPx(50.18, 7.36).dx, toPx(50.18, 7.36).dy)
      ..lineTo(toPx(50.27, 7.50).dx, toPx(50.27, 7.50).dy)
      ..lineTo(toPx(50.06, 7.66).dx, toPx(50.06, 7.66).dy)
      ..lineTo(toPx(49.88, 7.56).dx, toPx(49.88, 7.56).dy)
      ..lineTo(toPx(49.90, 7.38).dx, toPx(49.90, 7.38).dy)
      ..close();
    canvas.drawPath(forestPath, forestPaint);

    final bingerWald = Path()
      ..moveTo(toPx(50.02, 7.74).dx, toPx(50.02, 7.74).dy)
      ..lineTo(toPx(50.04, 7.85).dx, toPx(50.04, 7.85).dy)
      ..lineTo(toPx(49.97, 7.86).dx, toPx(49.97, 7.86).dy)
      ..lineTo(toPx(49.95, 7.75).dx, toPx(49.95, 7.75).dy)
      ..close();
    canvas.drawPath(bingerWald, forestPaint);

    // 3. District Border Line (Dashed subtle border)
    final borderPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final bPath = Path()
      ..moveTo(toPx(50.20, 7.72).dx, toPx(50.20, 7.72).dy)
      ..lineTo(toPx(50.09, 7.75).dx, toPx(50.09, 7.75).dy)
      ..lineTo(toPx(49.99, 7.79).dx, toPx(49.99, 7.79).dy)
      ..lineTo(toPx(49.86, 7.83).dx, toPx(49.86, 7.83).dy);
    canvas.drawPath(bPath, borderPaint);

    // 4. Street Network (hierarchical with road styles)
    _paintRoads(canvas);

    // 5. River Rhine (Rhein): Mathematically shifted strictly to the EAST (right bank) of all stores!
    // NO STORE WILL EVER BE IN THE WATER!
    final riverPaint = Paint()
      ..color = const Color(0xFFA5D7FE)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final riverPath = Path()
      ..moveTo(toPx(50.005, 8.24).dx, toPx(50.005, 8.24).dy) // East towards Mainz/Wiesbaden
      ..lineTo(toPx(50.003, 8.06).dx, toPx(50.003, 8.06).dy) // North of Ingelheim stores (Ingelheim is at 49.97)
      ..lineTo(toPx(49.975, 7.915).dx, toPx(49.975, 7.915).dy) // North of Bingen Stadt stores (Bingen is at 49.966)
      ..lineTo(toPx(49.978, 7.888).dx, toPx(49.978, 7.888).dy) // Binger Loch Mäuseturm bend
      ..cubicTo(
        toPx(50.02, 7.81).dx, toPx(50.02, 7.81).dy,
        toPx(50.06, 7.785).dx, toPx(50.06, 7.785).dy,
        toPx(50.108, 7.738).dx, toPx(50.108, 7.738).dy, // East of Oberwesel stores (Oberwesel is at 7.726)
      )
      ..lineTo(toPx(50.152, 7.722).dx, toPx(50.152, 7.722).dy) // East of St. Goar (St. Goar is at 7.712)
      ..cubicTo(
        toPx(50.18, 7.68).dx, toPx(50.18, 7.68).dy,
        toPx(50.21, 7.61).dx, toPx(50.21, 7.61).dy,
        toPx(50.236, 7.602).dx, toPx(50.236, 7.602).dy, // East of Boppard stores (Boppard is at 7.585)
      )
      ..lineTo(toPx(50.260, 7.610).dx, toPx(50.260, 7.610).dy); // North to Koblenz
    canvas.drawPath(riverPath, riverPaint);

    // River Nahe (joins Rhine at Bingen Knie): strictly narrow and cleanly South of Bingen Stadt
    final nahePaint = Paint()
      ..color = const Color(0xFFA5D7FE)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;
    final nahePath = Path()
      ..moveTo(toPx(49.85, 7.94).dx, toPx(49.85, 7.94).dy) // from Bad Kreuznach/Gensingen
      ..lineTo(toPx(49.945, 7.925).dx, toPx(49.945, 7.925).dy) // east of Büdesheim
      ..lineTo(toPx(49.970, 7.892).dx, toPx(49.970, 7.892).dy); // mouth into Rhine
    canvas.drawPath(nahePath, nahePaint);

    // 6. Geographic Region & District Labels
    _drawLabel(canvas, 'RHEIN-HUNSRÜCK-KREIS', toPx(50.10, 7.46), 14, const Color(0xFF64748B), true);
    _drawLabel(canvas, 'LANDKREIS MAINZ-BINGEN', toPx(49.92, 8.08), 14, const Color(0xFF64748B), true);

    // Towns
    _drawLabel(canvas, 'Bingen am Rhein', toPx(49.967, 7.886), 11.5, const Color(0xFF0F172A), true);
    _drawLabel(canvas, 'Büdesheim', toPx(49.952, 7.915), 10, const Color(0xFF334155), false);
    _drawLabel(canvas, 'Ingelheim am Rhein', toPx(49.975, 8.040), 11.5, const Color(0xFF0F172A), true);
    _drawLabel(canvas, 'Gau-Algesheim', toPx(49.955, 8.016), 10, const Color(0xFF334155), false);
    _drawLabel(canvas, 'Oberwesel', toPx(50.111, 7.720), 11, const Color(0xFF0F172A), true);
    _drawLabel(canvas, 'Boppard', toPx(50.230, 7.570), 11.5, const Color(0xFF0F172A), true);
    _drawLabel(canvas, 'Simmern (Hunsrück)', toPx(49.985, 7.518), 11.5, const Color(0xFF0F172A), true);
    _drawLabel(canvas, 'Emmelshausen', toPx(50.155, 7.632), 10.5, const Color(0xFF0F172A), true);
    _drawLabel(canvas, 'Kastellaun', toPx(50.070, 7.430), 10, const Color(0xFF334155), false);
    _drawLabel(canvas, 'St. Goar', toPx(50.149, 7.705), 10, const Color(0xFF334155), false);
    _drawLabel(canvas, '~ RHEIN ~', toPx(50.04, 7.80), 11, const Color(0xFF1E3A8A), true);
  }

  void _paintRoads(Canvas canvas) {
    // Road Definition List (Extensible: name is included and ready for tooltips/labels)
    final roads = [
      // Bundesstraße B9 along the Rhine (left bank)
      MapRoad(
        name: 'B9',
        type: RoadType.federal,
        geoPoints: [
          toPx(49.98, 8.16),
          toPx(49.972, 8.045), // Ingelheim
          toPx(49.965, 7.905), // Bingen Mainzer Str.
          toPx(49.967, 7.893), // Bingen Stadt
          toPx(50.060, 7.768), // Bacharach
          toPx(50.110, 7.727), // Oberwesel Koblenzer Str.
          toPx(50.150, 7.712), // St. Goar
          toPx(50.228, 7.584), // Boppard Mainzer Str.
          toPx(50.270, 7.580), // towards Koblenz
        ],
      ),

      // Autobahn A61
      MapRoad(
        name: 'A61',
        type: RoadType.autobahn,
        geoPoints: [
          toPx(49.85, 7.96),
          toPx(49.95, 7.88),
          toPx(50.04, 7.68), // Rheinböllen
          toPx(50.16, 7.62), // Emmelshausen
          toPx(50.23, 7.52), // Boppard-Buchholz
          toPx(50.28, 7.48),
        ],
      ),

      // Bundesstraße B50 (Simmern to Rheinböllen/A61)
      MapRoad(
        name: 'B50',
        type: RoadType.federal,
        geoPoints: [
          toPx(49.97, 7.42), // Kirchberg
          toPx(49.986, 7.53), // Simmern
          toPx(50.005, 7.675), // Rheinböllen
        ],
      ),

      // Bundesstraße B327 (Hunsrückhöhenstraße)
      MapRoad(
        name: 'B327',
        type: RoadType.federal,
        geoPoints: [
          toPx(50.16, 7.64), // Emmelshausen
          toPx(50.07, 7.44), // Kastellaun
          toPx(49.98, 7.36),
        ],
      ),

      // Autobahn A60 (Ingelheim -> Mainz)
      MapRoad(
        name: 'A60',
        type: RoadType.autobahn,
        geoPoints: [
          toPx(49.968, 7.98),
          toPx(49.965, 8.06),
          toPx(49.940, 8.16),
          toPx(49.920, 8.24),
        ],
      ),

      // Connecting Main Roads:
      // Bingen to Simmern connection via Soonwald (L214)
      MapRoad(
        name: 'L214',
        type: RoadType.mainStreet,
        geoPoints: [
          toPx(49.954, 7.917), // Bingen Büdesheim
          toPx(49.98, 7.76),
          toPx(50.005, 7.675), // Rheinböllen
        ],
      ),

      // Bingen to Gensingen / Bad Kreuznach (B41 / L417)
      MapRoad(
        name: 'B41',
        type: RoadType.federal,
        geoPoints: [
          toPx(49.954, 7.916), // Büdesheim
          toPx(49.91, 7.92),
          toPx(49.896, 7.928), // Gensingen
        ],
      ),

      // Local town grid lines (Clean, soft secondary streets)
      MapRoad(
        name: 'Saarlandstraße',
        type: RoadType.localStreet,
        geoPoints: [toPx(49.945, 7.910), toPx(49.960, 7.925)],
      ),
      MapRoad(
        name: 'Mainzer Straße',
        type: RoadType.localStreet,
        geoPoints: [toPx(49.963, 7.900), toPx(49.968, 7.915)],
      ),
      MapRoad(
        name: 'Ingelheim Zentrum',
        type: RoadType.localStreet,
        geoPoints: [toPx(49.968, 8.040), toPx(49.978, 8.060)],
      ),
      MapRoad(
        name: 'Simmern Zentrum',
        type: RoadType.localStreet,
        geoPoints: [toPx(49.980, 7.518), toPx(49.990, 7.540)],
      ),
      MapRoad(
        name: 'Boppard Rheinufer',
        type: RoadType.localStreet,
        geoPoints: [toPx(50.225, 7.580), toPx(50.235, 7.595)],
      ),
    ];

    // Paint in layers: Outlines first, then fills!
    // 1. Autobahn Layer
    final autobahnOutline = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 7.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final autobahnFill = Paint()
      ..color = const Color(0xFFFEF3C7)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 2. Federal Road Layer (Bundesstraße)
    final federalOutline = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final federalFill = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 3. Local Street Layer
    final localPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final r in roads) {
      if (r.geoPoints.length < 2) continue;
      final path = Path()..moveTo(r.geoPoints.first.dx, r.geoPoints.first.dy);
      for (int i = 1; i < r.geoPoints.length; i++) {
        path.lineTo(r.geoPoints[i].dx, r.geoPoints[i].dy);
      }

      if (r.type == RoadType.autobahn) {
        canvas.drawPath(path, autobahnOutline);
        canvas.drawPath(path, autobahnFill);
      } else if (r.type == RoadType.federal) {
        canvas.drawPath(path, federalOutline);
        canvas.drawPath(path, federalFill);
      } else {
        canvas.drawPath(path, localPaint);
      }
    }

    // Optional road names rendering
    if (showRoadNames) {
      for (final r in roads) {
        if (r.name != null && r.geoPoints.length >= 2) {
          final mid = r.geoPoints[r.geoPoints.length ~/ 2];
          _drawLabel(canvas, r.name!, mid, 9.5, const Color(0xFF334155), true);
        }
      }
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, double fontSize, Color color, bool isBold) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: isBold ? 1.4 : 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
