// app/lib/core/services/my_stores_service.dart
//
// "Meine Märkte": welche Filialen der Optimierer nutzen darf und in welcher
// Reihenfolge die Warengruppen im jeweiligen Markt liegen (für den Einkaufsmodus).
// Nur lokal gespeichert.

import 'package:flutter/foundation.dart';
import 'item_icons.dart';
import 'preferences_storage.dart';

class MyStoresService {
  MyStoresService._();

  static const _key = 'my_stores_v1';

  static Set<String> _disabled = {};
  static Map<String, List<String>> _categoryOrder = {};

  /// Steigt bei jeder Änderung, damit Screens neu zeichnen.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Set<String> get disabledStoreIds => Set.unmodifiable(_disabled);

  static bool isActive(String storeId) => !_disabled.contains(storeId);

  static Future<void> load() async {
    final raw = await PreferencesStorage.loadJson(_key);
    if (raw is! Map) return;
    _disabled = ((raw['disabled'] as List?) ?? const []).map((e) => e.toString()).toSet();
    final order = raw['category_order'];
    _categoryOrder = order is Map
        ? order.map((k, v) => MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList()))
        : {};
    revision.value++;
  }

  static Future<void> _save() async {
    revision.value++;
    await PreferencesStorage.saveJson(_key, {
      'disabled': _disabled.toList(),
      'category_order': _categoryOrder,
    });
  }

  static Future<void> setActive(String storeId, bool active) async {
    if (active) {
      _disabled.remove(storeId);
    } else {
      _disabled.add(storeId);
    }
    await _save();
  }

  /// Reihenfolge der Warengruppen für eine Kette (Standard: ungefährer Weg durch den Markt).
  static List<String> categoryOrder(String chain) {
    final saved = _categoryOrder[chain];
    final defaults = ItemIcons.defaultOrder;
    if (saved == null) return defaults;
    // Neue Warengruppen hinten anhängen, unbekannte verwerfen
    return [
      ...saved.where(defaults.contains),
      ...defaults.where((c) => !saved.contains(c)),
    ];
  }

  static Future<void> setCategoryOrder(String chain, List<String> order) async {
    _categoryOrder[chain] = List.of(order);
    await _save();
  }

  @visibleForTesting
  static void reset() {
    _disabled = {};
    _categoryOrder = {};
  }
}
