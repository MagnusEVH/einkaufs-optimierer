// app/lib/core/services/loyalty_service.dart
//
// Treue-Apps ohne Fremdzugriff (D1/D3): Die App öffnet die Händler-App,
// Punkte und Guthaben kommen nur aus einem Scan (Kassenbon oder Screenshot
// der Guthaben-Seite, Texterkennung im Browser). Kein Login, kein Auslesen
// fremder Apps (technisch nicht möglich und nicht erlaubt).
//
// App-Links: Universal Links laut apple-app-site-association der Händler
// (Stand 25.11.2026), sonst App-Store-Seite (Nummern per iTunes-Lookup geprüft).

import 'package:flutter/foundation.dart';
import '../models/store.dart';
import 'preferences_storage.dart';

class LoyaltyProgram {
  final String id;
  final String name;
  final String appName;
  final List<SupermarketChain> chains;
  /// Was die App an der Kasse bringt (kurz).
  final String benefit;
  /// Hinweis kurz vor der Kasse, oder null, wenn es nichts zu scannen gibt.
  final String? checkoutHint;
  /// Universal Link, der auf dem iPhone direkt die App öffnet (falls installiert).
  final String? appLink;
  final String appStoreId;
  final String? androidPackage;
  /// 'euro' (Guthaben) oder 'points' (Punkte) oder null (kein Konto).
  final String? balanceKind;

  const LoyaltyProgram({
    required this.id,
    required this.name,
    required this.appName,
    required this.chains,
    required this.benefit,
    this.checkoutHint,
    this.appLink,
    required this.appStoreId,
    this.androidPackage,
    this.balanceKind,
  });

  String get appStoreUrl => 'https://apps.apple.com/de/app/id$appStoreId';
}

/// Zuletzt gescannter Stand eines Programms.
class LoyaltyBalance {
  final String programId;
  final int? valueCents;
  final int? points;
  final DateTime at;
  final String source; // 'Screenshot' oder 'Kassenbon'
  const LoyaltyBalance({required this.programId, this.valueCents, this.points, required this.at, required this.source});

  Map<String, dynamic> toJson() => {
        'program': programId,
        'value_cents': valueCents,
        'points': points,
        'at': at.toIso8601String(),
        'source': source,
      };

  factory LoyaltyBalance.fromJson(Map<String, dynamic> j) => LoyaltyBalance(
        programId: j['program'].toString(),
        valueCents: (j['value_cents'] as num?)?.toInt(),
        points: (j['points'] as num?)?.toInt(),
        at: DateTime.tryParse(j['at']?.toString() ?? '') ?? DateTime.now(),
        source: j['source']?.toString() ?? 'Scan',
      );
}

/// Was ein Kassenbon über die Treue-App verrät.
class CheckoutRecord {
  final String programId;
  final DateTime date;
  /// true = Bon zeigt Bonus-/Punktezeilen, also wurde die App an der Kasse gescannt.
  final bool scanned;
  final int? earnedCents;
  final int? redeemedCents;
  final int? points;
  const CheckoutRecord({required this.programId, required this.date, required this.scanned, this.earnedCents, this.redeemedCents, this.points});

  Map<String, dynamic> toJson() => {
        'program': programId,
        'date': date.toIso8601String(),
        'scanned': scanned,
        'earned_cents': earnedCents,
        'redeemed_cents': redeemedCents,
        'points': points,
      };

  factory CheckoutRecord.fromJson(Map<String, dynamic> j) => CheckoutRecord(
        programId: j['program'].toString(),
        date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        scanned: j['scanned'] == true,
        earnedCents: (j['earned_cents'] as num?)?.toInt(),
        redeemedCents: (j['redeemed_cents'] as num?)?.toInt(),
        points: (j['points'] as num?)?.toInt(),
      );
}

/// Ergebnis eines Screenshot-Scans (BalanceScanner).
class BalanceImport {
  final String programId;
  final int? valueCents;
  final int? points;
  const BalanceImport({required this.programId, this.valueCents, this.points});
}

class LoyaltyService {
  LoyaltyService._();

  static const programs = <LoyaltyProgram>[
    LoyaltyProgram(
      id: 'rewe',
      name: 'REWE Bonus',
      appName: 'REWE',
      chains: [SupermarketChain.rewe],
      benefit: 'Bonus-Guthaben sammeln und an der Kasse einlösen',
      checkoutHint: 'REWE-App öffnen, Guthaben wählen und den QR-Code vor dem Bezahlen scannen lassen.',
      appLink: 'https://www.rewe.de/bonus/einloesen',
      appStoreId: '714121079',
      androidPackage: 'de.rewe.app.mobile',
      balanceKind: 'euro',
    ),
    LoyaltyProgram(
      id: 'lidl_plus',
      name: 'Lidl Plus',
      appName: 'Lidl Plus',
      chains: [SupermarketChain.lidl],
      benefit: 'Coupons und Rabatte an der Kasse',
      checkoutHint: 'Lidl Plus öffnen, Coupons aktivieren und die Karte vor dem Bezahlen scannen lassen.',
      appStoreId: '1238611143',
      androidPackage: 'com.lidl.eci.lidl.plus',
    ),
    LoyaltyProgram(
      id: 'payback',
      name: 'PAYBACK',
      appName: 'PAYBACK',
      chains: [],
      benefit: 'Punkte bei PAYBACK-Partnern',
      checkoutHint: 'PAYBACK-App öffnen und die Karte an der Kasse scannen lassen.',
      appStoreId: '363126964',
      androidPackage: 'de.payback.client.android',
      balanceKind: 'points',
    ),
    LoyaltyProgram(
      id: 'dm',
      name: 'Mein dm',
      appName: 'Mein dm',
      chains: [SupermarketChain.dm],
      benefit: 'Coupons an der Kasse',
      checkoutHint: 'Mein dm öffnen und den Code vor dem Bezahlen scannen lassen.',
      appStoreId: '1186271926',
      androidPackage: 'de.dm.meindm.android',
    ),
    LoyaltyProgram(
      id: 'rossmann',
      name: 'Rossmann',
      appName: 'Rossmann',
      chains: [SupermarketChain.rossmann],
      benefit: 'Coupons an der Kasse',
      checkoutHint: 'Rossmann-App öffnen, Coupons aktivieren und den Code vor dem Bezahlen scannen lassen.',
      appLink: 'https://www.rossmann.de/einkaufsportal/service-hilfe/rossmann-app.html',
      appStoreId: '1034309353',
      androidPackage: 'de.rossmann.app.android',
    ),
    LoyaltyProgram(
      id: 'netto',
      name: 'Netto plus',
      appName: 'Netto plus',
      chains: [SupermarketChain.netto],
      benefit: 'Coupons an der Kasse',
      checkoutHint: 'Netto-App öffnen und den Code vor dem Bezahlen scannen lassen.',
      appStoreId: '379404334',
    ),
    LoyaltyProgram(
      id: 'aldi_sued',
      name: 'ALDI SÜD',
      appName: 'ALDI SÜD',
      chains: [SupermarketChain.aldi_sued],
      benefit: 'Prospekt und Angebote, kein Bonusprogramm',
      appStoreId: '379054402',
    ),
    LoyaltyProgram(
      id: 'aldi_nord',
      name: 'ALDI Nord',
      appName: 'ALDI Nord',
      chains: [SupermarketChain.aldi_nord],
      benefit: 'Prospekt und Angebote, kein Bonusprogramm',
      appStoreId: '543651999',
    ),
  ];

  static LoyaltyProgram? byId(String id) {
    for (final p in programs) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Programm, das an der Kasse dieser Kette etwas bringt (für die Kassen-Erinnerung).
  static LoyaltyProgram? forChain(SupermarketChain chain) {
    for (final p in programs) {
      if (p.chains.contains(chain) && p.checkoutHint != null) return p;
    }
    return null;
  }

  static const _keyBalances = 'loyalty_balances_v1';
  static const _keyCheckouts = 'loyalty_checkouts_v1';

  static Map<String, LoyaltyBalance> _balances = {};
  static Map<String, CheckoutRecord> _checkouts = {};
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);


  static LoyaltyBalance? balance(String programId) => _balances[programId];
  static CheckoutRecord? lastCheckout(String programId) => _checkouts[programId];

  static Future<void> load() async {
    final b = await PreferencesStorage.loadJson(_keyBalances);
    if (b is Map) {
      _balances = b.map((k, v) => MapEntry(k.toString(), LoyaltyBalance.fromJson((v as Map).cast<String, dynamic>())));
    }
    final c = await PreferencesStorage.loadJson(_keyCheckouts);
    if (c is Map) {
      _checkouts = c.map((k, v) => MapEntry(k.toString(), CheckoutRecord.fromJson((v as Map).cast<String, dynamic>())));
    }
    revision.value++;
  }

  static Future<void> _save() async {
    revision.value++;
    await PreferencesStorage.saveJson(_keyBalances, _balances.map((k, v) => MapEntry(k, v.toJson())));
    await PreferencesStorage.saveJson(_keyCheckouts, _checkouts.map((k, v) => MapEntry(k, v.toJson())));
  }

  static Future<void> saveBalance(BalanceImport b, {String source = 'Screenshot', DateTime? at}) async {
    _balances[b.programId] = LoyaltyBalance(
      programId: b.programId,
      valueCents: b.valueCents,
      points: b.points,
      at: at ?? DateTime.now(),
      source: source,
    );
    await _save();
  }

  /// Wertet den Treue-Teil eines Kassenbons aus (aus bon.html, Feld `loyalty`).
  static Future<CheckoutRecord?> recordFromReceipt(SupermarketChain chain, DateTime date, Map<String, dynamic>? loyalty) async {
    final programId = loyalty?['program']?.toString() ?? forChain(chain)?.id;
    if (programId == null || byId(programId) == null) return null;
    final record = CheckoutRecord(
      programId: programId,
      date: date,
      scanned: loyalty?['detected'] == true,
      earnedCents: (loyalty?['earned_cents'] as num?)?.toInt(),
      redeemedCents: (loyalty?['redeemed_cents'] as num?)?.toInt(),
      points: (loyalty?['points'] as num?)?.toInt(),
    );
    final prev = _checkouts[programId];
    if (prev == null || !record.date.isBefore(prev.date)) _checkouts[programId] = record;
    final balanceCents = (loyalty?['balance_cents'] as num?)?.toInt();
    final balancePoints = (loyalty?['balance_points'] as num?)?.toInt();
    final current = _balances[programId];
    if ((balanceCents != null || balancePoints != null) && (current == null || !date.isBefore(current.at))) {
      _balances[programId] = LoyaltyBalance(
        programId: programId,
        valueCents: balanceCents,
        points: balancePoints,
        at: date,
        source: 'Kassenbon',
      );
    }
    await _save();
    return record;
  }

  @visibleForTesting
  static void reset() {
    _balances = {};
    _checkouts = {};
  }
}
