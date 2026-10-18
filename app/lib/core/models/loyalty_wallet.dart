// app/lib/core/models/loyalty_wallet.dart

import 'store.dart';

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

  const UserCoupon({
    required this.id,
    required this.chain,
    required this.title,
    required this.discountType,
    required this.discountValue,
    this.categorySlug,
    this.minSpendCents = 0,
    this.isActive = true,
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
