// app/lib/features/shopping_list/variant_picker.dart
//
// Sorte im Artikel-Blatt: "Egal" (die App nimmt die günstigste) oder eine
// bestimmte Sorte (Bodenhaltung, Freiland, Bio …). Mit Preis "ab".
// Eine Liste zum Antippen, genau eine Zeile ist gewählt (Haken + Rahmen).

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
    final rows = <Widget>[
      _VariantRow(
        key: const Key('variant_any'),
        title: 'Egal',
        subtitle: 'Die App nimmt die günstigste',
        price: group.fromPrice == null ? null : 'ab ${formatCents(group.fromPrice!)}',
        selected: selected == null,
        onTap: () => onChanged(null),
      ),
      for (final p in products)
        _VariantRow(
          key: Key('variant_${p.id}'),
          title: group.variantLabel(p),
          subtitle: p.name == group.variantLabel(p) ? null : p.name,
          price: cheapest(p) == null ? null : formatCents(cheapest(p)!),
          selected: selected?.id == p.id,
          onTap: () => onChanged(p),
        ),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Sorte', style: AppText.section),
      const SizedBox(height: AppSpace.s),
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) const SizedBox(height: AppSpace.xs),
        rows[i],
      ],
    ]);
  }
}

/// Eine wählbare Zeile: Auswahlkreis, Name, darunter der volle Produktname,
/// rechts der Preis in Tabellenziffern.
class _VariantRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? price;
  final bool selected;
  final VoidCallback onTap;

  const _VariantRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      label: [title, if (subtitle != null) subtitle!, if (price != null) price!].join(', '),
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primaryFaint : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
          side: BorderSide(color: selected ? AppColors.primary : AppColors.line, width: selected ? 1.5 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
              child: Row(children: [
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: selected ? AppColors.primary : AppColors.lineStrong,
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body.copyWith(
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? AppColors.primaryDark : AppColors.ink,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.tiny),
                      ],
                    ],
                  ),
                ),
                if (price != null) ...[
                  const SizedBox(width: AppSpace.m),
                  Text(
                    price!,
                    style: AppText.small.copyWith(
                      fontFeatures: AppText.tab,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: selected ? AppColors.primaryDark : AppColors.inkMuted,
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
