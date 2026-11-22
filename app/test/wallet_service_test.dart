import 'package:einkaufs_optimierer/core/models/loyalty_wallet.dart';
import 'package:einkaufs_optimierer/core/models/store.dart';
import 'package:einkaufs_optimierer/core/services/wallet_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WeeklyOffer', () {
    test('fromJson akzeptiert Scraper-Feldnamen und String-Preise', () {
      final o = WeeklyOffer.fromJson({
        'id': 1,
        'chain': 'aldi_sued',
        'raw_title': 'Skyr 500g',
        'price_cents': '119',
        'original_price_cents': 149,
        'discount_percent': 20,
        'valid_to': '2030-01-31T00:00:00Z',
      });
      expect(o.id, '1');
      expect(o.chain, SupermarketChain.aldi_sued);
      expect(o.productName, 'Skyr 500g');
      expect(o.title, 'Skyr 500g');
      expect(o.discountPriceCents, 119);
      expect(o.regularPriceCents, 149);
      expect(o.isExpired, isFalse);
      expect(o.displayValidity, 'Gültig bis 31.01.');
    });

    test('ohne Normalpreis gilt der Angebotspreis', () {
      final o = WeeklyOffer.fromJson({'discount_price_cents': 99});
      expect(o.regularPriceCents, 99);
      expect(o.displayValidity, 'Wochenangebot');
      expect(o.daysRemaining, isNull);
    });

    test('abgelaufenes Angebot: isExpired und 0 Resttage', () {
      final o = WeeklyOffer.fromJson(
          {'valid_to': '2000-01-01', 'period_label': 'KW 1'});
      expect(o.isExpired, isTrue);
      expect(o.daysRemaining, 0);
      expect(o.displayValidity, 'KW 1');
    });
  });

  test('UserCoupon.fromJson setzt Standardwerte', () {
    final c = UserCoupon.fromJson({'id': 'x', 'chain': 'dm', 'title': '10 %'});
    expect(c.chain, SupermarketChain.dm);
    expect(c.discountType, 'percent');
    expect(c.minSpendCents, 0);
    expect(c.isActive, isTrue);
    expect(c.validUntil, isNull);
  });

  group('WalletService', () {
    test('toggleCoupon schaltet nur den gewählten Coupon um', () {
      final before = WalletService.coupons;
      final id = before.first.id;
      WalletService.toggleCoupon(id);
      final after = WalletService.coupons;
      expect(after.first.isActive, !before.first.isActive);
      for (var i = 1; i < after.length; i++) {
        expect(after[i].isActive, before[i].isActive);
      }
      WalletService.toggleCoupon(id); // zurücksetzen
    });

    test('addCoupon fügt vorne ein', () {
      const c = UserCoupon(
          id: 'test-add',
          chain: SupermarketChain.lidl,
          title: 'T',
          discountType: 'percent',
          discountValue: 5);
      WalletService.addCoupon(c);
      expect(WalletService.coupons.first.id, 'test-add');
    });

    test('unlinkApp trennt die App und entfernt Coupons dieser Kette',
        () async {
      final app = WalletService.integratedApps.firstWhere((a) => a.isConnected);
      await WalletService.unlinkApp(app.id);
      final now =
          WalletService.integratedApps.firstWhere((a) => a.id == app.id);
      expect(now.isConnected, isFalse);
      expect(now.pointsBalance, 0);
      expect(WalletService.coupons.where((c) => c.chain == app.chain), isEmpty);
    });

    test('syncApp auf getrennter App liefert false', () async {
      final app =
          WalletService.integratedApps.firstWhere((a) => !a.isConnected);
      expect(await WalletService.syncApp(app.id), isFalse);
      expect(await WalletService.syncApp('gibt-es-nicht'), isFalse);
    });

    test('linkApp verbindet und setzt Punkte/Coupons', () async {
      final app =
          WalletService.integratedApps.firstWhere((a) => !a.isConnected);
      await WalletService.linkApp(app.id);
      final now =
          WalletService.integratedApps.firstWhere((a) => a.id == app.id);
      expect(now.isConnected, isTrue);
      expect(now.syncStatus, SyncStatus.synced);
      expect(now.importedCouponsCount, greaterThan(0));
      expect(now.pointsBalance, greaterThan(0));
      expect(now.lastSyncedAt, isNotNull);
    });

    test('syncApp überspringt kürzlich synchronisierte Apps', () async {
      final app = WalletService.integratedApps
          .firstWhere((a) => a.isConnected && a.lastSyncedAt != null);
      final before = app.lastSyncedAt;
      final sw = Stopwatch()..start();
      expect(await WalletService.syncApp(app.id), isTrue);
      expect(sw.elapsedMilliseconds,
          lessThan(500)); // kein simulierter Netzwerk-Sync
      expect(
          WalletService.integratedApps
              .firstWhere((a) => a.id == app.id)
              .lastSyncedAt,
          before);
    });

    test('loadScrapedOffers liest die Angebote aus app/assets', () async {
      final offers = await WalletService.loadScrapedOffers(forceRefresh: true);
      expect(offers.length, greaterThan(5));
      expect(offers.every((o) => o.id.startsWith('scraped-')), isTrue);
      expect(offers.every((o) => o.discountPriceCents > 0), isTrue);
    });
  });
}
