// app/lib/core/services/wallet_service.dart

import '../models/loyalty_wallet.dart';
import '../models/store.dart';

class WalletService {
  static List<LoyaltyAccount> _accounts = [
    const LoyaltyAccount(
      id: 'acc-1',
      chain: SupermarketChain.rewe,
      programName: 'PAYBACK',
      pointsBalance: 1420,
      pointsValueCents: 1420,
      cardNumberMasked: '•••• 8821',
    ),
    const LoyaltyAccount(
      id: 'acc-2',
      chain: SupermarketChain.lidl,
      programName: 'Lidl Plus',
      pointsBalance: 450,
      pointsValueCents: 450,
      cardNumberMasked: '•••• 5019',
    ),
    const LoyaltyAccount(
      id: 'acc-3',
      chain: SupermarketChain.netto,
      programName: 'DeutschlandCard',
      pointsBalance: 830,
      pointsValueCents: 830,
      cardNumberMasked: '•••• 3342',
    ),
    const LoyaltyAccount(
      id: 'acc-4',
      chain: SupermarketChain.aldi_sued,
      programName: 'ALDI Aktionen',
      pointsBalance: 0,
      pointsValueCents: 0,
    ),
    const LoyaltyAccount(
      id: 'acc-5',
      chain: SupermarketChain.dm,
      programName: 'PAYBACK (dm-App)',
      pointsBalance: 620,
      pointsValueCents: 620,
      cardNumberMasked: '•••• 1944',
    ),
    const LoyaltyAccount(
      id: 'acc-6',
      chain: SupermarketChain.rossmann,
      programName: 'Rossmann App (10% Coupons)',
      pointsBalance: 0,
      pointsValueCents: 0,
      cardNumberMasked: '•••• 7701',
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
    ),
    const WeeklyOffer(
      id: 'off-2',
      chain: SupermarketChain.lidl,
      productName: 'Kerrygold Irische Butter 250g',
      title: 'Kerrygold Butter Aktionspreis',
      discountPriceCents: 219,
      regularPriceCents: 279,
      discountPercent: 21,
    ),
    const WeeklyOffer(
      id: 'off-3',
      chain: SupermarketChain.netto,
      productName: 'Bio Bananen',
      title: 'Bio Bananen Frische-Aktion',
      discountPriceCents: 159,
      regularPriceCents: 199,
      discountPercent: 20,
    ),
    const WeeklyOffer(
      id: 'off-4',
      chain: SupermarketChain.dm,
      productName: 'dmBio Hafermilch Natur 1L',
      title: 'dmBio Vorteilspreis',
      discountPriceCents: 95,
      regularPriceCents: 115,
      discountPercent: 17,
    ),
    const WeeklyOffer(
      id: 'off-5',
      chain: SupermarketChain.rossmann,
      productName: 'Toilettenpapier 3-lagig 8er',
      title: 'Alouette Toilettenpapier Sparpack',
      discountPriceCents: 299,
      regularPriceCents: 379,
      discountPercent: 21,
    ),
  ];

  static List<LoyaltyAccount> get accounts => _accounts;
  static List<UserCoupon> get coupons => _coupons;
  static List<WeeklyOffer> get weeklyOffers => _weeklyOffers;

  static void updatePoints(SupermarketChain chain, int newPoints) {
    _accounts = _accounts.map((acc) {
      if (acc.chain == chain) {
        return acc.copyWith(
          pointsBalance: newPoints,
          pointsValueCents: newPoints,
        );
      }
      return acc;
    }).toList();
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
