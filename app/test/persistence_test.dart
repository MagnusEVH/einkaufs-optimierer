// V16: Einkaufsliste und Einstellungen überstehen einen Neustart (Demo-Modus).
// Im Test gibt es kein Secure-Storage-Plugin; PreferencesStorage nutzt dann
// seinen Zwischenspeicher. Geprüft wird der Weg Controller → Speicher → Controller.

import 'package:einkaufs_optimierer/core/models/user_preferences.dart';
import 'package:einkaufs_optimierer/core/services/preferences_storage.dart';
import 'package:einkaufs_optimierer/core/services/supabase_service.dart';
import 'package:einkaufs_optimierer/features/shopping_list/shopping_list_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ShoppingListController> _loaded() async {
  final c = ShoppingListController();
  await c.loadInitialItems();
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(PreferencesStorage.clearMemoryCache);

  test('erster Start zeigt den Beispielkorb', () async {
    final c = await _loaded();
    expect(c.state.items, isNotEmpty);
  });

  test('Liste mit Änderungen kommt nach Neustart zurück', () async {
    final first = await _loaded();
    first.clearList();
    first.addItem('bananen');
    first.addItem('vollmilch');
    first.toggleChecked(first.state.items.last.id);

    final second = await _loaded();
    final texts = second.state.items.map((i) => i.rawText).toList();
    expect(texts, ['vollmilch', 'bananen']); // neue Artikel stehen oben
    expect(second.state.items.firstWhere((i) => i.rawText == 'bananen').isChecked, isTrue);
    expect(second.state.items.first.matchedProduct, isNotNull, reason: 'Produkt über ID wiederhergestellt');
  });

  test('geleerte Liste bleibt leer statt Beispielkorb', () async {
    final first = await _loaded();
    first.clearList();
    final second = await _loaded();
    expect(second.state.items, isEmpty);
  });

  test('Einstellungen kommen nach Neustart zurück', () async {
    await SupabaseService.savePreferences(
      const UserPreferences(bioPreference: 'prefer_bio', maxStops: 1, preferredChains: ['lidl']),
    );
    final prefs = await SupabaseService.fetchPreferences();
    expect(prefs.bioPreference, 'prefer_bio');
    expect(prefs.maxStops, 1);
    expect(prefs.preferredChains, ['lidl']);
  });
}
