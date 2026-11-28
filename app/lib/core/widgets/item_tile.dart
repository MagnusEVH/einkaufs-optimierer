// app/lib/core/widgets/item_tile.dart
//
// Artikel-Kachel mit Icon (Vorbild: Bring!) und Artikel-Zeile für die Listenansicht.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ItemIconBox extends StatelessWidget {
  final String icon;
  final double size;
  final bool dimmed;
  const ItemIconBox(this.icon, {super.key, this.size = 44, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.primaryFaint, borderRadius: BorderRadius.circular(size * 0.28)),
        child: Text(icon, style: TextStyle(fontSize: size * 0.56, height: 1.1)),
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final String icon;
  final String name;
  /// Menge wie "500 g" oder "2×", leer = keine Angabe.
  final String amount;
  final bool needsCheck;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ItemTile({
    super.key,
    required this.icon,
    required this.name,
    this.amount = '',
    this.needsCheck = false,
    this.done = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bg = done ? AppColors.surfaceAlt : (needsCheck ? AppColors.warningSoft : AppColors.surface);
    final border = needsCheck ? AppColors.warningLine : AppColors.line;
    return Semantics(
      button: true,
      label: '$name${amount.isNotEmpty ? ', $amount' : ''}${needsCheck ? ', bitte prüfen' : ''}${done ? ', erledigt' : ''}',
      child: Material(
        color: bg,
        borderRadius: AppRadius.medium,
        child: InkWell(
          borderRadius: AppRadius.medium,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(borderRadius: AppRadius.medium, border: Border.all(color: border)),
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Breite Kachel (Reihe nicht voll): Icon links, Name rechts
                LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 150;
                  final iconText = Opacity(
                    opacity: done ? 0.4 : 1,
                    child: Text(icon, style: TextStyle(fontSize: wide ? 30 : 34, height: 1.15)),
                  );
                  final label = Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: wide ? TextAlign.start : TextAlign.center,
                    style: TextStyle(
                      fontSize: wide ? 14 : 13,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: done ? AppColors.inkSubtle : AppColors.ink,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  );
                  if (wide) {
                    return Row(children: [
                      const SizedBox(width: 4),
                      iconText,
                      const SizedBox(width: 12),
                      Expanded(child: label),
                      if (amount.isNotEmpty) SizedBox(width: amount.length * 7.0 + 8),
                    ]);
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [iconText, const SizedBox(height: 8), label],
                  );
                }),
                if (amount.isNotEmpty)
                  Positioned(
                    top: -4,
                    right: -2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Text(amount, style: const TextStyle(color: AppColors.inkMuted, fontSize: 13, fontWeight: FontWeight.w500, fontFeatures: AppText.tab)),
                    ),
                  ),
                if (needsCheck)
                  const Positioned(top: -4, left: -2, child: Icon(Icons.help_rounded, size: 18, color: AppColors.warning)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
