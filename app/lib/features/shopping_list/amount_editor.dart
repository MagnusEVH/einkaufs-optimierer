// app/lib/features/shopping_list/amount_editor.dart
//
// Menge im Artikel-Blatt: freiwillig. Einheit wählen, Schnellwahl antippen
// oder mit Plus/Minus feinstellen. "Keine Angabe" setzt zurück.

import 'package:flutter/material.dart';
import '../../core/models/item_amount.dart';
import '../../core/theme/app_theme.dart';

class AmountEditor extends StatelessWidget {
  final ItemAmount amount;

  /// Einheit, die vorgeschlagen wird, solange nichts angegeben ist.
  final AmountUnit suggested;
  final ValueChanged<ItemAmount> onChanged;

  const AmountEditor({super.key, required this.amount, required this.suggested, required this.onChanged});

  static const _units = [
    AmountUnit.stk,
    AmountUnit.g,
    AmountUnit.kg,
    AmountUnit.ml,
    AmountUnit.l,
    AmountUnit.pck,
    AmountUnit.bund,
  ];

  /// Startwert beim Wechsel der Einheit.
  static double _start(AmountUnit u) => switch (u) {
        AmountUnit.g || AmountUnit.ml => 500,
        _ => 1,
      };

  @override
  Widget build(BuildContext context) {
    final none = amount.isDefault;
    final unit = none ? suggested : amount.effectiveUnit;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const Text('Menge', style: AppText.bodyStrong),
        const SizedBox(width: AppSpace.s),
        Expanded(
          child: Text(
            none ? 'keine Angabe' : amount.label,
            key: const Key('amount_value'),
            style: none ? AppText.small : AppText.bodyStrong.copyWith(color: AppColors.primaryDark),
          ),
        ),
        if (!none)
          TextButton(
            key: const Key('amount_clear'),
            onPressed: () => onChanged(ItemAmount.none),
            child: const Text('Keine Angabe'),
          ),
      ]),
      const SizedBox(height: AppSpace.s),
      // Einheit
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final u in _units)
            Padding(
              padding: const EdgeInsets.only(right: AppSpace.xs),
              child: ChoiceChip(
                key: Key('amount_unit_${u.code}'),
                label: Text(u.label),
                selected: !none && u == unit,
                onSelected: (_) => onChanged(ItemAmount(_start(u), u).normalized()),
              ),
            ),
        ]),
      ),
      const SizedBox(height: AppSpace.s),
      // Schnellwahl + Feinstellen
      Row(children: [
        Expanded(
          child: Wrap(spacing: AppSpace.xs, runSpacing: AppSpace.xs, children: [
            for (final q in unit.quick)
              ActionChip(
                key: Key('amount_quick_${unit.code}_${ItemAmount.formatNumber(q)}'),
                label: Text(ItemAmount(q, unit).label.isEmpty ? '1×' : ItemAmount(q, unit).label),
                backgroundColor: !none && amount == ItemAmount(q, unit).normalized() ? AppColors.primaryFaint : null,
                onPressed: () => onChanged(ItemAmount(q, unit).normalized()),
              ),
          ]),
        ),
        IconButton.outlined(
          key: const Key('amount_minus'),
          tooltip: 'Weniger',
          icon: const Icon(Icons.remove),
          onPressed: none ? null : () => onChanged(amount.stepBy(-1)),
        ),
        const SizedBox(width: AppSpace.xs),
        IconButton.filled(
          key: const Key('amount_plus'),
          tooltip: 'Mehr',
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(none ? ItemAmount(_start(unit) + (unit.isCount ? 1 : 0), unit).normalized() : amount.stepBy(1)),
        ),
      ]),
    ]);
  }
}
