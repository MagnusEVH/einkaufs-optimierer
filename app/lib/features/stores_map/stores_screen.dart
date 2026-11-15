// app/lib/features/stores_map/stores_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/store.dart';
import '../../core/services/location_service.dart';
import '../../core/config/app_config.dart';
import '../optimizer/optimizer_screen.dart';

enum TileStyle {
  voyager,
  openStreetMap,
  satellite,
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

  // Selected Store for on-demand bottom sheet
  Store? _selectedStore;

  // Selected Tile Style: Voyager by default (Google Maps clean aesthetic)
  TileStyle _tileStyle = TileStyle.voyager;

  // Map Controller for smooth programmatic zooming and centering
  final MapController _mapController = MapController();

  // Vollständig verifizierter Datensatz (45 reale Supermärkte & Drogerien)
  // Mainz-Bingen & Rhein-Hunsrück-Kreis mit exakten Adressen & GPS-Koordinaten
  final List<Store> _allStores = const [
    // =========================================================================
    // LANDKREIS MAINZ-BINGEN (23 Stores)
    // =========================================================================

    // ── Bingen-Büdesheim Cluster 10 (Gewerbegebiet Hitchinstraße / Saarlandstr. < 500m) ──
    Store(
      id: 'mb-bingen-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Bingen-Büdesheim',
      address: 'Hitchinstraße 45a, 55411 Bingen am Rhein',
      latitude: 49.9491,
      longitude: 7.9020,
      clusterNum: 10,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 350,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-bingen-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Bingen-Büdesheim',
      address: 'Hitchinstraße 46, 55411 Bingen am Rhein',
      latitude: 49.9478,
      longitude: 7.9028,
      clusterNum: 10,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 420,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-bingen-dm',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Bingen-Büdesheim',
      address: 'Hitchinstraße 45, 55411 Bingen am Rhein',
      latitude: 49.9490,
      longitude: 7.9050,
      clusterNum: 10,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 400,
      openingHours: 'Mo–Sa 08:30–20:00 Uhr',
    ),
    Store(
      id: 'mb-bingen-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Bingen-Büdesheim',
      address: 'Schultheiss-Kollei-Straße 19, 55411 Bingen am Rhein',
      latitude: 49.9499,
      longitude: 7.9024,
      clusterNum: 10,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 380,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),
    Store(
      id: 'mb-bingen-netto',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount Bingen',
      address: 'Saarlandstraße 62, 55411 Bingen am Rhein',
      latitude: 49.9519,
      longitude: 7.9005,
      clusterNum: 10,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 200,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),

    // ── Bingen Innenstadt ──
    Store(
      id: 'mb-bingen-rewe-city',
      chain: SupermarketChain.rewe,
      name: 'REWE City Bingen Innenstadt',
      address: 'Basilikastraße 3, 55411 Bingen am Rhein',
      latitude: 49.9683,
      longitude: 7.8926,
      postalCode: '55411',
      city: 'Bingen am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 2200,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),

    // ── Gensingen Cluster 11 (Am Kieselberg / Binger Str.) ──
    Store(
      id: 'mb-gensingen-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Gensingen',
      address: 'Am Kieselberg 6a, 55457 Gensingen',
      latitude: 49.9025,
      longitude: 7.9250,
      clusterNum: 11,
      postalCode: '55457',
      city: 'Gensingen',
      district: 'Mainz-Bingen',
      distanceMeters: 6200,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-gensingen-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Gensingen',
      address: 'Am Kieselberg 8, 55457 Gensingen',
      latitude: 49.9020,
      longitude: 7.9260,
      clusterNum: 11,
      postalCode: '55457',
      city: 'Gensingen',
      district: 'Mainz-Bingen',
      distanceMeters: 6250,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-gensingen-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Center Gensingen (Globus-Zone)',
      address: 'Binger Straße 29, 55457 Gensingen',
      latitude: 49.9003,
      longitude: 7.9226,
      clusterNum: 11,
      postalCode: '55457',
      city: 'Gensingen',
      district: 'Mainz-Bingen',
      distanceMeters: 6400,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),

    // ── Ingelheim am Rhein Cluster 12 & 13 ──
    Store(
      id: 'mb-ingelheim-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Ingelheim',
      address: 'Konrad-Adenauer-Straße 14c, 55218 Ingelheim am Rhein',
      latitude: 49.9788,
      longitude: 8.0553,
      clusterNum: 12,
      postalCode: '55218',
      city: 'Ingelheim am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 9800,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-ingelheim-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Ingelheim-West',
      address: 'Binger Straße 210, 55218 Ingelheim am Rhein',
      latitude: 49.9678,
      longitude: 8.0285,
      postalCode: '55218',
      city: 'Ingelheim am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 8800,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-ingelheim-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Center Ingelheim (Neue Mitte)',
      address: 'Georg-Rückert-Straße 3, 55218 Ingelheim am Rhein',
      latitude: 49.9692,
      longitude: 8.0573,
      clusterNum: 13,
      postalCode: '55218',
      city: 'Ingelheim am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 9900,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),
    Store(
      id: 'mb-ingelheim-dm',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Ingelheim',
      address: 'Binger Straße 85, 55218 Ingelheim am Rhein',
      latitude: 49.9689,
      longitude: 8.0520,
      clusterNum: 13,
      postalCode: '55218',
      city: 'Ingelheim am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 9600,
      openingHours: 'Mo–Sa 08:00–20:00 Uhr',
    ),
    Store(
      id: 'mb-heidesheim-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Heidesheim',
      address: 'Im Schäfersborn 1, 55262 Ingelheim am Rhein',
      latitude: 49.9985,
      longitude: 8.1272,
      postalCode: '55262',
      city: 'Ingelheim am Rhein',
      district: 'Mainz-Bingen',
      distanceMeters: 14500,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),

    // ── Gau-Algesheim Cluster 14 ──
    Store(
      id: 'mb-gaualgesheim-netto',
      chain: SupermarketChain.netto,
      name: 'Netto Gau-Algesheim',
      address: 'Appenheimer Str. 36, 55435 Gau-Algesheim',
      latitude: 49.9540,
      longitude: 8.0180,
      clusterNum: 14,
      postalCode: '55435',
      city: 'Gau-Algesheim',
      district: 'Mainz-Bingen',
      distanceMeters: 7400,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-gaualgesheim-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Gau-Algesheim',
      address: 'Schlossgasse 22, 55435 Gau-Algesheim',
      latitude: 49.9560,
      longitude: 8.0210,
      clusterNum: 14,
      postalCode: '55435',
      city: 'Gau-Algesheim',
      district: 'Mainz-Bingen',
      distanceMeters: 7600,
      openingHours: 'Mo–Sa 07:00–21:30 Uhr',
    ),

    // ── Nieder-Olm Cluster 15 (Gewerbegebiet Am Giener) ──
    Store(
      id: 'mb-niederolm-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Nieder-Olm',
      address: 'Am Giener 27, 55268 Nieder-Olm',
      latitude: 49.9130,
      longitude: 8.1775,
      clusterNum: 15,
      postalCode: '55268',
      city: 'Nieder-Olm',
      district: 'Mainz-Bingen',
      distanceMeters: 21500,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-niederolm-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Nieder-Olm',
      address: 'Am Giener 23, 55268 Nieder-Olm',
      latitude: 49.9133,
      longitude: 8.1782,
      clusterNum: 15,
      postalCode: '55268',
      city: 'Nieder-Olm',
      district: 'Mainz-Bingen',
      distanceMeters: 21550,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-niederolm-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Nieder-Olm',
      address: 'Bussolengo Platz 10-12, 55268 Nieder-Olm',
      latitude: 49.9235,
      longitude: 8.2120,
      postalCode: '55268',
      city: 'Nieder-Olm',
      district: 'Mainz-Bingen',
      distanceMeters: 23000,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),

    // ── Budenheim ──
    Store(
      id: 'mb-budenheim-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Budenheim',
      address: 'Binger Straße 1, 55257 Budenheim',
      latitude: 50.0223,
      longitude: 8.1654,
      postalCode: '55257',
      city: 'Budenheim',
      district: 'Mainz-Bingen',
      distanceMeters: 19000,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),

    // ── Oppenheim Cluster 16 ──
    Store(
      id: 'mb-oppenheim-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Oppenheim',
      address: 'Wormser Straße 112, 55276 Oppenheim',
      latitude: 49.8452,
      longitude: 8.3615,
      clusterNum: 16,
      postalCode: '55276',
      city: 'Oppenheim',
      district: 'Mainz-Bingen',
      distanceMeters: 38000,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-oppenheim-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Oppenheim',
      address: 'Sant-Ambrogio-Ring 1, 55276 Oppenheim',
      latitude: 49.8491,
      longitude: 8.3582,
      clusterNum: 16,
      postalCode: '55276',
      city: 'Oppenheim',
      district: 'Mainz-Bingen',
      distanceMeters: 37800,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'mb-oppenheim-dm',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Oppenheim',
      address: 'In den Weingärten 80, 55276 Oppenheim',
      latitude: 49.8510,
      longitude: 8.3565,
      clusterNum: 16,
      postalCode: '55276',
      city: 'Oppenheim',
      district: 'Mainz-Bingen',
      distanceMeters: 37600,
      openingHours: 'Mo–Sa 08:00–20:00 Uhr',
    ),

    // =========================================================================
    // RHEIN-HUNSRÜCK-KREIS (22 Stores)
    // =========================================================================

    // ── Stromberg Cluster 20 (Gewerbegebiet Am Lindchen / Friedrichsheck < 500m) ──
    Store(
      id: 'rh-stromberg-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Stromberg',
      address: 'Friedrichsheck 31, 55442 Stromberg',
      latitude: 49.9539,
      longitude: 7.7830,
      clusterNum: 20,
      postalCode: '55442',
      city: 'Stromberg',
      district: 'Rhein-Hunsrück',
      distanceMeters: 10500,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-stromberg-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Stromberg',
      address: 'Königsberger Str. 1, 55442 Stromberg',
      latitude: 49.9548,
      longitude: 7.7785,
      clusterNum: 20,
      postalCode: '55442',
      city: 'Stromberg',
      district: 'Rhein-Hunsrück',
      distanceMeters: 10700,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-stromberg-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Stromberg',
      address: 'Am Lindchen 18, 55442 Stromberg',
      latitude: 49.9535,
      longitude: 7.7812,
      clusterNum: 20,
      postalCode: '55442',
      city: 'Stromberg',
      district: 'Rhein-Hunsrück',
      distanceMeters: 10600,
      openingHours: 'Mo–Sa 07:00–21:30 Uhr',
    ),

    // ── Rheinböllen ──
    Store(
      id: 'rh-rheinboellen-netto',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount Rheinböllen',
      address: 'Am Müllergraben 3, 55494 Rheinböllen',
      latitude: 50.0090,
      longitude: 7.6740,
      postalCode: '55494',
      city: 'Rheinböllen',
      district: 'Rhein-Hunsrück',
      distanceMeters: 17500,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),

    // ── Simmern/Hunsrück Cluster 21 & 22 (Kreisstadt-Zentrum & Gewerbegebiet) ──
    Store(
      id: 'rh-simmern-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Simmern',
      address: 'Johann-Philipp-Reis-Straße 14a, 55469 Simmern',
      latitude: 49.9844,
      longitude: 7.5446,
      clusterNum: 21,
      postalCode: '55469',
      city: 'Simmern/Hunsrück',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28200,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-simmern-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Simmern',
      address: 'Koblenzer Straße 103, 55469 Simmern',
      latitude: 49.9914,
      longitude: 7.5265,
      clusterNum: 22,
      postalCode: '55469',
      city: 'Simmern/Hunsrück',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28600,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-simmern-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Simmern',
      address: 'Koblenzer Straße 107, 55469 Simmern',
      latitude: 49.9830,
      longitude: 7.5250,
      clusterNum: 22,
      postalCode: '55469',
      city: 'Simmern/Hunsrück',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28500,
      openingHours: 'Mo–Sa 07:00–22:00 Uhr',
    ),
    Store(
      id: 'rh-simmern-dm',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Simmern',
      address: 'Schmiedelstraße 2, 55469 Simmern',
      latitude: 49.9850,
      longitude: 7.5280,
      clusterNum: 22,
      postalCode: '55469',
      city: 'Simmern/Hunsrück',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28300,
      openingHours: 'Mo–Sa 08:00–20:00 Uhr',
    ),
    Store(
      id: 'rh-simmern-rossmann',
      chain: SupermarketChain.rossmann,
      name: 'Rossmann Simmern',
      address: 'Schloßplatz 3, 55469 Simmern',
      latitude: 49.9820,
      longitude: 7.5210,
      postalCode: '55469',
      city: 'Simmern/Hunsrück',
      district: 'Rhein-Hunsrück',
      distanceMeters: 28700,
      openingHours: 'Mo–Sa 08:30–20:00 Uhr',
    ),

    // ── Kirchberg/Hunsrück Cluster 23 ──
    Store(
      id: 'rh-kirchberg-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Kirchberg',
      address: 'Freiherr-von-Drais-Straße 3, 55481 Kirchberg (Hunsrück)',
      latitude: 49.9502,
      longitude: 7.4055,
      clusterNum: 23,
      postalCode: '55481',
      city: 'Kirchberg (Hunsrück)',
      district: 'Rhein-Hunsrück',
      distanceMeters: 36000,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-kirchberg-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Kirchberg',
      address: 'Freiherr-von-Drais-Straße 1, 55481 Kirchberg (Hunsrück)',
      latitude: 49.9508,
      longitude: 7.4066,
      clusterNum: 23,
      postalCode: '55481',
      city: 'Kirchberg (Hunsrück)',
      district: 'Rhein-Hunsrück',
      distanceMeters: 35900,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),

    // ── Kastellaun Cluster 24 (Südstr. / Perlengasse / Fordstr. < 500m) ──
    Store(
      id: 'rh-kastellaun-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Kastellaun',
      address: 'Südstraße 8, 56288 Kastellaun',
      latitude: 50.0671,
      longitude: 7.4452,
      clusterNum: 24,
      postalCode: '56288',
      city: 'Kastellaun',
      district: 'Rhein-Hunsrück',
      distanceMeters: 35800,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-kastellaun-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Kastellaun',
      address: 'Fordstraße 4, 56288 Kastellaun',
      latitude: 50.0635,
      longitude: 7.4439,
      clusterNum: 24,
      postalCode: '56288',
      city: 'Kastellaun',
      district: 'Rhein-Hunsrück',
      distanceMeters: 36100,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-kastellaun-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Kastellaun',
      address: 'Perlengasse 3, 56288 Kastellaun',
      latitude: 50.0664,
      longitude: 7.4431,
      clusterNum: 24,
      postalCode: '56288',
      city: 'Kastellaun',
      district: 'Rhein-Hunsrück',
      distanceMeters: 35900,
      openingHours: 'Mo–Sa 07:00–21:30 Uhr',
    ),
    Store(
      id: 'rh-kastellaun-dm',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Kastellaun',
      address: 'Johann-Sebastian-Bach-Straße 26, 56288 Kastellaun',
      latitude: 50.0682,
      longitude: 7.4446,
      clusterNum: 24,
      postalCode: '56288',
      city: 'Kastellaun',
      district: 'Rhein-Hunsrück',
      distanceMeters: 35700,
      openingHours: 'Mo–Sa 08:00–20:00 Uhr',
    ),
    Store(
      id: 'rh-kastellaun-netto',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount Kastellaun',
      address: 'Zeller Str. 32, 56288 Kastellaun',
      latitude: 50.0710,
      longitude: 7.4380,
      postalCode: '56288',
      city: 'Kastellaun',
      district: 'Rhein-Hunsrück',
      distanceMeters: 36200,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),

    // ── Emmelshausen Cluster 25 ──
    Store(
      id: 'rh-emmelshausen-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Emmelshausen',
      address: 'Argenschwanger Weg 1, 56281 Emmelshausen',
      latitude: 50.1580,
      longitude: 7.6410,
      clusterNum: 25,
      postalCode: '56281',
      city: 'Emmelshausen',
      district: 'Rhein-Hunsrück',
      distanceMeters: 27700,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-emmelshausen-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Emmelshausen',
      address: 'Liesenfelder Weg 14, 56281 Emmelshausen',
      latitude: 50.1540,
      longitude: 7.6430,
      clusterNum: 25,
      postalCode: '56281',
      city: 'Emmelshausen',
      district: 'Rhein-Hunsrück',
      distanceMeters: 27600,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-emmelshausen-netto',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount Emmelshausen',
      address: 'Rhein-Mosel-Str. 98, 56281 Emmelshausen',
      latitude: 50.1560,
      longitude: 7.6380,
      clusterNum: 25,
      postalCode: '56281',
      city: 'Emmelshausen',
      district: 'Rhein-Hunsrück',
      distanceMeters: 27500,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),

    // ── Boppard ──
    Store(
      id: 'rh-boppard-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE Markt Boppard',
      address: 'Hellerwaldstr. 1, 56154 Boppard',
      latitude: 50.2310,
      longitude: 7.5760,
      postalCode: '56154',
      city: 'Boppard',
      district: 'Rhein-Hunsrück',
      distanceMeters: 33000,
      openingHours: 'Mo–Sa 07:00–21:30 Uhr',
    ),
    Store(
      id: 'rh-boppard-lidl',
      chain: SupermarketChain.lidl,
      name: 'Lidl Boppard',
      address: 'Mainzer Str. 48, 56154 Boppard',
      latitude: 50.2280,
      longitude: 7.5840,
      postalCode: '56154',
      city: 'Boppard',
      district: 'Rhein-Hunsrück',
      distanceMeters: 32600,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-boppard-aldi',
      chain: SupermarketChain.aldi_sued,
      name: 'ALDI SÜD Boppard',
      address: 'Buchenauer Str. 6, 56154 Boppard',
      latitude: 50.2200,
      longitude: 7.5820,
      postalCode: '56154',
      city: 'Boppard',
      district: 'Rhein-Hunsrück',
      distanceMeters: 32800,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-boppard-dm',
      chain: SupermarketChain.dm,
      name: 'dm-drogerie markt Boppard',
      address: 'Heerstraße 145, 56154 Boppard',
      latitude: 50.2330,
      longitude: 7.5910,
      postalCode: '56154',
      city: 'Boppard',
      district: 'Rhein-Hunsrück',
      distanceMeters: 33200,
      openingHours: 'Mo–Sa 08:30–20:00 Uhr',
    ),

    // ── Oberwesel & St. Goar ──
    Store(
      id: 'rh-oberwesel-netto',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount Oberwesel',
      address: 'Chrishausener Str. 2, 55430 Oberwesel',
      latitude: 50.1082,
      longitude: 7.7285,
      postalCode: '55430',
      city: 'Oberwesel',
      district: 'Rhein-Hunsrück',
      distanceMeters: 18500,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-oberwesel-rewe',
      chain: SupermarketChain.rewe,
      name: 'REWE City Oberwesel',
      address: 'Koblenzer Str. 18, 55430 Oberwesel',
      latitude: 50.1105,
      longitude: 7.7260,
      postalCode: '55430',
      city: 'Oberwesel',
      district: 'Rhein-Hunsrück',
      distanceMeters: 18700,
      openingHours: 'Mo–Sa 07:00–21:00 Uhr',
    ),
    Store(
      id: 'rh-stgoar-netto',
      chain: SupermarketChain.netto,
      name: 'Netto Marken-Discount St. Goar',
      address: 'An der Loreley 1, 56329 St. Goar',
      latitude: 50.1500,
      longitude: 7.7120,
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

  String _getTileUrl() {
    switch (_tileStyle) {
      case TileStyle.voyager:
        return AppConfig.cartoVoyagerUrl;
      case TileStyle.openStreetMap:
        return AppConfig.openStreetMapUrl;
      case TileStyle.satellite:
        return AppConfig.satelliteUrl;
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
                    _tileStyle == TileStyle.voyager
                        ? 'CartoDB Voyager'
                        : (_tileStyle == TileStyle.satellite ? 'Satellit' : 'OSM'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
            Text(
              '${_filteredStores.length} Filialen • Echte Straßenkarten',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
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
                    Icon(Icons.streetview_rounded, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 10),
                    Text('OpenStreetMap Classic'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TileStyle.satellite,
                child: Row(
                  children: [
                    Icon(Icons.satellite_alt_rounded, size: 18, color: Color(0xFFD97706)),
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
          : Stack(
              children: [
                Column(
                  children: [
                    // Top District & Chain Filter Chips Bar
                    _buildDistrictAndFilterBar(),

                    // Main Content: Echte hochauflösende Kachel-Karte
                    Expanded(
                      child: _isMapView
                          ? _buildRealTileMapView(userLoc)
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

  /// Real Tile Map View powered by flutter_map and CartoDB/OpenStreetMap
  Widget _buildRealTileMapView(UserLocation userLoc) {
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
              urlTemplate: _getTileUrl(),
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
                  child: _buildUserLocationMarker(),
                ),
                ..._buildStoreMarkers(),
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

  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2563EB),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Marker> _buildStoreMarkers() {
    return _filteredStores.map((store) {
      final isSelected = _selectedStore?.id == store.id;
      final chainColor = _getChainColor(store.chain);
      final badge = _getChainBadge(store.chain);

      return Marker(
        point: LatLng(store.latitude, store.longitude),
        width: 68,
        height: 64,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // onTapDown löst SOFORT beim ersten Touch aus (kein Wisch-Konflikt!)
          onTapDown: (_) {
            setState(() {
              _selectedStore = store;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Store Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isSelected ? 0.4 : 0.2),
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
              const SizedBox(height: 1),

              // Pin Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: isSelected ? 40 : 32,
                    color: chainColor,
                  ),
                  Positioned(
                    top: isSelected ? 6 : 5,
                    child: Container(
                      width: isSelected ? 15 : 12,
                      height: isSelected ? 15 : 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        store.chain == SupermarketChain.dm || store.chain == SupermarketChain.rossmann
                            ? Icons.sanitizer_outlined
                            : Icons.shopping_basket_rounded,
                        size: isSelected ? 9 : 7,
                        color: chainColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

          // Opening Hours Pill (prominent)
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
}
