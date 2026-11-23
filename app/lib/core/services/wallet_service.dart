// app/lib/core/services/wallet_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/loyalty_wallet.dart';
import '../models/store.dart';
import 'analytics_service.dart';

class WalletService {
  static List<AppIntegrationInfo> _integratedApps = [
    const AppIntegrationInfo(
      id: 'lidl-plus',
      chain: SupermarketChain.lidl,
      programName: 'Lidl Plus',
      description: 'Persönliche Coupons, Kassenbons & Lidl-Pay',
      integrationType: IntegrationType.oauthSessionToken,
      apiDocumentation:
          'Lidl bietet keine offizielle Entwickler-API. Diese Verknüpfung ist eine Demo mit Beispieldaten.',
      isConnected: true,
      syncStatus: SyncStatus.synced,
      importedCouponsCount: 4,
      pointsBalance: 450,
      syncIntervalHours: 6,
      importedDataSummary: ['4 Aktivierte Coupons', '4,50 € Spar-Guthaben', 'Letzter Kassenbon Bingen'],
    ),
    const AppIntegrationInfo(
      id: 'payback',
      chain: SupermarketChain.rewe,
      programName: 'PAYBACK',
      description: 'Punkte sammeln bei REWE, dm, Aral & 600+ Partnern',
      integrationType: IntegrationType.partnerRestSession,
      apiDocumentation:
          'Geplant: PAYBACK-Anbindung. Diese Verknüpfung ist eine Demo mit Beispieldaten.',
      isConnected: true,
      syncStatus: SyncStatus.synced,
      importedCouponsCount: 3,
      pointsBalance: 2040,
      syncIntervalHours: 12,
      importedDataSummary: ['3 eCoupons aktiv (10% REWE, 20x dmBio)', '2.040 Punkte (20,40 €)', 'REWE & dm Konto synchron'],
    ),
    const AppIntegrationInfo(
      id: 'deutschlandcard',
      chain: SupermarketChain.netto,
      programName: 'DeutschlandCard',
      description: 'Punkte bei Netto, EDEKA, Esso & vielen mehr',
      integrationType: IntegrationType.webSessionVault,
      apiDocumentation:
          'Web-Session Vault für Netto Marken-Discount. Keine offizielle Public API; Session-Cookies verfallen nach 30 Tagen (Re-Auth).',
      isConnected: false,
      syncStatus: SyncStatus.disconnected,
      importedCouponsCount: 0,
      pointsBalance: 0,
      syncIntervalHours: 12,
      importedDataSummary: [],
    ),
    const AppIntegrationInfo(
      id: 'rossmann-app',
      chain: SupermarketChain.rossmann,
      programName: 'Rossmann App',
      description: '10%-Coupons, Babywelt-Vorteile & Aktionsangebote',
      integrationType: IntegrationType.barcodeCardNumber,
      apiDocumentation:
          'Lokale Speicherung der Rossmann-Kundennummer und der 10%-Kupon-Barcodes im Hardware-Keystore. Kein Cloud-Passwort erforderlich.',
      isConnected: true,
      syncStatus: SyncStatus.synced,
      importedCouponsCount: 2,
      pointsBalance: 0,
      syncIntervalHours: 24,
      importedDataSummary: ['10% Universalgutschein (1/4)', '20% auf alle enerBiO Artikel'],
    ),
    const AppIntegrationInfo(
      id: 'aldi-app',
      chain: SupermarketChain.aldi_sued,
      programName: 'ALDI SÜD Aktionen',
      description: 'Aktionsartikel, Prospekte & Filial-Angebote',
      integrationType: IntegrationType.partnerRestSession,
      apiDocumentation:
          'Öffentlicher Prospekt-Feed der ALDI SÜD Filialen (Bingen & Umgebung). Kein Kunden-Login erforderlich.',
      isConnected: true,
      syncStatus: SyncStatus.synced,
      importedCouponsCount: 0,
      pointsBalance: 0,
      syncIntervalHours: 6,
      importedDataSummary: ['Wöchentlicher Frische- & Non-Food-Feed'],
    ),
    const AppIntegrationInfo(
      id: 'dm-app',
      chain: SupermarketChain.dm,
      programName: 'dm-Drogerie App',
      description: 'Coupons, Produktscanner & PAYBACK-Integration',
      integrationType: IntegrationType.partnerRestSession,
      apiDocumentation:
          'Geplant: dm-Kundenkonto. Diese Verknüpfung ist eine Demo mit Beispieldaten.',
      isConnected: false,
      syncStatus: SyncStatus.disconnected,
      importedCouponsCount: 0,
      pointsBalance: 0,
      syncIntervalHours: 12,
      importedDataSummary: [],
    ),
  ];

  static List<UserCoupon> _coupons = [
    const UserCoupon(
      id: 'coup-1',
      chain: SupermarketChain.rewe,
      title: '10% Rabatt auf Obst & Bio',
      discountType: 'percent',
      discountValue: 10.0,
      categorySlug: 'obst',
      minSpendCents: 0,
      isActive: true,
    ),
    const UserCoupon(
      id: 'coup-2',
      chain: SupermarketChain.lidl,
      title: '1,00 € Rabatt ab 15 € Einkauf',
      discountType: 'fixed_amount',
      discountValue: 100.0,
      minSpendCents: 1500,
      isActive: true,
    ),
    const UserCoupon(
      id: 'coup-3',
      chain: SupermarketChain.netto,
      title: '5x DeutschlandCard Punkte',
      discountType: 'points_multiplier',
      discountValue: 5.0,
      minSpendCents: 0,
      isActive: true,
    ),
    const UserCoupon(
      id: 'coup-4',
      chain: SupermarketChain.rossmann,
      title: '10% Rabatt auf den gesamten Einkauf',
      discountType: 'percent',
      discountValue: 10.0,
      categorySlug: 'allgemein',
      minSpendCents: 0,
      isActive: true,
    ),
    const UserCoupon(
      id: 'coup-5',
      chain: SupermarketChain.dm,
      title: '20-fach PAYBACK Punkte auf dmBio',
      discountType: 'points_multiplier',
      discountValue: 20.0,
      categorySlug: 'bio',
      minSpendCents: 0,
      isActive: true,
    ),
  ];

  static final List<WeeklyOffer> _weeklyOffers = [
    const WeeklyOffer(
      id: 'off-1',
      chain: SupermarketChain.rewe,
      productName: 'Barilla Spaghetti No. 5 500g',
      title: 'Barilla Spaghetti Wochenknüller',
      discountPriceCents: 149,
      regularPriceCents: 199,
      discountPercent: 25,
      periodLabel: 'Gültig bis Sa.',
      unitInfo: '500g Packung',
    ),
    const WeeklyOffer(
      id: 'off-2',
      chain: SupermarketChain.lidl,
      productName: 'Kerrygold Irische Butter 250g',
      title: 'Kerrygold Butter Aktionspreis',
      discountPriceCents: 219,
      regularPriceCents: 279,
      discountPercent: 21,
      periodLabel: 'Gültig bis Sa.',
      unitInfo: '250g Stück',
    ),
    const WeeklyOffer(
      id: 'off-3',
      chain: SupermarketChain.netto,
      productName: 'Bio Bananen',
      title: 'Bio Bananen Frische-Aktion',
      discountPriceCents: 159,
      regularPriceCents: 199,
      discountPercent: 20,
      periodLabel: 'Gültig bis Sa.',
      unitInfo: '1kg Bund',
    ),
    const WeeklyOffer(
      id: 'off-4',
      chain: SupermarketChain.dm,
      productName: 'dmBio Hafermilch Natur 1L',
      title: 'dmBio Vorteilspreis',
      discountPriceCents: 95,
      regularPriceCents: 115,
      discountPercent: 17,
      periodLabel: 'Gültig 14 Tage',
      unitInfo: '1L Tetra Pak',
    ),
    const WeeklyOffer(
      id: 'off-5',
      chain: SupermarketChain.rossmann,
      productName: 'Toilettenpapier 3-lagig 8er',
      title: 'Alouette Toilettenpapier Sparpack',
      discountPriceCents: 299,
      regularPriceCents: 379,
      discountPercent: 21,
      periodLabel: 'Gültig 14 Tage',
      unitInfo: '8 Rollen Packung',
    ),
  ];

  static bool _offersLoaded = false;

  static List<AppIntegrationInfo> get integratedApps => _integratedApps;
  static List<UserCoupon> get coupons => _coupons;
  static List<WeeklyOffer> get weeklyOffers => _weeklyOffers;

  /// Lädt tagesaktuelle, gescrapte Angebote mit Datumsbereich aus dem Asset-Store
  static Future<List<WeeklyOffer>> loadScrapedOffers({bool forceRefresh = false}) async {
    if (_offersLoaded && !forceRefresh && _weeklyOffers.length > 5) {
      return _weeklyOffers;
    }

    try {
      final jsonStr = await rootBundle.loadString('assets/live_scraped_offers_rlp.json');
      final Map<String, dynamic> data = json.decode(jsonStr);
      final List<dynamic>? rawOffers = data['offers'];

      if (rawOffers != null && rawOffers.isNotEmpty) {
        final parsed = rawOffers.map((o) {
          final map = o as Map<String, dynamic>;
          final chainVal = map['chain']?.toString() ?? 'rewe';
          final pName = map['matched_product_name'] ?? map['raw_title'] ?? '';
          return WeeklyOffer.fromJson({
            'id': 'scraped-$chainVal-${map['matched_product_id'] ?? pName.hashCode}',
            'chain': chainVal,
            'product_name': pName,
            'title': map['raw_title'] ?? pName,
            'discount_price_cents': map['price_cents'] ?? 0,
            'regular_price_cents': map['original_price_cents'] ?? map['price_cents'] ?? 0,
            'discount_percent': map['discount_percent'] ?? 0,
            'is_active': true,
            'valid_from': map['valid_from'],
            'valid_to': map['valid_to'],
            'period_label': map['period_label'],
            'unit_info': map['unit_info'],
          });
        }).toList();

        if (parsed.isNotEmpty) {
          _weeklyOffers
            ..clear()
            ..addAll(parsed);
          _offersLoaded = true;
          return _weeklyOffers;
        }
      }
    } catch (e) {
      debugPrint('[WalletService] Fallback auf kuratierte Angebote: $e');
    }

    _offersLoaded = true;
    return _weeklyOffers;
  }

  /// Verknüpft eine externe Supermarkt-App
  static Future<void> linkApp(
    String appId, {
    String? cardNumber,
    String? username,
    String? password,
  }) async {
    final idx = _integratedApps.indexWhere((a) => a.id == appId);
    if (idx < 0) return;

    final app = _integratedApps[idx];
    final importedCoupons = app.chain == SupermarketChain.rossmann ? 2 : 4;
    final points = app.chain == SupermarketChain.rewe ? 2040 : (app.chain == SupermarketChain.lidl ? 450 : 830);

    _integratedApps[idx] = app.copyWith(
      isConnected: true,
      syncStatus: SyncStatus.synced,
      importedCouponsCount: importedCoupons,
      pointsBalance: points,
      lastSyncedAt: DateTime.now(),
      statusMessage: 'Demo-Verknüpfung (simuliert)',
      importedDataSummary: [
        '$importedCoupons personalisierte Coupons importiert',
        'Punktestand: $points',
        'Beispieldaten, keine echte Verbindung',
      ],
    );

    AnalyticsService.trackEvent(
      'supermarket_app_linked',
      category: 'wallet',
      properties: {
        'app_id': appId,
        'chain': app.chain.name,
        'imported_coupons': importedCoupons,
      },
    );
  }

  /// Trennt eine verknüpfte Supermarkt-App
  static Future<void> unlinkApp(String appId) async {
    final idx = _integratedApps.indexWhere((a) => a.id == appId);
    if (idx < 0) return;

    final app = _integratedApps[idx];
    _integratedApps[idx] = app.copyWith(
      isConnected: false,
      syncStatus: SyncStatus.disconnected,
      importedCouponsCount: 0,
      pointsBalance: 0,
      lastSyncedAt: null,
      statusMessage: null,
      importedDataSummary: [],
    );

    // Remove coupons associated with this chain
    _coupons = _coupons.where((c) => c.chain != app.chain).toList();

    AnalyticsService.trackEvent(
      'supermarket_app_unlinked',
      category: 'wallet',
      properties: {'app_id': appId, 'chain': app.chain.name},
    );
  }

  /// Einzel-Synchronisation einer App mit 6h-Intervall-Check und Deduplizierung
  static Future<bool> syncApp(String appId, {bool force = false}) async {
    final idx = _integratedApps.indexWhere((a) => a.id == appId);
    if (idx < 0) return false;

    final app = _integratedApps[idx];
    if (!app.isConnected) return false;

    // Check if synced within the interval
    if (!force && app.lastSyncedAt != null) {
      final hoursSinceSync = DateTime.now().difference(app.lastSyncedAt!).inHours;
      if (hoursSinceSync < app.syncIntervalHours) {
        debugPrint('[WalletService] ${app.programName} sync skipped (recently synced $hoursSinceSync h ago)');
        return true;
      }
    }

    _integratedApps[idx] = app.copyWith(syncStatus: SyncStatus.syncing);

    // Simulate network sync
    await Future.delayed(const Duration(milliseconds: 900));

    final now = DateTime.now();
    _integratedApps[idx] = _integratedApps[idx].copyWith(
      syncStatus: SyncStatus.synced,
      lastSyncedAt: now,
      statusMessage: 'Zuletzt aktualisiert: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} Uhr',
    );

    AnalyticsService.trackCouponSyncSuccess(
      chain: app.chain.name,
      importedCount: app.importedCouponsCount,
    );

    return true;
  }

  /// Synchronisiert alle verbundenen Apps (für Pull-to-Refresh & Background-Scheduler)
  static Future<int> syncAllConnectedApps({bool force = false}) async {
    int syncedCount = 0;
    for (final app in _integratedApps) {
      if (app.isConnected) {
        final ok = await syncApp(app.id, force: force);
        if (ok) syncedCount++;
      }
    }
    return syncedCount;
  }

  static void toggleCoupon(String couponId) {
    _coupons = _coupons.map((c) {
      if (c.id == couponId) {
        return c.copyWith(isActive: !c.isActive);
      }
      return c;
    }).toList();
  }

  static void addCoupon(UserCoupon coupon) {
    _coupons = [coupon, ..._coupons];
  }
}
