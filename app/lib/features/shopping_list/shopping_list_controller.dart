// app/lib/features/shopping_list/shopping_list_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/list_item.dart';
import '../../core/models/product.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/catalog_service.dart';
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

    final remoteItems = await SupabaseService.fetchListItems(activeListId);
    if (remoteItems.isNotEmpty) {
      state = state.copyWith(items: remoteItems, isLoading: false);
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
    state = state.copyWith(items: [item, ...state.items]);
    SupabaseService.saveListItem(item);

    AnalyticsService.trackShoppingListItemAdded(
      item.rawText,
      category: item.matchedProduct?.categoryId,
    );
  }

  void updateQuantity(String id, double delta) {
    state = state.copyWith(
      items: state.items.map((it) {
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
    state = state.copyWith(
      items: state.items.map((it) {
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

    state = state.copyWith(
      items: state.items.where((it) => it.id != id).toList(),
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

  void clearList() {
    state = state.copyWith(items: []);
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListController, ShoppingListState>((ref) {
  return ShoppingListController();
});
