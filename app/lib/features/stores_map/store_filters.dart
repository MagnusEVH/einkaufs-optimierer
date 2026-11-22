// app/lib/features/stores_map/store_filters.dart

import '../../core/models/store.dart';

/// Filtert Filialen nach Landkreis und Kategorie ('Alle' = kein Filter).
List<Store> filterStores(
  List<Store> stores, {
  required String district,
  required String chainFilter,
}) {
  return stores.where((s) {
    // 1. District isolation filter
    if (district != 'Alle' && s.district != district) {
      return false;
    }

    // 2. Supermarket chain filter
    if (chainFilter == 'Discounter') {
      return s.chain == SupermarketChain.aldi_sued ||
          s.chain == SupermarketChain.lidl ||
          s.chain == SupermarketChain.netto;
    }
    if (chainFilter == 'Supermarkt') {
      return s.chain == SupermarketChain.rewe;
    }
    if (chainFilter == 'Drogerie') {
      return s.chain == SupermarketChain.dm ||
          s.chain == SupermarketChain.rossmann;
    }
    if (chainFilter == 'Cluster (<500m)') {
      return s.clusterNum != null;
    }

    return true;
  }).toList();
}
