// app/lib/features/shopping_list/amount_editor.dart
//
// Menge im Artikel-Blatt: freiwillig. Oben der aktuelle Wert mit Plus/Minus,
// darunter Einheit und Schnellwahl. "Keine Angabe" setzt zurück.

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
      // Kopf: "Menge", rechts Zurücksetzen (nur wenn etwas angegeben ist)
      SizedBox(
        height: 44,
        child: Row(children: [
          const Text('Menge', style: AppText.section),
          const SizedBox(width: AppSpace.s),
          const Text('freiwillig', style: AppText.tiny),
          const Spacer(),
          if (!none)
            TextButton(
              key: const Key('amount_clear'),
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.s),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              onPressed: () => onChanged(ItemAmount.none),
              child: const Text('Keine Angabe'),
            ),
        ]),
      ),
      const SizedBox(height: AppSpace.xs),
      // Wert mit Plus/Minus
      Container(
        padding: const EdgeInsets.all(AppSpace.xs),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: AppRadius.medium),
        child: Row(children: [
          _StepButton(
            key: const Key('amount_minus'),
            tooltip: 'Weniger',
            icon: Icons.remove_rounded,
            onPressed: none ? null : () => onChanged(amount.stepBy(-1)),
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                none ? 'keine Angabe' : amount.label,
                key: const Key('amount_value'),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: none
                    ? AppText.body.copyWith(color: AppColors.inkSubtle)
                    : AppText.title.copyWith(fontFeatures: AppText.tab, color: AppColors.ink),
              ),
            ),
          ),
          _StepButton(
            key: const Key('amount_plus'),
            tooltip: 'Mehr',
            icon: Icons.add_rounded,
            onPressed: () =>
                onChanged(none ? ItemAmount(_start(unit) + (unit.isCount ? 1 : 0), unit).normalized() : amount.stepBy(1)),
          ),
        ]),
      ),
      const SizedBox(height: AppSpace.m),
      // Einheit
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(children: [
          for (final u in _units)
            Padding(
              padding: const EdgeInsets.only(right: AppSpace.xs),
              child: _Pill(
                key: Key('amount_unit_${u.code}'),
                label: u.label,
                selected: !none && u == unit,
                onTap: () => onChanged(ItemAmount(_start(u), u).normalized()),
              ),
            ),
        ]),
      ),
      // Schnellwahl
      Wrap(spacing: AppSpace.xs, children: [
        for (final q in unit.quick)
          _Pill(
            key: Key('amount_quick_${unit.code}_${ItemAmount.formatNumber(q)}'),
            label: ItemAmount(q, unit).label.isEmpty ? '1×' : ItemAmount(q, unit).label,
            selected: !none && amount == ItemAmount(q, unit).normalized(),
            outlined: true,
            onTap: () => onChanged(ItemAmount(q, unit).normalized()),
          ),
      ]),
    ]);
  }
}

/// Runder Plus/Minus-Knopf, 44 px.
class _StepButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  const _StepButton({super.key, required this.tooltip, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        minimumSize: const Size(44, 44),
        backgroundColor: AppColors.surface,
        disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.5),
        foregroundColor: AppColors.primaryDark,
        disabledForegroundColor: AppColors.lineStrong,
        side: BorderSide(color: enabled ? AppColors.lineStrong : AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
    );
  }
}

/// Kompakter Auswahlknopf. Sichtbar 36 px hoch, antippbar 44 px.
/// Gewählt: grüner Grund, Rahmen und fette Schrift (nicht nur Farbe).
class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool outlined;
  final VoidCallback onTap;
  const _Pill({super.key, required this.label, required this.selected, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primarySoft : (outlined ? AppColors.surface : AppColors.surfaceAlt);
    final border = selected ? AppColors.primary : (outlined ? AppColors.lineStrong : Colors.transparent);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 36,
            constraints: const BoxConstraints(minWidth: 44),
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.small,
              border: Border.all(color: border, width: selected ? 1.5 : 1),
            ),
            // widthFactor 1: so breit wie der Text, nicht wie die Zeile
            child: Align(
              widthFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFeatures: AppText.tab,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.primaryDark : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
