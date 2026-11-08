// app/lib/core/models/loyalty_wallet.dart

import 'store.dart';

enum SyncStatus {
  disconnected,
  syncing,
  synced,
  reAuthRequired,
  failed,
}

enum IntegrationType {
  oauthSessionToken,   // e.g. Lidl Plus OAuth token flow
  partnerRestSession,  // e.g. PAYBACK partner API session
  barcodeCardNumber,   // e.g. Rossmann barcode / customer ID
  webSessionVault,     // e.g. DeutschlandCard token vault
}

class AppIntegrationInfo {
  final String id;
  final SupermarketChain chain;
  final String programName;
  final String description;
  final IntegrationType integrationType;
  final String apiDocumentation;
  final bool isConnected;
  final SyncStatus syncStatus;
  final int importedCouponsCount;
  final int pointsBalance;
  final DateTime? lastSyncedAt;
  final int syncIntervalHours;
  final String? statusMessage;
  final List<String> importedDataSummary;

  const AppIntegrationInfo({
    required this.id,
    required this.chain,
    required this.programName,
    required this.description,
    required this.integrationType,
    required this.apiDocumentation,
    this.isConnected = false,
    this.syncStatus = SyncStatus.disconnected,
    this.importedCouponsCount = 0,
    this.pointsBalance = 0,
    this.lastSyncedAt,
    this.syncIntervalHours = 6,
    this.statusMessage,
    this.importedDataSummary = const [],
  });

  bool get needsReAuth => syncStatus == SyncStatus.reAuthRequired;

  AppIntegrationInfo copyWith({
    bool? isConnected,
    SyncStatus? syncStatus,
    int? importedCouponsCount,
    int? pointsBalance,
    DateTime? lastSyncedAt,
    String? statusMessage,
    List<String>? importedDataSummary,
  }) {
    return AppIntegrationInfo(
      id: id,
      chain: chain,
      programName: programName,
      description: description,
      integrationType: integrationType,
      apiDocumentation: apiDocumentation,
      isConnected: isConnected ?? this.isConnected,
      syncStatus: syncStatus ?? this.syncStatus,
      importedCouponsCount: importedCouponsCount ?? this.importedCouponsCount,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncIntervalHours: syncIntervalHours,
      statusMessage: statusMessage ?? this.statusMessage,
      importedDataSummary: importedDataSummary ?? this.importedDataSummary,
    );
  }
}

class LoyaltyAccount {
  final String id;
  final SupermarketChain chain;
  final String programName;
  final int pointsBalance;
  final int pointsValueCents;
  final String? cardNumberMasked;

  const LoyaltyAccount({
    required this.id,
    required this.chain,
    required this.programName,
    required this.pointsBalance,
    required this.pointsValueCents,
    this.cardNumberMasked,
  });

  double get pointsValueEuros => pointsValueCents / 100.0;

  LoyaltyAccount copyWith({
    int? pointsBalance,
    int? pointsValueCents,
  }) {
    return LoyaltyAccount(
      id: id,
      chain: chain,
      programName: programName,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      pointsValueCents: pointsValueCents ?? this.pointsValueCents,
      cardNumberMasked: cardNumberMasked,
    );
  }

  factory LoyaltyAccount.fromJson(Map<String, dynamic> json) {
    return LoyaltyAccount(
      id: json['id'] ?? '',
      chain: SupermarketChain.fromString(json['chain'] ?? 'rewe'),
      programName: json['program_name'] ?? 'Bonusprogramm',
      pointsBalance: json['points_balance'] ?? 0,
      pointsValueCents: json['points_value_cents'] ?? 0,
      cardNumberMasked: json['card_number_masked'],
    );
  }
}

class UserCoupon {
  final String id;
  final SupermarketChain chain;
  final String title;
  final String discountType; // 'percent', 'fixed_amount', 'points_multiplier'
  final double discountValue;
  final String? categorySlug;
  final int minSpendCents;
  final bool isActive;
  final DateTime? validUntil;

  const UserCoupon({
    required this.id,
    required this.chain,
    required this.title,
    required this.discountType,
    required this.discountValue,
    this.categorySlug,
    this.minSpendCents = 0,
    this.isActive = true,
    this.validUntil,
  });

  UserCoupon copyWith({bool? isActive}) {
    return UserCoupon(
      id: id,
      chain: chain,
      title: title,
      discountType: discountType,
      discountValue: discountValue,
      categorySlug: categorySlug,
      minSpendCents: minSpendCents,
      isActive: isActive ?? this.isActive,
      validUntil: validUntil,
    );
  }

  factory UserCoupon.fromJson(Map<String, dynamic> json) {
    return UserCoupon(
      id: json['id'] ?? '',
      chain: SupermarketChain.fromString(json['chain'] ?? 'rewe'),
      title: json['title'] ?? '',
      discountType: json['discount_type'] ?? 'percent',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      categorySlug: json['category_slug'],
      minSpendCents: json['min_spend_cents'] ?? 0,
      isActive: json['is_active'] ?? true,
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until']) : null,
    );
  }
}

class WeeklyOffer {
  final String id;
  final SupermarketChain chain;
  final String productName;
  final String title;
  final int discountPriceCents;
  final int regularPriceCents;
  final int discountPercent;
  final bool isActive;

  const WeeklyOffer({
    required this.id,
    required this.chain,
    required this.productName,
    required this.title,
    required this.discountPriceCents,
    required this.regularPriceCents,
    required this.discountPercent,
    this.isActive = true,
  });

  double get discountPriceEuros => discountPriceCents / 100.0;
  double get regularPriceEuros => regularPriceCents / 100.0;

  factory WeeklyOffer.fromJson(Map<String, dynamic> json) {
    return WeeklyOffer(
      id: json['id'] ?? '',
      chain: SupermarketChain.fromString(json['chain'] ?? 'rewe'),
      productName: json['product_name'] ?? '',
      title: json['title'] ?? '',
      discountPriceCents: json['discount_price_cents'] ?? 0,
      regularPriceCents: json['regular_price_cents'] ?? 0,
      discountPercent: json['discount_percent'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}
