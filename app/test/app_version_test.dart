// Versionsanzeige: welcher Build läuft, und liegt ein neuerer bereit?

import 'package:einkaufs_optimierer/core/services/app_version.dart';
import 'package:einkaufs_optimierer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('Neuer nur, wenn der Server einen anderen Commit hat', () {
    expect(AppVersion.isNewer('b2', local: 'a1'), isTrue);
    expect(AppVersion.isNewer('a1', local: 'a1'), isFalse);
    expect(AppVersion.isNewer(null, local: 'a1'), isFalse);
    expect(AppVersion.isNewer('b2', local: 'lokal'), isFalse, reason: 'eigene Builds nie melden');
  });

  test('Lokaler Build zeigt "lokal"', () {
    expect(AppVersion.label, contains('lokal'));
  });

  test('build.json wird ohne Cache abgefragt, Fehler bleiben still', () async {
    Uri? asked;
    final ok = MockClient((req) async {
      asked = req.url;
      return http.Response('{"sha":"zzz9999"}', 200);
    });
    await AppVersion.check(client: ok, base: Uri.parse('https://example.org/app/'));
    expect(asked!.path, '/app/build.json');
    expect(asked!.queryParameters, contains('t'));
    // Im Test ist der eigene Build "lokal": nie als veraltet melden
    expect(AppVersion.updateAvailable.value, isFalse);

    final broken = MockClient((_) async => throw Exception('offline'));
    await AppVersion.check(client: broken, base: Uri.parse('https://example.org/app/'));
  });

  testWidgets('Hinweis oben erscheint, sobald eine neue Version bereitliegt', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: UpdateBanner())));
    expect(find.byKey(const Key('update_banner')), findsNothing);
    AppVersion.updateAvailable.value = true;
    await tester.pump();
    expect(find.text('Neue Version da'), findsOneWidget);
    AppVersion.updateAvailable.value = false;
  });
}
