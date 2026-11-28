// app/lib/features/shopping_list/variant_picker.dart
//
// Sorte im Artikel-Blatt: "Egal" (die App nimmt die günstigste) oder eine
// bestimmte Sorte (Bodenhaltung, Freiland, Bio …). Mit Preis "ab".

import 'package:flutter/material.dart';
import '../../core/models/product.dart';
import '../../core/services/item_groups.dart';
import '../../core/theme/app_theme.dart';

String formatCents(int cents) => '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';

int? cheapest(Product p) => p.prices.values.isEmpty ? null : p.prices.values.reduce((a, b) => a < b ? a : b);

class VariantPicker extends StatelessWidget {
  final ItemGroup group;

  /// Gewählte Sorte, null = Egal.
  final Product? selected;
  final ValueChanged<Product?> onChanged;

  const VariantPicker({super.key, required this.group, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final products = [...group.products]..sort((a, b) => (cheapest(a) ?? 1 << 30).compareTo(cheapest(b) ?? 1 << 30));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Sorte', style: AppText.bodyStrong),
      const SizedBox(height: AppSpace.s),
      Wrap(spacing: AppSpace.xs, runSpacing: AppSpace.xs, children: [
        ChoiceChip(
          key: const Key('variant_any'),
          label: Text(group.fromPrice == null ? 'Egal' : 'Egal · ab ${formatCents(group.fromPrice!)}'),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final p in products)
          Tooltip(
            message: p.name,
            child: ChoiceChip(
              key: Key('variant_${p.id}'),
              label: Text(cheapest(p) == null ? group.variantLabel(p) : '${group.variantLabel(p)} · ${formatCents(cheapest(p)!)}'),
              selected: selected?.id == p.id,
              onSelected: (_) => onChanged(p),
            ),
          ),
      ]),
      const SizedBox(height: AppSpace.xs),
      Text(
        selected == null ? 'Die App nimmt die günstigste passende Sorte.' : selected!.name,
        style: AppText.small,
      ),
    ]);
  }
}
