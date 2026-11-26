// Suche beim Hinzufügen zur Liste: Reihenfolge nach Treffergüte und Tippfehler.

import 'package:einkaufs_optimierer/core/services/catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await CatalogService.loadCatalog();
  });

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
}
