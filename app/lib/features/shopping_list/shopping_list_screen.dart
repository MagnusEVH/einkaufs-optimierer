// app/lib/features/shopping_list/shopping_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product.dart';
import '../../core/services/catalog_service.dart';
import '../optimizer/optimizer_screen.dart';
import 'shopping_list_controller.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Product> _suggestions = [];

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final results = CatalogService.getSuggestions(query, limit: 4);
    setState(() => _suggestions = results);
  }

  void _submitItem([Product? selectedProduct]) {
    final text = _inputController.text.trim();
    if (text.isEmpty && selectedProduct == null) return;

    final itemTitle = selectedProduct?.name ?? text;
    ref.read(shoppingListProvider.notifier).addItem(
          itemTitle,
          matchedProduct: selectedProduct,
        );

    _inputController.clear();
    setState(() => _suggestions = []);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shoppingListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shopping_bag_outlined, color: Colors.teal),
            SizedBox(width: 8),
            Text('Einkaufs-Optimierer', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Liste leeren',
            onPressed: state.items.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Liste leeren?'),
                        content: const Text('Möchtest du alle Artikel von der Liste entfernen?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
                          FilledButton(
                            onPressed: () {
                              ref.read(shoppingListProvider.notifier).clearList();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Leeren'),
                          ),
                        ],
                      ),
                    );
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // Input Header Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) => _submitItem(),
                  decoration: InputDecoration(
                    hintText: 'Artikel hinzufügen (z. B. Skyr, Bio Eier, ja!...)',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF059669)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF059669)),
                      onPressed: () => _submitItem(),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),

                // Quick Add Chips
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        'Schnellwahl:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 8),
                      ...['Skyr Natur', 'Vollmilch', 'Markenbutter', 'Bananen', 'Toilettenpapier', 'Haferflocken'].map((quickItem) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            label: Text(
                              '+ $quickItem',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                            ),
                            backgroundColor: const Color(0xFFD1FAE5),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onPressed: () {
                              ref.read(shoppingListProvider.notifier).addItem(quickItem);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Autocomplete Suggestions
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final prod = _suggestions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.shopping_basket_outlined, color: Color(0xFF059669), size: 20),
                          title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            prod.isBio ? 'Bio-Produkt' : (prod.brand ?? 'Eigenmarke'),
                            style: TextStyle(fontSize: 12, color: prod.isBio ? Colors.green.shade700 : Colors.grey),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () => _submitItem(prod),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Items Count Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.items.length} Artikel auf der Liste',
                  style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    '6 Ketten aktiv (Lidl, Aldi, Rewe, Netto, dm, Rossmann)',
                    style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          // Shopping List Items
          Expanded(
            child: state.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('Deine Einkaufsliste ist leer.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('Gib oben einen Artikel ein, um zu beginnen.', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: state.items.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      final isMatched = item.matchedProduct != null;

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref.read(shoppingListProvider.notifier).removeItem(item.id);
                        },
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: item.isChecked,
                                  activeColor: Colors.teal,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (_) {
                                    ref.read(shoppingListProvider.notifier).toggleChecked(item.id);
                                  },
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.rawText,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                          color: item.isChecked ? Colors.grey : null,
                                        ),
                                      ),
                                      if (isMatched) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.teal.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                item.matchedProduct!.isBio
                                                    ? '🌱 Bio'
                                                    : (item.matchedProduct!.brand ?? 'Basis'),
                                                style: TextStyle(fontSize: 11, color: Colors.teal.shade800, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Katalog-Treffer',
                                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Quantity Stepper
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      color: Colors.grey.shade600,
                                      onPressed: () {
                                        ref.read(shoppingListProvider.notifier).updateQuantity(item.id, -1);
                                      },
                                    ),
                                    Text(
                                      '${item.quantity.toInt()}x',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      color: Colors.teal,
                                      onPressed: () {
                                        ref.read(shoppingListProvider.notifier).updateQuantity(item.id, 1);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
            ],
            border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
          ),
          child: FilledButton.icon(
            icon: const Icon(Icons.bolt_rounded, size: 22),
            label: Text(
              'Günstigste Route berechnen (${state.items.length} Artikel)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            onPressed: state.items.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OptimizerResultScreen(),
                      ),
                    );
                  },
          ),
        ),
      ),
    );
  }
}
