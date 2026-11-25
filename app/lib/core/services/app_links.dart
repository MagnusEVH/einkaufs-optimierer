// app/lib/core/services/app_links.dart
//
// Öffnet fremde Apps, Navigation und die Scan-Seiten (bon.html, konto.html).

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'loyalty_service.dart';

class AppLinks {
  AppLinks._();

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// Ziel für "App öffnen". iPhone: Universal Link öffnet die installierte App,
  /// ohne Link die App-Store-Seite (dort "Öffnen", falls installiert).
  static Uri programAppUri(LoyaltyProgram p) {
    if (p.appLink != null) return Uri.parse(p.appLink!);
    if (_isAndroid && p.androidPackage != null) {
      return Uri.parse('https://play.google.com/store/apps/details?id=${p.androidPackage}');
    }
    return Uri.parse(p.appStoreUrl);
  }

  static Future<bool> openProgramApp(LoyaltyProgram p) =>
      launchUrl(programAppUri(p), mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');

  /// Navigation zum Markt: auf dem iPhone Apple Karten, sonst Google Maps.
  static Uri navigationUri(double lat, double lng) => _isIos
      ? Uri.parse('https://maps.apple.com/?daddr=$lat,$lng')
      : Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

  static Future<bool> openNavigation(double lat, double lng) =>
      launchUrl(navigationUri(lat, lng), mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');

  /// Kassenbon-Scan (Texterkennung im Browser), kommt per #import zurück.
  static Future<bool> openReceiptScan() => launchUrl(Uri.base.resolve('bon.html'), webOnlyWindowName: '_self');

  /// Screenshot der Guthaben-Seite scannen.
  static Future<bool> openBalanceScan(String programId) =>
      launchUrl(Uri.base.resolve('konto.html?program=$programId'), webOnlyWindowName: '_self');
}
