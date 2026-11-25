import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:einkaufs_optimierer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EinkaufsOptimiererApp()));
    expect(find.byType(EinkaufsOptimiererApp), findsOneWidget);
    // Standortabfrage der Karte endet spätestens nach 12 s mit dem Standard-Standort
    await tester.pump(const Duration(seconds: 13));
  });
}
