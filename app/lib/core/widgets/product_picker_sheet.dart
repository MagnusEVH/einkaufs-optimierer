// app/lib/core/widgets/product_picker_sheet.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/catalog_service.dart';

/// Rückfrage: passende Katalogprodukte zu einem Freitext zur Auswahl anbieten.
/// Liefert das gewählte Produkt oder null ("So lassen").
Future<Product?> showProductPicker(
  BuildContext context,
  String rawText, {
  String emptyHint = 'Der Artikel bleibt ohne Preis und zählt nicht in die Summe.',
}) {
  final found = CatalogService.matchCandidates(rawText).candidates;
  final options = found.isNotEmpty
      ? found.take(8).toList()
      : {
          for (final word in CatalogService.tokenize(rawText))
            ...CatalogService.getSuggestions(word, limit: 4),
        }.take(8).toList();

  return showModalBottomSheet<Product>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Welches Produkt meinst du mit „$rawText“?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (options.isEmpty)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Kein passendes Produkt im Katalog.'),
              subtitle: Text(emptyHint),
            ),
          ...options.map((p) => ListTile(
                leading: Icon(p.isBio ? Icons.eco_outlined : Icons.shopping_basket_outlined, color: Colors.teal),
                title: Text(p.name),
                subtitle: p.brand != null ? Text(p.brand!) : null,
                onTap: () => Navigator.pop(ctx, p),
              )),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('So lassen'),
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}
