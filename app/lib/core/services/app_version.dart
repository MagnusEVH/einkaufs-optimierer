// app/lib/core/services/app_version.dart
//
// Welche Version läuft, und gibt es eine neuere? Die CI schreibt den Commit
// in die App (--dart-define=BUILD_SHA/BUILD_TIME) und daneben in build.json.
// Die App fragt build.json beim Start, beim Zurückkehren und alle 10 Minuten
// ohne Cache ab. Weicht der Commit ab, liegt eine neuere Version bereit.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AppVersion {
  AppVersion._();

  /// Kurzer Commit, z. B. "a1b2c3d". "lokal" bei eigenen Builds.
  static const sha = String.fromEnvironment('BUILD_SHA', defaultValue: 'lokal');

  /// Build-Zeit in deutscher Zeit, z. B. "27.11. 22:10".
  static const time = String.fromEnvironment('BUILD_TIME', defaultValue: '');

  static String get label => time.isEmpty ? 'Version $sha' : 'Version vom $time · $sha';

  /// true, sobald auf dem Server ein anderer Build liegt.
  static final ValueNotifier<bool> updateAvailable = ValueNotifier(false);

  static Timer? _timer;
  static AppLifecycleListener? _lifecycle;

  /// Regelmäßig nachsehen (nur in echten Builds, nicht lokal oder im Test).
  static void watch() {
    if (!kIsWeb || sha == 'lokal' || _timer != null) return;
    unawaited(check());
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => check());
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(check()));
  }

  static Future<void> check({http.Client? client, Uri? base}) async {
    try {
      final uri = (base ?? Uri.base).resolve('build.json?t=${DateTime.now().millisecondsSinceEpoch}');
      final res = await (client ?? http.Client()).get(uri, headers: {'Cache-Control': 'no-cache'});
      if (res.statusCode != 200) return;
      final remote = (json.decode(res.body) as Map)['sha'] as String?;
      updateAvailable.value = isNewer(remote);
    } catch (_) {
      // offline: beim nächsten Mal
    }
  }

  @visibleForTesting
  static bool isNewer(String? remoteSha, {String local = sha}) =>
      remoteSha != null && remoteSha.isNotEmpty && local != 'lokal' && remoteSha != local;

  @visibleForTesting
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _lifecycle?.dispose();
    _lifecycle = null;
  }
}
