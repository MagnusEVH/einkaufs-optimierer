// app/lib/features/shopping_list/shopping_list_controller.dart
//
// Einkaufsliste. Zwei Betriebsarten:
// - lokal (ohne Konto oder ohne Haushalt): Liste nur auf diesem Gerät
// - gemeinsam (angemeldet, Haushalt gewählt): Liste des Haushalts über
//   ListSync (Server, Warteschlange, Zwischenspeicher, Realtime)

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/item_amount.dart';
import '../../core/models/list_item.dart';
import '../../core/models/product.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/household_service.dart';
import '../../core/services/list_sync.dart';
import '../../core/services/preferences_storage.dart';
import '../../core/services/supabase_service.dart';

class ShoppingListState {
  final List<ShoppingListItem> items;
  final bool isLoading;
  final String? errorMessage;

  /// Gemeinsame Liste eines Haushalts (sonst nur auf diesem Gerät).
  final bool shared;

  /// Änderungen, die noch nicht beim Server sind.
  final int pendingCount;
  final SyncProblem? problem;

  /// Artikel der Geräte-Liste, die man in den Haushalt übernehmen kann.
  final int importable;

  /// Server verlangt eine neuere App.
  final bool needsReload;

  const ShoppingListState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.shared = false,
    this.pendingCount = 0,
    this.problem,
    this.importable = 0,
    this.needsReload = false,
  });

  ShoppingListState copyWith({
    List<ShoppingListItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ShoppingListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      shared: shared,
      pendingCount: pendingCount,
      problem: problem,
      importable: importable,
      needsReload: needsReload,
    );
  }
}

class ShoppingListController extends StateNotifier<ShoppingListState> {
  /// [remote] nur für Tests, sonst Supabase.
  ShoppingListController({this.remote}) : super(const ShoppingListState()) {
    _localReady = loadInitialItems();
  }

  final ListRemote? remote;
  static const _uuid = Uuid();
  final String activeListId = '00000000-0000-0000-0000-000000000001';

  late Future<void> _localReady;
  List<ShoppingListItem> _local = const [];
  ListSync? _sync;
  Timer? _retry;
  AppLifecycleListener? _lifecycle;
  int _ticks = 0;
  int _importable = 0;
  bool _needsReload = false;

  static const _keyImportAsked = 'list_import_asked_v1';

  ListSync? get sync => _sync;

  Future<void> loadInitialItems() async {
    state = state.copyWith(isLoading: true);
    await CatalogService.loadCatalog();
    await CatalogService.loadUsage();

    final localItems = await _loadLocalItems();
    if (localItems != null) {
      _local = localItems;
    } else {
      // Beispielkorb für den ersten Start
      _local = [
        _createItem('Somat Gold', quantity: 2),
        _createItem('Kerrygold', quantity: 2),
        _createItem('Skyr', quantity: 2),
        _createItem('Barilla Spaghetti', quantity: 3),
        _createItem('Ritter Sport', quantity: 3),
        _createItem('Ristorante', quantity: 2),
      ];
    }
    if (_sync == null) state = state.copyWith(items: _local, isLoading: false);
  }

  /// Lokal gespeicherte Liste, oder null beim ersten Start.
  Future<List<ShoppingListItem>?> _loadLocalItems() async {
    final raw = await PreferencesStorage.loadShoppingList();
    if (raw == null) return null;
    return raw.map((m) {
      final id = m['matched_product_id'] as String?;
      final byId = id == null ? const <Product>[] : CatalogService.products.where((p) => p.id == id);
      return ShoppingListItem.fromJson(m, matched: byId.isNotEmpty ? byId.first : null);
    }).toList();
  }

  // ── Haushalt wechseln ────────────────────────────────────────────────────

  /// null = lokale Liste. Sonst die gemeinsame Liste dieses Haushalts.
  Future<void> attachHousehold(String? householdId) async {
    if (householdId == _sync?.householdId) return;
    _detach();
    await _localReady;
    if (householdId == null) {
      state = ShoppingListState(items: _local);
      return;
    }
    final s = ListSync(remote ?? const SupabaseListRemote(), householdId);
    _sync = s;
    s.onChanged = () {
      if (identical(_sync, s)) _showSync();
    };
    state = const ShoppingListState(shared: true, isLoading: true);
    _retry = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(s.sync()));
    await s.open();
    if (!identical(_sync, s)) return;
    final asked = await PreferencesStorage.loadJson(_keyImportAsked) == true;
    _importable = asked ? 0 : _local.where((i) => !i.isChecked).length;
    _needsReload = await SupabaseService.needsReload();
    _showSync();
  }

  void _detach() {
    _sync?.close();
    _sync = null;
    _retry?.cancel();
    _retry = null;
    _lifecycle?.dispose();
    _lifecycle = null;
  }

  /// Alle 30 s: bei Problemen oder Wartendem erneut, sonst alle 2 Min. nachladen
  /// (falls ein Realtime-Signal verloren ging).
  void _tick() {
    final s = _sync;
    if (s == null) return;
    _ticks++;
    if (s.problem != null || s.pendingCount > 0 || _ticks % 4 == 0) unawaited(s.sync());
  }

  void _showSync() {
    final s = _sync;
    if (s == null) return;
    state = ShoppingListState(
      items: [for (final r in s.rows.reversed) _fromRow(r)],
      shared: true,
      pendingCount: s.pendingCount,
      problem: s.problem,
      importable: _importable,
      needsReload: _needsReload,
      errorMessage: s.droppedMessage,
    );
  }

  ShoppingListItem _fromRow(ListRow r) {
    final byId = r.productId == null ? null : CatalogService.products.where((p) => p.id == r.productId).firstOrNull;
    return ShoppingListItem(
      id: r.id,
      listId: r.householdId,
      rawText: r.rawText,
      matchedProduct: byId ?? CatalogService.matchRawText(r.rawText),
      pinned: byId != null,
      quantity: r.quantity,
      unit: r.unit,
      isChecked: r.checked,
      notes: r.note,
    );
  }

  /// Erste Anmeldung: Liste von diesem Gerät in den Haushalt übernehmen.
  /// Was dort schon steht (gleicher Name), kommt nicht doppelt.
  Future<void> importLocal() async {
    final s = _sync;
    if (s == null) return;
    await PreferencesStorage.saveJson(_keyImportAsked, true);
    _importable = 0;
    final existing = {for (final r in s.rows) r.rawText.toLowerCase()};
    for (final it in _local.reversed) {
      if (it.isChecked || existing.contains(it.rawText.toLowerCase())) continue;
      await s.add(ListRow(
        id: _uuid.v4(),
        householdId: s.householdId,
        rawText: it.rawText,
        productId: it.pinned ? it.matchedProduct?.id : null,
        quantity: it.quantity,
        unit: it.unit,
        note: it.notes,
      ));
    }
    _showSync();
  }

  Future<void> declineImport() async {
    await PreferencesStorage.saveJson(_keyImportAsked, true);
    _importable = 0;
    _showSync();
  }

  /// Sofort abgleichen (Knopf "Erneut versuchen").
  Future<void> syncNow() async => _sync?.sync();

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  // ── Lokale Liste ─────────────────────────────────────────────────────────

  /// Setzt die lokale Liste und speichert sie, damit sie das Neuladen übersteht.
  void _setItems(List<ShoppingListItem> items) {
    _local = items;
    state = state.copyWith(items: items);
    PreferencesStorage.saveShoppingList(items.map((it) => it.toJson()).toList());
  }

  ShoppingListItem _createItem(String text, {double quantity = 1.0, String? unit, Product? product}) {
    final matched = product ?? CatalogService.matchRawText(text);
    return ShoppingListItem(
      id: _uuid.v4(),
      listId: activeListId,
      rawText: text,
      matchedProduct: matched,
      quantity: quantity,
      unit: unit,
      isChecked: false,
    );
  }

  // ── Änderungen (lokal oder gemeinsam) ────────────────────────────────────

  /// Neuer Artikel. Aus dem Text wird die Menge gelesen ("500 g Erdbeeren"
  /// → Erdbeeren, 500 g). Bei einem gewählten Produkt steht nur das Ding an
  /// sich auf der Liste ("Erdbeeren"), Marke und Größe nicht.
  ///
  /// [matchedProduct] ist eine ausdrücklich gewählte Sorte (pinned).
  /// [name] überschreibt den Namen, z. B. den Grundartikel "Eier".
  /// Liefert die ID des neuen Artikels (null, wenn nichts angelegt wurde).
  String? addItem(String text, {Product? matchedProduct, ItemAmount? amount, String? name}) {
    if (text.trim().isEmpty && matchedProduct == null && name == null) return null;
    final parsed = parseItemInput(text);
    final label = name ?? (matchedProduct != null ? genericName(matchedProduct) : parsed.name);
    if (label.isEmpty) return null;
    final a = amount ?? parsed.amount;
    final item = _createItem(label,
            quantity: a.quantity, unit: a.isDefault ? null : a.unit?.code, product: matchedProduct)
        .copyWith(pinned: matchedProduct != null);
    final s = _sync;
    if (s != null) {
      s.add(ListRow(
        id: item.id,
        householdId: s.householdId,
        rawText: item.rawText,
        // Nur eine gewählte Sorte geht an den Server; sonst sucht jedes Gerät selbst
        productId: matchedProduct?.id,
        quantity: item.quantity,
        unit: item.unit,
      ));
    } else {
      _setItems([item, ...state.items]);
    }
    final matched = item.matchedProduct;
    if (matched != null) CatalogService.recordUsage(matched.id);

    AnalyticsService.trackShoppingListItemAdded(
      item.rawText,
      category: item.matchedProduct?.categoryId,
    );
    return item.id;
  }

  /// Sorte wählen ("Freiland") oder offen lassen (null: die App nimmt die
  /// günstigste passende). Der Name auf der Liste bleibt ("Eier").
  void chooseVariant(String id, Product? product) {
    if (product != null) CatalogService.recordUsage(product.id);
    final s = _sync;
    if (s != null) {
      s.patch(id, {'product_id': product?.id});
      return;
    }
    _setItems(state.items
        .map((it) => it.id != id ? it : it.withVariant(product, fallback: CatalogService.matchRawText(it.rawText)))
        .toList());
  }

  /// Ordnet einem Artikel ausdrücklich ein Katalogprodukt zu (Rückfrage bei
  /// unsicherer Freitext-Zuordnung). Auf der Liste steht danach das Ding an
  /// sich ("Erdbeeren"), das Produkt bleibt über die ID gemerkt.
  void assignProduct(String id, Product product) {
    CatalogService.recordUsage(product.id);
    final name = genericName(product);
    final s = _sync;
    if (s != null) {
      s.patch(id, {'raw_text': name, 'product_id': product.id});
      return;
    }
    _setItems(
      state.items
          .map((it) => it.id != id ? it : it.copyWith(rawText: name, matchedProduct: product, pinned: true))
          .toList(),
    );
  }

  /// Menge setzen, auch zurück auf "keine Angabe" ([ItemAmount.none]).
  void setAmount(String id, ItemAmount amount) {
    final a = amount.normalized();
    final unit = a.isDefault ? null : a.unit?.code;
    final s = _sync;
    if (s != null) {
      s.patch(id, {'quantity': a.quantity, 'unit': unit});
      return;
    }
    _setItems(state.items.map((it) => it.id == id ? it.withAmount(a) : it).toList());
  }

  /// Plus/Minus: ein Schritt in der Einheit des Artikels (Stück 1, g 50 …).
  void updateQuantity(String id, double delta) {
    final current = state.items.where((it) => it.id == id).firstOrNull;
    if (current == null) return;
    setAmount(id, current.amount.stepBy(delta.sign.toInt()));
  }

  void toggleChecked(String id) {
    final current = state.items.where((it) => it.id == id).firstOrNull;
    if (current == null) return;
    final newChecked = !current.isChecked;
    AnalyticsService.trackShoppingListItemCompleted(current.rawText, isChecked: newChecked);
    final s = _sync;
    if (s != null) {
      s.setChecked(id, newChecked);
      return;
    }
    _setItems(state.items.map((it) => it.id == id ? it.copyWith(isChecked: newChecked) : it).toList());
  }

  void removeItem(String id) {
    final itemToRemove = state.items.where((it) => it.id == id).firstOrNull;
    final s = _sync;
    if (s != null) {
      s.delete(id);
    } else {
      _setItems(state.items.where((it) => it.id != id).toList());
    }
    if (itemToRemove != null) {
      AnalyticsService.trackEvent(
        'shopping_list_item_removed',
        category: 'shopping_list',
        properties: {'product_name': itemToRemove.rawText},
      );
    }
  }

  /// Entfernt mehrere Artikel auf einmal (Abschluss eines Einkaufs).
  void removeItems(Set<String> ids) {
    if (ids.isEmpty) return;
    final s = _sync;
    if (s != null) {
      for (final id in ids) {
        s.delete(id);
      }
      return;
    }
    _setItems(state.items.where((it) => !ids.contains(it.id)).toList());
  }

  void clearList() {
    final s = _sync;
    if (s != null) {
      for (final it in state.items) {
        s.delete(it.id);
      }
      return;
    }
    _setItems([]);
  }
}

/// Fake-Server für Tests der gemeinsamen Liste, sonst Supabase.
final listRemoteProvider = Provider<ListRemote?>((ref) => null);

final shoppingListProvider = StateNotifierProvider<ShoppingListController, ShoppingListState>((ref) {
  final controller = ShoppingListController(remote: ref.watch(listRemoteProvider));
  // Gemeinsame Liste nur angemeldet mit Haushalt, sonst lokal
  ref.listen<HouseholdState>(
    householdProvider,
    (_, next) {
      final available = ref.read(householdApiProvider).available;
      controller.attachHousehold(available ? next.current?.id : null);
    },
    fireImmediately: true,
  );
  return controller;
});
