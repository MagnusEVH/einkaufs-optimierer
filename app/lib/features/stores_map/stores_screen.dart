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
  Store? _selectedStore;

  // Map engine selection
  MapProvider _mapProvider = MapProvider.vectorInteractive;

  // InteractiveViewer Transformation Controller
  final TransformationController _transformationController = TransformationController();

  // Geographic Bounding Box for Mainz-Bingen & Rhein-Hunsrück-Kreis
  static const double minLat = 49.85;
  static const double maxLat = 50.28;
  static const double minLng = 7.35;
  static const double maxLng = 8.22;

  // Virtual Canvas Dimension for realistic scaling
  static const double virtualCanvasWidth = 1600.0;
  static const double virtualCanvasHeight = 1300.0;

  // Complete preloaded dataset for both Landkreise (30 real stores)
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
        _selectedStore = _allStores.first;
      });
      // Initial viewpoint centered around Bingen / Middle Rhine
      _focusOnLocation(49.96, 7.91, 1.1);
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

  void _focusOnLocation(double lat, double lng, [double zoom = 1.2]) {
    final target = projectGpsToCanvas(lat, lng, const Size(virtualCanvasWidth, virtualCanvasHeight));
    // Center viewport on target
    final tx = -target.dx * zoom + 180;
    final ty = -target.dy * zoom + 260;
    final matrix = Matrix4.identity()
      ..translateByDouble(tx, ty, 0.0, 1.0)
      ..multiply(Matrix4.diagonal3Values(zoom, zoom, 1.0));
    _transformationController.value = matrix;
  }

  void _onDistrictSelected(String district) {
    setState(() {
      _activeDistrict = district;
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
              '${_filteredStores.length} Filialen vorgeladen • Echtzeit-GPS',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
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
          : Column(
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

                // Selected Store Action Card
                if (_selectedStore != null) _buildSelectedStoreSheet(theme),
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
          setState(() => _activeChainFilter = filterName);
        },
      ),
    );
  }

  /// Full Interactive Vector Map with Natural Scale
  Widget _buildInteractiveVectorMapView(UserLocation userLoc) {
    const canvasSize = Size(virtualCanvasWidth, virtualCanvasHeight);

    return Stack(
      children: [
        // Gesture-enabled Interactive Canvas (Pan & Pinch-to-Zoom on iPhone)
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 3.5,
          boundaryMargin: const EdgeInsets.all(500),
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Base Vector Map: Rhine River, B9 & A61 Highway, Boundaries, Landkreise
                const CustomPaint(
                  size: canvasSize,
                  painter: _RegionalVectorMapPainter(canvasSize),
                ),

                // GPS User Location Marker
                _buildUserLocationMarker(userLoc, canvasSize),

                // Store Map Pins positioned with exact GPS projection
                ..._buildProjectedStorePins(canvasSize),
              ],
            ),
          ),
        ),

        // District Legend Overlay (Top Left)
        Positioned(
          top: 10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map_outlined, color: Color(0xFF059669), size: 14),
                const SizedBox(width: 6),
                Text(
                  'Fokus: Mainz-Bingen & Rhein-Hunsrück (${_filteredStores.length} Märkte)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ),

        // Floating Zoom and Navigation Controls (Right Edge)
        Positioned(
          right: 14,
          bottom: 16,
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
        left: pos.dx - 35,
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

  /// Modern Bottom Action Card for the selected Store
  Widget _buildSelectedStoreSheet(ThemeData theme) {
    final store = _selectedStore!;
    final chainColor = _getChainColor(store.chain);
    final distanceMeters = store.distanceMeters?.toInt() ?? 250;
    final walkMinutes = (distanceMeters / 75).ceil();
    final driveMinutes = math.max(1, (distanceMeters / 400).ceil());

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  store.district ?? 'RLP',
                  style: const TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Details row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_walk_rounded, size: 14, color: Color(0xFF475569)),
                    const SizedBox(width: 4),
                    Text(
                      '~$walkMinutes Min. Fuß',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_rounded, size: 14, color: Color(0xFF475569)),
                    const SizedBox(width: 4),
                    Text(
                      '~$driveMinutes Min. Auto',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Cluster ${store.clusterNum ?? '-'}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Primary Action Button: "Von diesem Laden ausplanen"
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.alt_route_rounded, size: 18),
              label: const Text(
                'Von diesem Laden ausplanen 🚀',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                            store.district ?? '',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                          const SizedBox(width: 8),
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

/// Regional Vector Painter drawing Rhine River, B9, A61 Highway and District Boundaries
class _RegionalVectorMapPainter extends CustomPainter {
  final Size canvasSize;
  const _RegionalVectorMapPainter(this.canvasSize);

  Offset toPx(double lat, double lng) {
    return _StoresScreenState.projectGpsToCanvas(lat, lng, canvasSize);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Terrain Background
    final bgPaint = Paint()..color = const Color(0xFFF1EFE9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Forests & Natural Parks (Soonwald / Hunsrück & Rheingau)
    final hunsrueckForest = Paint()..color = const Color(0xFFDCEAD7);
    final forestPath = Path()
      ..moveTo(toPx(50.15, 7.38).dx, toPx(50.15, 7.38).dy)
      ..lineTo(toPx(50.25, 7.50).dx, toPx(50.25, 7.50).dy)
      ..lineTo(toPx(50.05, 7.65).dx, toPx(50.05, 7.65).dy)
      ..lineTo(toPx(49.90, 7.55).dx, toPx(49.90, 7.55).dy)
      ..lineTo(toPx(49.92, 7.40).dx, toPx(49.92, 7.40).dy)
      ..close();
    canvas.drawPath(forestPath, hunsrueckForest);

    // 3. District Border Line (Dashed soft line between Rhein-Hunsrück & Mainz-Bingen)
    final borderPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final bPath = Path()
      ..moveTo(toPx(50.18, 7.72).dx, toPx(50.18, 7.72).dy)
      ..lineTo(toPx(50.08, 7.74).dx, toPx(50.08, 7.74).dy)
      ..lineTo(toPx(49.98, 7.78).dx, toPx(49.98, 7.78).dy)
      ..lineTo(toPx(49.88, 7.82).dx, toPx(49.88, 7.82).dy);
    canvas.drawPath(bPath, borderPaint);

    // 4. River Rhine (Rhein): Flows from Ingelheim -> Bingen -> Oberwesel -> St. Goar -> Boppard
    final riverPaint = Paint()
      ..color = const Color(0xFFA5D7FE)
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pIngelheim = toPx(49.98, 8.08);
    final pBingenKnie = toPx(49.97, 7.90);
    final pBacharach = toPx(50.06, 7.77);
    final pOberwesel = toPx(50.11, 7.73);
    final pStGoar = toPx(50.15, 7.71);
    final pBoppard = toPx(50.23, 7.59);

    final riverPath = Path()
      ..moveTo(pIngelheim.dx, pIngelheim.dy)
      ..lineTo(pBingenKnie.dx, pBingenKnie.dy)
      ..cubicTo(pBingenKnie.dx, pBingenKnie.dy, pBacharach.dx, pBacharach.dy, pOberwesel.dx, pOberwesel.dy)
      ..lineTo(pStGoar.dx, pStGoar.dy)
      ..cubicTo(pStGoar.dx, pStGoar.dy, toPx(50.20, 7.62).dx, toPx(50.20, 7.62).dy, pBoppard.dx, pBoppard.dy);
    canvas.drawPath(riverPath, riverPaint);

    // River Nahe joining Rhine at Bingen
    final nahePaint = Paint()
      ..color = const Color(0xFFA5D7FE)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    final nahePath = Path()
      ..moveTo(toPx(49.86, 7.93).dx, toPx(49.86, 7.93).dy)
      ..lineTo(toPx(49.93, 7.92).dx, toPx(49.93, 7.92).dy)
      ..lineTo(pBingenKnie.dx, pBingenKnie.dy);
    canvas.drawPath(nahePath, nahePaint);

    // 5. Autobahn A61 (Orange Highway with White center)
    final a61Outline = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    final a61Path = Path()
      ..moveTo(toPx(49.86, 7.96).dx, toPx(49.86, 7.96).dy)
      ..lineTo(toPx(49.96, 7.86).dx, toPx(49.96, 7.86).dy)
      ..lineTo(toPx(50.05, 7.68).dx, toPx(50.05, 7.68).dy)
      ..lineTo(toPx(50.16, 7.62).dx, toPx(50.16, 7.62).dy)
      ..lineTo(toPx(50.24, 7.51).dx, toPx(50.24, 7.51).dy);
    canvas.drawPath(a61Path, a61Outline);

    // Bundesstraße B50 (Simmern to Rheinböllen/A61)
    final b50Paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      toPx(49.98, 7.53),
      toPx(50.01, 7.67),
      b50Paint,
    );

    // 6. Geographic Region Labels
    _drawLabel(canvas, 'RHEIN-HUNSRÜCK-KREIS', toPx(50.10, 7.48), 13, const Color(0xFF475569), true);
    _drawLabel(canvas, 'LANDKREIS MAINZ-BINGEN', toPx(49.92, 8.04), 13, const Color(0xFF475569), true);

    // City Labels
    _drawLabel(canvas, 'Bingen am Rhein', toPx(49.97, 7.88), 11, const Color(0xFF0F172A), false);
    _drawLabel(canvas, 'Ingelheim am Rhein', toPx(49.98, 8.04), 11, const Color(0xFF0F172A), false);
    _drawLabel(canvas, 'Oberwesel', toPx(50.11, 7.74), 10, const Color(0xFF0F172A), false);
    _drawLabel(canvas, 'Boppard', toPx(50.24, 7.59), 11, const Color(0xFF0F172A), false);
    _drawLabel(canvas, 'Simmern (Hunsrück)', toPx(49.99, 7.53), 11, const Color(0xFF0F172A), false);
    _drawLabel(canvas, 'Emmelshausen', toPx(50.16, 7.65), 10, const Color(0xFF0F172A), false);
    _drawLabel(canvas, '~ RHEIN ~', toPx(50.04, 7.79), 10, const Color(0xFF1E3A8A), true);
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
