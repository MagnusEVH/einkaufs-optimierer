import 'package:einkaufs_optimierer/core/models/store.dart';
import 'package:einkaufs_optimierer/features/stores_map/data/rlp_stores.dart';
import 'package:einkaufs_optimierer/features/stores_map/store_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Store> f({String district = 'Alle', String chain = 'Alle'}) =>
      filterStores(rlpStores, district: district, chainFilter: chain);

  test('Alle/Alle liefert den kompletten Datensatz', () {
    expect(f(), hasLength(rlpStores.length));
  });

  test('Landkreis-Filter liefert nur Filialen dieses Landkreises', () {
    for (final d in ['Mainz-Bingen', 'Rhein-Hunsrück']) {
      final r = f(district: d);
      expect(r, isNotEmpty);
      expect(r.every((s) => s.district == d), isTrue);
    }
    expect(
        f(district: 'Mainz-Bingen').length +
            f(district: 'Rhein-Hunsrück').length,
        rlpStores.length);
  });

  test('Discounter = Aldi Süd, Lidl, Netto', () {
    const ok = {
      SupermarketChain.aldi_sued,
      SupermarketChain.lidl,
      SupermarketChain.netto
    };
    final r = f(chain: 'Discounter');
    expect(r, isNotEmpty);
    expect(r.every((s) => ok.contains(s.chain)), isTrue);
  });

  test('Supermarkt = REWE, Drogerie = dm und Rossmann', () {
    expect(
        f(chain: 'Supermarkt').every((s) => s.chain == SupermarketChain.rewe),
        isTrue);
    expect(
        f(chain: 'Drogerie').every((s) =>
            s.chain == SupermarketChain.dm ||
            s.chain == SupermarketChain.rossmann),
        isTrue);
  });

  test('Cluster-Filter liefert nur Filialen mit Cluster', () {
    final r = f(chain: 'Cluster (<500m)');
    expect(r, isNotEmpty);
    expect(r.every((s) => s.clusterNum != null), isTrue);
  });

  test('Landkreis und Kategorie werden kombiniert', () {
    final r = f(district: 'Rhein-Hunsrück', chain: 'Drogerie');
    expect(r.every((s) => s.district == 'Rhein-Hunsrück'), isTrue);
  });

  test('Filial-IDs sind eindeutig', () {
    expect(rlpStores.map((s) => s.id).toSet(), hasLength(rlpStores.length));
  });
}
