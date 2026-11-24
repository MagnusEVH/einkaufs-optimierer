// app/lib/features/wallet/import_offers_screen.dart
//
// Vorschau für Angebote, die der Übernehmen-Knopf von einer Händlerseite
// gelesen hat. Der Nutzer prüft, ordnet zu und übernimmt.

import 'package:flutter/material.dart';
import '../../core/services/offer_import_service.dart';
import '../../core/services/wallet_service.dart';
import '../../core/widgets/product_picker_sheet.dart';

class ImportOffersScreen extends StatefulWidget {
  final ImportBatch batch;

  const ImportOffersScreen({super.key, required this.batch});

  @override
  State<ImportOffersScreen> createState() => _ImportOffersScreenState();
}

class _ImportOffersScreenState extends State<ImportOffersScreen> {
  bool _saving = false;

  ImportBatch get batch => widget.batch;

  String _euro(int cents) => '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';
  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';

  Future<void> _pick(ImportCandidate c) async {
    final chosen = await showProductPicker(
      context,
      c.title,
      emptyHint: 'Das Angebot wird nur angezeigt und fließt nicht in die Optimierung ein.',
    );
    if (chosen != null) {
      setState(() {
        c.product = chosen;
        c.selected = true;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    int count;
    String message;
    if (batch.isReceipt) {
      count = await OfferImportService.saveReceipt(batch);
      message = '$count Bonpreise von ${batch.chain.displayName} gespeichert';
    } else {
      // Ersetzt frühere Übernahmen derselben Kette und Woche (korrigiert alte Fehler)
      final kept = await OfferImportService.saveOffers(batch);
      WalletService.setImportedOffers(kept);
      count = batch.candidates.where((c) => c.selected).length;
      message = '$count Angebote von ${batch.host} übernommen';
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context, count);
  }

  @override
  Widget build(BuildContext context) {
    final selected = batch.candidates.where((c) => c.selected).length;
    final matched = batch.candidates.where((c) => c.product != null).length;

    return Scaffold(
      appBar: AppBar(title: Text(batch.isReceipt ? 'Kassenbon übernehmen' : 'Angebote übernehmen')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${batch.chain.displayName} · ${batch.host}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    batch.isReceipt
                        ? 'Einkauf vom ${_date(batch.validFrom)}${batch.validGuessed ? ' (kein Datum auf dem Bon gefunden, heute angenommen)' : ''}'
                        : 'Gültig ${_date(batch.validFrom)} – ${_date(batch.validTo)}'
                            '${batch.validGuessed ? ' (kein Datum auf der Seite gefunden, geschätzt)' : ''}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${batch.candidates.length} erkannt, $matched dem Katalog zugeordnet. '
                    '${batch.isReceipt ? 'Zugeordnete Bonpreise ersetzen 60 Tage lang den Beispielpreis dieser Kette. ' : 'Nur zugeordnete Angebote fließen in die Optimierung ein. '
                        'Frühere Übernahmen von ${batch.chain.displayName} für diesen Zeitraum werden ersetzt. '}'
                    'Deine Zuordnungen merkt sich die App für das nächste Mal. '
                    'Die Daten bleiben auf diesem Gerät.',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (batch.candidates.isEmpty)
            const ListTile(
              leading: Icon(Icons.search_off),
              title: Text('Keine Angebote erkannt'),
              subtitle: Text('Auf der Seite ganz nach unten scrollen und den Knopf erneut drücken.'),
            ),
          ...batch.candidates.map((c) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: CheckboxListTile(
                  value: c.selected,
                  onChanged: (v) => setState(() => c.selected = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_euro(c.priceCents)}'
                        '${c.originalPriceCents != null ? ' statt ${_euro(c.originalPriceCents!)}' : ''}'
                        '${c.unitInfo != null ? ' · ${c.unitInfo}' : ''}',
                      ),
                      if (!batch.isReceipt && c.warning(batch.chain) != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text('⚠ ${c.warning(batch.chain)}',
                              style: TextStyle(fontSize: 12.5, color: Colors.red.shade700, fontWeight: FontWeight.w600)),
                        ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _pick(c),
                        child: Text(
                          c.product != null ? '→ ${c.product!.name} (ändern)' : '→ Kein Katalogprodukt – tippen zum Zuordnen',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: c.product != null ? Colors.teal.shade700 : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: const Icon(Icons.download_done_rounded),
            label: Text(batch.isReceipt ? '$selected Bonpreise übernehmen' : '$selected Angebote übernehmen'),
            onPressed: _saving || selected == 0 ? null : _save,
          ),
        ),
      ),
    );
  }
}
