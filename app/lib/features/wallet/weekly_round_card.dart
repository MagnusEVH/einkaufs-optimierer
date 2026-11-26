// app/lib/features/wallet/weekly_round_card.dart
//
// Wochenrunde: pro Kette, wann zuletzt Angebote übernommen wurden, mit Link
// zur Angebotsseite. Du öffnest die Seite selbst und drückst dort den
// Übernehmen-Knopf; die App ruft keine Händlerseite selbst ab.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/store.dart';
import '../../core/services/offer_import_service.dart';
import '../../core/services/wallet_service.dart';
import '../../core/theme/app_theme.dart';

class WeeklyRoundStop {
  final SupermarketChain chain;
  final String url;
  /// true = eigene Erkennungsregel an einer echten Seite geprüft.
  final bool verified;
  final String hint;

  const WeeklyRoundStop(this.chain, this.url, {this.verified = false, this.hint = ''});
}

/// Reihenfolge der Runde. REWE und dm sind an echten Seiten geprüft.
const weeklyRound = [
  WeeklyRoundStop(SupermarketChain.rewe, 'https://www.rewe.de/angebote/',
      verified: true, hint: 'Markt wählen, ganz nach unten scrollen'),
  WeeklyRoundStop(SupermarketChain.lidl, 'https://www.lidl.de/', hint: 'Angebote der Woche öffnen'),
  WeeklyRoundStop(SupermarketChain.aldi_sued, 'https://www.aldi-sued.de/', hint: 'Angebote öffnen'),
  WeeklyRoundStop(SupermarketChain.netto, 'https://www.netto-online.de/', hint: 'Filiale wählen, Angebote öffnen'),
  WeeklyRoundStop(SupermarketChain.dm, 'https://www.dm.de/',
      verified: true, hint: 'Eine Produktliste öffnen, z. B. „Neu“ oder eine Kategorie'),
  WeeklyRoundStop(SupermarketChain.rossmann, 'https://www.rossmann.de/', hint: 'Angebote öffnen'),
];

class WeeklyRoundCard extends StatefulWidget {
  const WeeklyRoundCard({super.key});

  @override
  State<WeeklyRoundCard> createState() => _WeeklyRoundCardState();
}

class _WeeklyRoundCardState extends State<WeeklyRoundCard> {
  Map<String, Map<String, dynamic>> _log = {};

  @override
  void initState() {
    super.initState();
    WalletService.offersRevision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    WalletService.offersRevision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final log = await OfferImportService.loadLog();
    if (mounted) setState(() => _log = log);
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';

  /// Status einer Kette: aktuell (Angebote noch gültig), veraltet oder offen.
  (String, Color) _status(SupermarketChain chain) {
    final e = _log[chain.name];
    if (e == null) return ('noch nie übernommen', AppColors.inkSubtle);
    final at = DateTime.tryParse(e['at']?.toString() ?? '');
    final validTo = DateTime.tryParse(e['valid_to']?.toString() ?? '');
    final count = e['count'] ?? 0;
    final when = at != null ? 'am ${_date(at)}' : '';
    if (validTo != null && validTo.isAfter(DateTime.now())) {
      return ('$count Angebote $when, gültig bis ${_date(validTo)}', AppColors.primaryDark);
    }
    return ('abgelaufen, zuletzt $when', Colors.orange.shade800);
  }

  int get _done => weeklyRound.where((s) {
        final v = DateTime.tryParse(_log[s.chain.name]?['valid_to']?.toString() ?? '');
        return v != null && v.isAfter(DateTime.now());
      }).length;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Wochenrunde', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('$_done / ${weeklyRound.length} aktuell',
                      style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.inkMuted)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Seite öffnen, ganz nach unten scrollen, Übernehmen-Knopf in der Lesezeichenleiste drücken. '
              'Ein neuer Import ersetzt den alten derselben Kette.',
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 4),
            ...weeklyRound.map((s) {
              final (text, color) = _status(s.chain);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  s.chain.displayName + (s.verified ? '' : ' · Erkennung ungeprüft'),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('$text\n${s.hint}', style: TextStyle(color: color, fontSize: 13)),
                isThreeLine: true,
                trailing: TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Öffnen'),
                  onPressed: () => launchUrl(Uri.parse(s.url), webOnlyWindowName: '_blank'),
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: const Text('Übernehmen-Knopf einrichten'),
                onPressed: () => launchUrl(Uri.base.resolve('uebernehmen.html'), webOnlyWindowName: '_blank'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
