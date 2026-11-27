// Suche beim Hinzufügen zur Liste: Reihenfolge nach Treffergüte und Tippfehler.

import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await CatalogService.loadCatalog();
  });

  setUp(CatalogService.clearUsage);

  List<String> names(String q, {int limit = 5}) =>
      CatalogService.getSuggestions(q, limit: limit).map((p) => p.name).toList();

  test('Genauer Alias zuerst, Zusammensetzungen danach', () {
    final r = names('milch');
    expect(r.first, 'Frische Vollmilch 3,5% 1L', reason: 'Alias "milch" passt genau');
    expect(r.indexOf('Oatly Hafermilch Barista 1L'), anyOf(-1, greaterThan(0)));
  });

  test('Wortanfang vor Treffer mitten im Wort', () {
    final r = names('joghurt');
    expect(r.take(2), containsAll(['Naturjoghurt 3,5% 500g', 'Griechischer Joghurt 10% 500g']));
    expect(r.last, 'Zott Sahnejoghurt Erdbeer 150g');
  });

  test('Kein Wortteil-Unsinn vorn: Eier, Cola, Reis, Salat, Lachs, Tee', () {
    expect(names('eier').first, 'Frische Eier Bodenhaltung Gr. M/L 10er', reason: 'nicht "Paprika Dreierpack"');
    expect(names('cola').first, 'Cola 1,5L', reason: 'nicht "Rucola"');
    expect(names('reis').first, 'Basmati Reis 1kg', reason: 'nicht "Milchreis"');
    expect(names('salat').first, 'Eisbergsalat');
    expect(names('lachs').first, 'Lachsfilet frisch mit Haut 300g', reason: 'nicht "Lachsschinken"');
    expect(names('tee').first, 'Schwarzer Tee Ceylon-Assam 50 Beutel', reason: 'nicht "Eistee"');
  });

  test('Ganzes Wort vor längerem Wort: Äpfel vor Apfelessig und Apfelsaft', () {
    final r = names('apfel', limit: 3);
    expect(r.take(2), containsAll(['Äpfel Gala', 'Bio Äpfel Topaz']));
  });

  test('Ganzes Wort vor Wortteil: Gouda-Käse vor Frischkäse', () {
    final r = names('käse', limit: 7);
    expect(r.first, 'Gouda jung in Scheiben 400g', reason: 'Alias "käse scheiben" enthält das ganze Wort');
    expect(r.indexOf('Frischkäse Doppelrahm 200g'), greaterThan(0));
  });

  test('Kurze Eingabe: Wortanfang zählt', () {
    expect(names('spag').first, 'Spaghetti No. 5 500g');
  });

  test('Tippfehler werden verziehen', () {
    expect(names('joghrt'), contains('Naturjoghurt 3,5% 500g'));
    expect(names('jogurt'), contains('Naturjoghurt 3,5% 500g'));
    expect(names('spagetti').first, 'Spaghetti No. 5 500g');
    expect(names('spahgetti'), contains('Spaghetti No. 5 500g'), reason: 'vertauschte Buchstaben');
  });

  test('Umlaute: ae, oe, ue und ä, ö, ü sind gleich', () {
    expect(names('aepfel'), contains('Äpfel Gala'));
    expect(names('kaese'), isNotEmpty);
    expect(names('Käse'), names('kaese'));
  });

  test('Mehrere Wörter müssen alle passen', () {
    final r = names('bio milch');
    expect(r.first, 'Bio Frische Milch 3,8% 1L');
    expect(r, isNot(contains('Frische Vollmilch 3,5% 1L')));
  });

  test('Kurze Wörter ohne Treffer liefern keinen Unsinn', () {
    expect(names('xq'), isEmpty);
    expect(names('abc'), isEmpty);
    expect(names(''), isEmpty);
  });

  test('Eier: alle Eier vor dem Paprika-Dreierpack, auch beim Tippen', () {
    final r = names('eier', limit: 10);
    expect(r.take(3), containsAll(['Frische Eier Bodenhaltung Gr. M/L 10er', 'Bio Eier 10er', 'Freilandeier Gr. M/L 10er']));
    final paprika = r.indexOf('Paprika Dreierpack 500g');
    expect(paprika, anyOf(-1, greaterThan(2)));
    for (final q in ['eie', 'Eier', 'EIER ']) {
      expect(names(q).first, contains('Eier'), reason: q);
    }
  });

  test('Kompositum: letztes Glied zählt ("Freilandeier" sind Eier)', () {
    final r = names('eier', limit: 10);
    expect(r, contains('Freilandeier Gr. M/L 10er'));
    final paprika = r.indexOf('Paprika Dreierpack 500g');
    if (paprika >= 0) expect(r.indexOf('Freilandeier Gr. M/L 10er'), lessThan(paprika));
  });

  test('Oft gekauft gewinnt bei gleicher Güte, nie gegen besseren Treffer', () async {
    final now = DateTime(2026, 11, 27);
    final bio = CatalogService.products.firstWhere((p) => p.name == 'Bio Eier 10er');
    final paprika = CatalogService.products.firstWhere((p) => p.name == 'Paprika Dreierpack 500g');
    // Ohne Gewohnheit: die genaue Alias-Übereinstimmung zuerst
    expect(CatalogService.getSuggestions('eier', now: now).first.name, 'Frische Eier Bodenhaltung Gr. M/L 10er');
    for (var i = 0; i < 5; i++) {
      await CatalogService.recordUsage(paprika.id, now: now);
    }
    await CatalogService.recordUsage(bio.id, now: now);
    final r = CatalogService.getSuggestions('eier', limit: 10, now: now).map((p) => p.name).toList();
    expect(r.first, 'Frische Eier Bodenhaltung Gr. M/L 10er', reason: 'genauer Alias bleibt vorn');
    expect(r.indexOf('Paprika Dreierpack 500g'), anyOf(-1, greaterThan(2)), reason: 'oft gekauft hebt keinen schlechten Treffer');
    // Gleiche Güte (ganzes Wort "milch"): das oft Gekaufte zuerst
    final bioMilch = CatalogService.products.firstWhere((p) => p.name == 'Bio Frische Milch 3,8% 1L');
    final before = CatalogService.getSuggestions('milch', limit: 10, now: now).map((p) => p.name).toList();
    await CatalogService.recordUsage(bioMilch.id, now: now);
    final after = CatalogService.getSuggestions('milch', limit: 10, now: now).map((p) => p.name).toList();
    expect(before, contains(bioMilch.name));
    expect(after.indexOf(bioMilch.name), lessThan(before.indexOf(bioMilch.name)));
  });

  test('Gewohnheit verblasst: vor einem Jahr zählt weniger als letzte Woche', () async {
    final now = DateTime(2026, 11, 27);
    final a = CatalogService.products.firstWhere((p) => p.name == 'Bio Frische Milch 3,8% 1L');
    final b = CatalogService.products.firstWhere((p) => p.name == 'H-Milch fettarm 1,5% 1L');
    for (var i = 0; i < 3; i++) {
      await CatalogService.recordUsage(a.id, now: now.subtract(const Duration(days: 365)));
    }
    await CatalogService.recordUsage(b.id, now: now.subtract(const Duration(days: 7)));
    final r = CatalogService.getSuggestions('milch', limit: 10, now: now).map((p) => p.name).toList();
    expect(r.indexOf(b.name), lessThan(r.indexOf(a.name)));
  });

  test('Gewohnheit übersteht das Neuladen', () async {
    final p = CatalogService.products.firstWhere((p) => p.name == 'Bio Eier 10er');
    await CatalogService.recordUsage(p.id);
    CatalogService.clearUsage();
    await CatalogService.loadUsage();
    final r = CatalogService.getSuggestions('bio').map((p) => p.name).toList();
    expect(r.first, 'Bio Eier 10er');
  });

  test('Kurze Eingabe: nächstes Wort zuerst, "Eigenmarke" zählt nicht', () {
    final r = names('ei');
    expect(r.first, anyOf('Frische Eier Bodenhaltung Gr. M/L 10er', 'Bio Eier 10er'));
    expect(r, isNot(contains('Cola 1,5L')), reason: 'nur "Eigenmarke" passt');
  });

  test('Tippfehler nur, wenn nichts Besseres passt', () {
    expect(names('eier'), isNot(contains('Energy Drink Original 250ml')));
    expect(names('saft'), isNot(contains('Nivea Pflegedusche Creme Soft 250ml')));
    expect(names('joghrt'), contains('Naturjoghurt 3,5% 500g'));
  });

  test('Umlaut weggelassen: kase = käse = kaese', () {
    expect(names('kase'), names('käse'));
    expect(names('kase'), contains('Butterkäse Scheiben 400g'));
  });
}
