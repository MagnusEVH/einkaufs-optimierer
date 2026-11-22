// app/lib/features/stores_map/stores_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/store.dart';
import '../../core/services/location_service.dart';
import '../../core/config/app_config.dart';
import '../optimizer/optimizer_screen.dart';
import 'data/rlp_stores.dart';
import 'map_tile_style.dart';
import 'store_filters.dart';
import 'widgets/district_filter_bar.dart';
import 'widgets/selected_store_sheet.dart';
import 'widgets/store_list_view.dart';
import 'widgets/store_markers.dart';

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

  // Selected Store for on-demand bottom sheet
  Store? _selectedStore;

  // Selected Tile Style: Voyager by default (Google Maps clean aesthetic)
  TileStyle _tileStyle = TileStyle.voyager;

  // Map Controller for smooth programmatic zooming and centering
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _location = loc;
        _isLoading = false;
        _selectedStore = null; // Clean start without initial overlay
      });
    }
  }

  List<Store> get _filteredStores => filterStores(
        rlpStores,
        district: _activeDistrict,
        chainFilter: _activeChainFilter,
      );

  void _onChainFilterSelected(String filter) {
    setState(() {
      _activeChainFilter = filter;
      _selectedStore = null;
    });
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
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  void _recenterOnUser() {
    final userLoc = _location ?? LocationService.bingenLocation;
    _mapController.move(LatLng(userLoc.latitude, userLoc.longitude), 14.0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zentriert auf deinen Standort 📍'),
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  void _onDistrictSelected(String district) {
    setState(() {
      _activeDistrict = district;
      _selectedStore = null;
    });

    if (district == 'Mainz-Bingen') {
      _mapController.move(const LatLng(49.965, 7.95), 12.0);
    } else if (district == 'Rhein-Hunsrück') {
      _mapController.move(const LatLng(50.08, 7.60), 11.0);
    } else {
      _mapController.move(const LatLng(50.02, 7.78), 10.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLoc = _location ?? LocationService.bingenLocation;
    final filtered = _filteredStores;

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
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tileStyleLabel(_tileStyle),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
            Text(
              '${filtered.length} Filialen • Echte Straßenkarten',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          // Kartenstil-Wähler (Voyager, OpenStreetMap, Satellit)
          PopupMenuButton<TileStyle>(
            icon: const Icon(Icons.layers_outlined, color: Color(0xFF334155)),
            tooltip: 'Kartenansicht wechseln',
            onSelected: (style) => setState(() => _tileStyle = style),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: TileStyle.voyager,
                child: Row(
                  children: [
                    Icon(Icons.map_rounded, size: 18, color: Color(0xFF059669)),
                    SizedBox(width: 10),
                    Text('CartoDB Voyager (Empfohlen)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TileStyle.openStreetMap,
                child: Row(
                  children: [
                    Icon(Icons.streetview_rounded,
                        size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 10),
                    Text('OpenStreetMap Classic'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TileStyle.satellite,
                child: Row(
                  children: [
                    Icon(Icons.satellite_alt_rounded,
                        size: 18, color: Color(0xFFD97706)),
                    SizedBox(width: 10),
                    Text('Satellit / Luftbild'),
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
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF059669)))
          : Stack(
              children: [
                Column(
                  children: [
                    // Top District & Chain Filter Chips Bar
                    DistrictFilterBar(
                      activeDistrict: _activeDistrict,
                      activeChainFilter: _activeChainFilter,
                      allStores: rlpStores,
                      onDistrictSelected: _onDistrictSelected,
                      onChainFilterSelected: _onChainFilterSelected,
                    ),

                    // Main Content: Echte hochauflösende Kachel-Karte
                    Expanded(
                      child: _isMapView
                          ? _buildRealTileMapView(userLoc, filtered)
                          : StoreListView(
                              stores: filtered,
                              selectedStoreId: _selectedStore?.id,
                              onPlanFromStore: _planFromStore,
                            ),
                    ),
                  ],
                ),

                // Floating Store Action Card when a store is tapped by user
                if (_selectedStore != null && _isMapView)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SelectedStoreSheet(
                      store: _selectedStore!,
                      onClose: () => setState(() => _selectedStore = null),
                      onPlanFromStore: _planFromStore,
                    ),
                  ),
              ],
            ),
    );
  }

  /// Real Tile Map View powered by flutter_map and CartoDB/OpenStreetMap
  Widget _buildRealTileMapView(UserLocation userLoc, List<Store> stores) {
    final userPos = LatLng(userLoc.latitude, userLoc.longitude);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userPos,
            initialZoom: 13.0,
            minZoom: 7.0,
            maxZoom: 18.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // Echte Kartenkacheln (CartoDB Voyager / OpenStreetMap / Satellite)
            TileLayer(
              urlTemplate: tileUrlFor(_tileStyle),
              fallbackUrl: _tileStyle == TileStyle.voyager
                  ? AppConfig.openStreetMapUrl
                  : null,
              userAgentPackageName: 'de.einkaufsoptimierer.app',
              maxZoom: 19,
            ),

            // User Location Marker
            MarkerLayer(
              markers: [
                Marker(
                  point: userPos,
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: const UserLocationMarker(),
                ),
                ...buildStoreMarkers(
                  stores: stores,
                  selectedStoreId: _selectedStore?.id,
                  onStoreTap: (store) => setState(() => _selectedStore = store),
                ),
              ],
            ),
          ],
        ),

        // Floating Zoom and Navigation Controls (Right Edge)
        Positioned(
          right: 14,
          bottom: _selectedStore != null ? 220 : 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'map_zoom_in_tile',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 3,
                tooltip: 'Heranzoomen',
                onPressed: _zoomIn,
                child: const Icon(Icons.add_rounded, size: 20),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'map_zoom_out_tile',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 3,
                tooltip: 'Herauszoomen',
                onPressed: _zoomOut,
                child: const Icon(Icons.remove_rounded, size: 20),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'map_recenter_tile',
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 4,
                tooltip: 'Mein Standort zentrieren',
                onPressed: _recenterOnUser,
                child: const Icon(Icons.my_location_rounded, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
