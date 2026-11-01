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
  String _activeFilter = 'Alle';
  Store? _selectedStore;

  // Map engine selection: defaults to the vector map, with Google Maps ready to be enabled
  MapProvider _mapProvider = MapProvider.vectorInteractive;

  // Controller for pan & zoom gestures
  final TransformationController _transformationController = TransformationController();

  // Stores in Bingen am Rhein (55411) and Oberwesel (55430)
  final List<Store> _allStores = const [
    Store(
      id: 'b-1',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Bingen-Büdesheim',
      address: 'Saarlandstraße 165, 55411 Bingen am Rhein',
      latitude: 49.9545,
      longitude: 7.9172,
      clusterNum: 10,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      distanceMeters: 80,
    ),
    Store(
      id: 'b-2',
      chain: SupermarketChain.lidl,
      name: 'Lidl Filiale Bingen-Büdesheim',
      address: 'Saarlandstraße 171, 55411 Bingen am Rhein',
      latitude: 49.9542,
      longitude: 7.9160,
      clusterNum: 10,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      distanceMeters: 120,
    ),
    Store(
      id: 'b-3',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Bingen',
      address: 'Mainzer Straße 44, 55411 Bingen am Rhein',
      latitude: 49.9658,
      longitude: 7.9045,
      clusterNum: 11,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      distanceMeters: 950,
    ),
    Store(
      id: 'b-4',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Bingen',
      address: 'Vorstadt 10-12, 55411 Bingen am Rhein',
      latitude: 49.9662,
      longitude: 7.8965,
      clusterNum: 12,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      distanceMeters: 1400,
    ),
    Store(
      id: 'b-5',
      chain: SupermarketChain.rossmann,
      name: 'Rossmann Drogeriemarkt Bingen',
      address: 'Basilikastraße 3, 55411 Bingen am Rhein',
      latitude: 49.9670,
      longitude: 7.8940,
      clusterNum: 12,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      distanceMeters: 1450,
    ),
    Store(
      id: 'o-1',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount Oberwesel',
      address: 'Chrishausener Str. 2, 55430 Oberwesel',
      latitude: 50.1082,
      longitude: 7.7285,
      clusterNum: 20,
      postalCode: '55430',
      city: 'Oberwesel',
      distanceMeters: 350,
    ),
    Store(
      id: 'o-2',
      chain: SupermarketChain.rewe,
      name: 'REWE City Oberwesel',
      address: 'Koblenzer Str. 18, 55430 Oberwesel',
      latitude: 50.1105,
      longitude: 7.7260,
      clusterNum: 20,
      postalCode: '55430',
      city: 'Oberwesel',
      distanceMeters: 550,
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
    }
  }

  List<Store> get _filteredStores {
    return _allStores.where((s) {
      if (_activeFilter == 'Discounter') {
        return s.chain == SupermarketChain.aldi_sued ||
            s.chain == SupermarketChain.lidl ||
            s.chain == SupermarketChain.netto;
      }
      if (_activeFilter == 'Supermarkt') {
        return s.chain == SupermarketChain.rewe;
      }
      if (_activeFilter == 'Drogerie') {
        return s.chain == SupermarketChain.dm || s.chain == SupermarketChain.rossmann;
      }
      if (_activeFilter == 'Cluster (<500m)') {
        return s.clusterNum == 10 || s.clusterNum == 12 || s.clusterNum == 20;
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
    matrix.scaleByDouble(1.25, 1.25, 1.0, 1.0);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    matrix.scaleByDouble(0.8, 0.8, 1.0, 1.0);
    _transformationController.value = matrix;
  }

  void _recenterMap() {
    _transformationController.value = Matrix4.identity();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Karte auf deinen Standort zentriert 📍'),
        duration: Duration(milliseconds: 1200),
      ),
    );
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
                    _mapProvider == MapProvider.vectorInteractive ? 'Live-Vektor' : 'Google Maps',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
            Text(
              'Bingen & Oberwesel • ${_filteredStores.length} Lebensmittelmärkte',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          // Engine Switcher (Vector vs Google Maps)
          PopupMenuButton<MapProvider>(
            icon: const Icon(Icons.layers_outlined, color: Color(0xFF334155)),
            tooltip: 'Karten-Engine wählen',
            onSelected: (prov) => setState(() => _mapProvider = prov),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: MapProvider.vectorInteractive,
                child: Row(
                  children: [
                    Icon(Icons.brush_rounded, size: 18, color: Color(0xFF059669)),
                    SizedBox(width: 10),
                    Text('Interaktive Vektor-Karte (Offline)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: MapProvider.googleMapsNative,
                child: Row(
                  children: [
                    Icon(Icons.public_rounded, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 10),
                    Text('Google Maps (Native Vorbereitung)'),
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
                // Filter Bar
                _buildFilterChips(),

                // Map Canvas or List View
                Expanded(
                  child: _isMapView
                      ? (_mapProvider == MapProvider.vectorInteractive
                          ? _buildInteractiveVectorMapView(userLoc)
                          : _buildGoogleMapsPlaceholderView())
                      : _buildStoreListView(theme),
                ),

                // Selected Store Action Card / Bottom Sheet
                if (_selectedStore != null) _buildSelectedStoreSheet(theme),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Alle', 'Discounter', 'Supermarkt', 'Drogerie', 'Cluster (<500m)'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _activeFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(
                  f,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
                backgroundColor: const Color(0xFFF1F5F9),
                selectedColor: const Color(0xFF059669),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF059669) : Colors.transparent,
                ),
                onSelected: (val) {
                  setState(() => _activeFilter = f);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Full Interactive Vector Map with Panning, Pinch-to-Zoom and Store Pins
  Widget _buildInteractiveVectorMapView(UserLocation userLoc) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = math.max(constraints.maxWidth, 700.0);
        final canvasHeight = math.max(constraints.maxHeight, 700.0);

        return Stack(
          children: [
            // Gesture-enabled Interactive Canvas (Pan & Zoom)
            InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.7,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(300),
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: canvasWidth,
                height: canvasHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Base Map Painter: Rhine River, B9 Highway, Streets, City Districts
                    CustomPaint(
                      size: Size(canvasWidth, canvasHeight),
                      painter: _GoogleMapsStyleVectorPainter(),
                    ),

                    // User Location Marker (Blue Pulsing Target)
                    _buildUserLocationMarker(canvasWidth, canvasHeight),

                    // Store Map Pins
                    ..._buildStorePins(canvasWidth, canvasHeight),
                  ],
                ),
              ),
            ),

            // Top Status Badge: Stores Only Notice
            Positioned(
              top: 12,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Color(0xFF059669), size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Ausschließlich Supermärkte & Drogerien im Fokus',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      ),
                    ),
                    Text(
                      '${_filteredStores.length} Filialen',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Controls: Zoom In / Out & Recenter GPS
            Positioned(
              right: 14,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'map_zoom_in',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 3,
                    tooltip: 'Heranzoomen',
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add_rounded, size: 20),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'map_zoom_out',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 3,
                    tooltip: 'Herauszoomen',
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove_rounded, size: 20),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'map_recenter',
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    tooltip: 'Mein Standort zentrieren',
                    onPressed: _recenterMap,
                    child: const Icon(Icons.my_location_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Placeholder/Slot for native Google Maps when API keys & SDK are active
  Widget _buildGoogleMapsPlaceholderView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map_rounded, color: Color(0xFF2563EB), size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Google Maps Modus vorbereitet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              'Die native Google Maps Schnittstelle ist im Projekt vorbereitet. Sobald der API-Key in deiner Konfiguration hinterlegt ist, schaltet dieser Tab nahtlos auf die Satelliten- und Straßenkarten um.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.brush_rounded, size: 18),
              label: const Text('Zurück zur Live-Vektor-Karte'),
              onPressed: () {
                setState(() => _mapProvider = MapProvider.vectorInteractive);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserLocationMarker(double canvasWidth, double canvasHeight) {
    final cx = canvasWidth / 2;
    final cy = canvasHeight / 2 - 10;

    return Positioned(
      left: cx - 55,
      top: cy - 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(10),
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
                Icon(Icons.person_pin, color: Colors.white, size: 13),
                SizedBox(width: 4),
                Text(
                  'Mein Standort',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2563EB),
                  border: Border.all(color: Colors.white, width: 3),
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

  List<Widget> _buildStorePins(double canvasWidth, double canvasHeight) {
    final cx = canvasWidth / 2;
    final cy = canvasHeight / 2 - 10;

    // Offsets positioned in realistic layout across Bingen & Oberwesel
    final pinOffsets = {
      'b-1': Offset(cx - 100, cy - 90), // ALDI SÜD Bingen Büdesheim
      'b-2': Offset(cx - 20, cy - 95),  // Lidl Bingen Büdesheim (Cluster 10 with ALDI)
      'b-3': Offset(cx + 95, cy - 35),  // REWE Markt Bingen Mainzer Str.
      'b-4': Offset(cx - 120, cy + 55), // dm Bingen Vorstadt
      'b-5': Offset(cx - 45, cy + 75),  // Rossmann Bingen Basilikastr. (Cluster 12 with dm)
      'o-1': Offset(cx + 115, cy + 95), // Netto Oberwesel
      'o-2': Offset(cx + 60, cy + 145), // REWE City Oberwesel (Cluster 20 with Netto)
    };

    return _filteredStores.map((store) {
      final offset = pinOffsets[store.id] ?? Offset(cx, cy);
      final isSelected = _selectedStore?.id == store.id;
      final chainColor = _getChainColor(store.chain);
      final badge = _getChainBadge(store.chain);

      return Positioned(
        left: offset.dx - 45,
        top: offset.dy - 45,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _selectedStore = store;
            });
          },
          child: AnimatedScale(
            scale: isSelected ? 1.18 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Tag Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.35 : 0.15),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 2),
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
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: chainColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${store.distanceMeters?.toInt()} m',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),

                // Distinct Pin Shape
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isSelected ? 46 : 38,
                      color: chainColor,
                    ),
                    Positioned(
                      top: isSelected ? 8 : 6,
                      child: Container(
                        width: isSelected ? 18 : 15,
                        height: isSelected ? 18 : 15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          store.chain == SupermarketChain.dm || store.chain == SupermarketChain.rossmann
                              ? Icons.sanitizer_outlined
                              : Icons.shopping_basket_rounded,
                          size: isSelected ? 11 : 9,
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
    final distanceMeters = store.distanceMeters?.toInt() ?? 100;
    final walkMinutes = (distanceMeters / 75).ceil();
    final driveMinutes = math.max(1, (distanceMeters / 400).ceil());

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: chainColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: chainColor.withValues(alpha: 0.25)),
                ),
                child: Icon(
                  store.chain == SupermarketChain.dm || store.chain == SupermarketChain.rossmann
                      ? Icons.clean_hands_rounded
                      : Icons.storefront_rounded,
                  color: chainColor,
                  size: 26,
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
              // Cluster Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Cluster ${store.clusterNum}',
                  style: const TextStyle(color: Color(0xFF065F46), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Travel Times & Details
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
                    const Icon(Icons.directions_walk_rounded, size: 15, color: Color(0xFF475569)),
                    const SizedBox(width: 4),
                    Text(
                      '~$walkMinutes Min. zu Fuß',
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
                    const Icon(Icons.directions_car_rounded, size: 15, color: Color(0xFF475569)),
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
                '$distanceMeters m Distanz',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _filteredStores.length,
      itemBuilder: (ctx, index) {
        final store = _filteredStores[index];
        final chainColor = _getChainColor(store.chain);
        final isSelected = _selectedStore?.id == store.id;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? const Color(0xFF059669) : Colors.black.withValues(alpha: 0.08),
              width: isSelected ? 2 : 1,
            ),
          ),
          color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: chainColor.withValues(alpha: 0.15),
                  child: Icon(
                    store.chain == SupermarketChain.dm || store.chain == SupermarketChain.rossmann
                        ? Icons.sanitizer_outlined
                        : Icons.storefront_rounded,
                    color: chainColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        store.address,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.directions_walk, size: 14, color: Colors.grey.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${store.distanceMeters?.toInt()} m',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Cluster ${store.clusterNum}',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                            ),
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
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  onPressed: () => _planFromStore(store),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Google Maps styled Vector Painter (Water, B9 Highway, Roads, Green Parks)
class _GoogleMapsStyleVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background Land (Soft Google Maps Beige/Gray)
    final bgPaint = Paint()..color = const Color(0xFFF1EFE9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Green Parks & Vineyards (Binger Wald & Rheingau)
    final parkPaint = Paint()..color = const Color(0xFFDCEAD7);
    final parkPath1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.15, size.height * 0.25)
      ..lineTo(0, size.height * 0.30)
      ..close();
    canvas.drawPath(parkPath1, parkPaint);

    final parkPath2 = Path()
      ..moveTo(size.width * 0.70, size.height * 0.65)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.65, size.height)
      ..close();
    canvas.drawPath(parkPath2, parkPaint);

    // 3. Water body: River Rhine (Light Blue with smooth Google Maps styling)
    final riverPaint = Paint()
      ..color = const Color(0xFFA5D7FE)
      ..strokeWidth = 48
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(0, size.height * 0.15)
      ..cubicTo(
        size.width * 0.35, size.height * 0.35,
        size.width * 0.65, size.height * 0.72,
        size.width, size.height * 0.90,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Nahe River estuary joining the Rhine
    final nahePaint = Paint()
      ..color = const Color(0xFFA5D7FE)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;
    final nahePath = Path()
      ..moveTo(size.width * 0.25, size.height)
      ..cubicTo(
        size.width * 0.28, size.height * 0.75,
        size.width * 0.35, size.height * 0.50,
        size.width * 0.42, size.height * 0.42,
      );
    canvas.drawPath(nahePath, nahePaint);

    // 4. Secondary Streets (White with subtle shadow)
    final secRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.1, 0),
      Offset(size.width * 0.55, size.height),
      secRoadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.65),
      Offset(size.width, size.height * 0.45),
      secRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.3),
      secRoadPaint,
    );

    // 5. Major Highway B9 (Golden Yellow with outline)
    final b9OutlinePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 11
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final b9FillPaint = Paint()
      ..color = const Color(0xFFFEF3C7)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final b9Path = Path()
      ..moveTo(0, size.height * 0.23)
      ..cubicTo(
        size.width * 0.33, size.height * 0.42,
        size.width * 0.62, size.height * 0.78,
        size.width, size.height * 0.96,
      );
    canvas.drawPath(b9Path, b9OutlinePaint);
    canvas.drawPath(b9Path, b9FillPaint);

    // 6. Geographic Water & District Labels
    const textStyle = TextStyle(
      color: Color(0xFF1E3A8A),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );
    final textPainter = TextPainter(
      text: const TextSpan(text: '~ RHEIN ~', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.52, size.height * 0.58));

    const districtStyle = TextStyle(
      color: Color(0xFF64748B),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    final dPainter = TextPainter(
      text: const TextSpan(text: 'Bingen am Rhein', style: districtStyle),
      textDirection: TextDirection.ltr,
    );
    dPainter.layout();
    dPainter.paint(canvas, Offset(size.width * 0.25, size.height * 0.30));

    final d2Painter = TextPainter(
      text: const TextSpan(text: 'Büdesheim', style: districtStyle),
      textDirection: TextDirection.ltr,
    );
    d2Painter.layout();
    d2Painter.paint(canvas, Offset(size.width * 0.12, size.height * 0.52));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
