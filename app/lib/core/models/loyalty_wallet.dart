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
  final DateTime? validFrom;
  final DateTime? validTo;
  final String? periodLabel;
  final String? unitInfo;

  const WeeklyOffer({
    required this.id,
    required this.chain,
    required this.productName,
    required this.title,
    required this.discountPriceCents,
    required this.regularPriceCents,
    required this.discountPercent,
    this.isActive = true,
    this.validFrom,
    this.validTo,
    this.periodLabel,
    this.unitInfo,
  });

  double get discountPriceEuros => discountPriceCents / 100.0;
  double get regularPriceEuros => regularPriceCents / 100.0;

  bool get isExpired {
    if (validTo == null) return false;
    return DateTime.now().isAfter(validTo!);
  }

  int? get daysRemaining {
    if (validTo == null) return null;
    final diff = validTo!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  String get displayValidity {
    if (periodLabel != null && periodLabel!.isNotEmpty) {
      return periodLabel!;
    }
    if (validTo != null) {
      String pad(int n) => n.toString().padLeft(2, '0');
      return 'Gültig bis ${pad(validTo!.day)}.${pad(validTo!.month)}.';
    }
    return 'Wochenangebot';
  }

  factory WeeklyOffer.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    final pName = json['product_name'] ?? json['matched_product_name'] ?? json['raw_title'] ?? '';
    final tName = json['title'] ?? json['raw_title'] ?? pName;
    final pCents = json['discount_price_cents'] ?? json['price_cents'] ?? 0;
    final rCents = json['regular_price_cents'] ?? json['original_price_cents'] ?? pCents;

    return WeeklyOffer(
      id: json['id']?.toString() ?? '',
      chain: SupermarketChain.fromString(json['chain'] ?? 'rewe'),
      productName: pName.toString(),
      title: tName.toString(),
      discountPriceCents: pCents is num ? pCents.toInt() : int.tryParse(pCents.toString()) ?? 0,
      regularPriceCents: rCents is num ? rCents.toInt() : int.tryParse(rCents.toString()) ?? 0,
      discountPercent: (json['discount_percent'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] ?? true,
      validFrom: parseDate(json['valid_from'] ?? json['starts_at']),
      validTo: parseDate(json['valid_to'] ?? json['ends_at']),
      periodLabel: json['period_label']?.toString(),
      unitInfo: json['unit_info']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chain': chain.name,
      'product_name': productName,
      'title': title,
      'discount_price_cents': discountPriceCents,
      'regular_price_cents': regularPriceCents,
      'discount_percent': discountPercent,
      'is_active': isActive,
      'valid_from': validFrom?.toIso8601String(),
      'valid_to': validTo?.toIso8601String(),
      'period_label': periodLabel,
      'unit_info': unitInfo,
    };
  }
}
