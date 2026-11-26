// Zuordnung von Bon- und Freitext zum Katalog (V49).

import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await CatalogService.loadCatalog();
  });

  String? name(String text, {String brandPreference = 'prefer_private_label'}) =>
      CatalogService.matchRawText(text, brandPreference: brandPreference)?.name;

  test('Markenname auf dem Bon schlägt die Eigenmarke', () {
    expect(name('KERRYGOLD BUTTER', brandPreference: 'neutral'), 'Kerrygold Irische Butter 250g');
    expect(name('KERRYGOLD BUTTER'), 'Kerrygold Irische Butter 250g');
    expect(CatalogService.matchCandidates('KERRYGOLD BUTTER').candidates.length, 1, reason: 'keine Rückfrage nötig');
  });

  test('Ohne Marke bleibt es bei der Eigenmarke', () {
    expect(name('butter'), 'Deutsche Markenbutter 250g');
    expect(name('kerrygold'), 'Kerrygold Irische Butter 250g');
  });
}
