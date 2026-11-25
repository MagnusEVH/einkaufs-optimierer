// app/lib/core/services/balance_scanner.dart
//
// Guthaben aus einem Screenshot lesen, direkt in der App (Texterkennung im
// Browser über web/konto/scan.js). Außerhalb des Browsers nicht verfügbar.

import 'dart:convert';
import 'balance_scanner_stub.dart' if (dart.library.js_interop) 'balance_scanner_web.dart' as impl;
import 'loyalty_service.dart';

class BalanceScanner {
  BalanceScanner._();

  static bool get isSupported => impl.isSupported;

  /// Liest den Stand aus dem Bild unter [imageUrl] (blob:-Adresse vom Bildwähler).
  /// Ergebnis null, wenn kein Stand erkennbar ist.
  static Future<BalanceImport?> scan(String imageUrl, LoyaltyProgram program) async {
    final kind = program.balanceKind ?? 'euro';
    final raw = await impl.scanImage(imageUrl, kind);
    if (raw == null) return null;
    final data = json.decode(raw) as Map<String, dynamic>;
    final cents = (data['value_cents'] as num?)?.toInt();
    final points = (data['points'] as num?)?.toInt();
    if (cents == null && points == null) return null;
    return BalanceImport(programId: program.id, valueCents: cents, points: points);
  }
}
