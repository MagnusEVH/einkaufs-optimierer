// app/lib/features/shopping_list/shopping_list_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/list_item.dart';
import '../../core/models/product.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/preferences_storage.dart';
import '../../core/services/supabase_service.dart';

class ShoppingListState {
  final List<ShoppingListItem> items;
  final bool isLoading;
  final String? errorMessage;

  const ShoppingListState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
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
    );
  }
}

class ShoppingListController extends StateNotifier<ShoppingListState> {
  ShoppingListController() : super(const ShoppingListState()) {
    loadInitialItems();
  }

  static const _uuid = Uuid();
  final String activeListId = '00000000-0000-0000-0000-000000000001';

  Future<void> loadInitialItems() async {
    state = state.copyWith(isLoading: true);
    await CatalogService.loadCatalog();
    await CatalogService.loadUsage();

    final remoteItems = await SupabaseService.fetchListItems(activeListId);
    final localItems = remoteItems.isEmpty ? await _loadLocalItems() : null;
    if (remoteItems.isNotEmpty) {
      state = state.copyWith(items: remoteItems, isLoading: false);
    } else if (localItems != null) {
      state = state.copyWith(items: localItems, isLoading: false);
    } else {
      // Default initial sample basket for instant testability
      final initialBasket = [
        _createItem('Somat Gold', quantity: 2),
        _createItem('Kerrygold', quantity: 2),
        _createItem('Skyr', quantity: 2),
        _createItem('Barilla Spaghetti', quantity: 3),
        _createItem('Ritter Sport', quantity: 3),
        _createItem('Ristorante', quantity: 2),
      ];
      state = state.copyWith(items: initialBasket, isLoading: false);
    }
  }

  /// Lokal gespeicherte Liste (Demo-Modus), oder null beim ersten Start.
  Future<List<ShoppingListItem>?> _loadLocalItems() async {
    final raw = await PreferencesStorage.loadShoppingList();
    if (raw == null) return null;
    return raw.map((m) {
      final id = m['matched_product_id'] as String?;
      final byId = id == null ? const <Product>[] : CatalogService.products.where((p) => p.id == id);
      return ShoppingListItem.fromJson(m, matched: byId.isNotEmpty ? byId.first : null);
    }).toList();
  }

  /// Setzt die Liste und speichert sie lokal, damit sie das Neuladen übersteht.
  void _setItems(List<ShoppingListItem> items) {
    state = state.copyWith(items: items);
    PreferencesStorage.saveShoppingList(items.map((it) => it.toJson()).toList());
  }

  ShoppingListItem _createItem(String text, {double quantity = 1.0, Product? product}) {
    final matched = product ?? CatalogService.matchRawText(text);
    return ShoppingListItem(
      id: _uuid.v4(),
      listId: activeListId,
      rawText: text,
      matchedProduct: matched,
      quantity: quantity,
      isChecked: false,
    );
  }

  void addItem(String text, {Product? matchedProduct, double quantity = 1.0}) {
    if (text.trim().isEmpty) return;
    final item = _createItem(text.trim(), quantity: quantity, product: matchedProduct);
    _setItems([item, ...state.items]);
    SupabaseService.saveListItem(item);
    final matched = item.matchedProduct;
    if (matched != null) CatalogService.recordUsage(matched.id);

    AnalyticsService.trackShoppingListItemAdded(
      item.rawText,
      category: item.matchedProduct?.categoryId,
    );
  }

  /// Ordnet einem Artikel ausdrücklich ein Katalogprodukt zu (Rückfrage bei
  /// unsicherer Freitext-Zuordnung). Der Name wird übernommen, damit der
  /// Optimierer die Wahl nicht wieder überschreibt.
  void assignProduct(String id, Product product) {
    _setItems(
      state.items.map((it) {
        if (it.id != id) return it;
        final updated = it.copyWith(rawText: product.name, matchedProduct: product);
        SupabaseService.saveListItem(updated);
        CatalogService.recordUsage(product.id);
        return updated;
      }).toList(),
    );
  }

  void updateQuantity(String id, double delta) {
    _setItems(
      state.items.map((it) {
        if (it.id == id) {
          final newQty = (it.quantity + delta).clamp(1.0, 99.0);
          final updated = it.copyWith(quantity: newQty);
          SupabaseService.saveListItem(updated);
          return updated;
        }
        return it;
      }).toList(),
    );
  }

  void toggleChecked(String id) {
    _setItems(
      state.items.map((it) {
        if (it.id == id) {
          final newChecked = !it.isChecked;
          final updated = it.copyWith(isChecked: newChecked);
          SupabaseService.saveListItem(updated);

          AnalyticsService.trackShoppingListItemCompleted(
            it.rawText,
            isChecked: newChecked,
          );

          return updated;
        }
        return it;
      }).toList(),
    );
  }

  void removeItem(String id) {
    final itemToRemove = state.items.firstWhere(
      (it) => it.id == id,
      orElse: () => _createItem(''),
    );

    _setItems(
      state.items.where((it) => it.id != id).toList(),
    );
    SupabaseService.deleteListItem(id);

    if (itemToRemove.rawText.isNotEmpty) {
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
    _setItems(state.items.where((it) => !ids.contains(it.id)).toList());
    for (final id in ids) {
      SupabaseService.deleteListItem(id);
    }
  }

  void clearList() {
    _setItems([]);
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListController, ShoppingListState>((ref) {
  return ShoppingListController();
});
