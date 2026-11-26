// app/lib/features/my_apps/my_apps_screen.dart
//
// Meine Apps: Händler-Apps öffnen (für den QR-Code an der Kasse) und Punkte
// bzw. Guthaben per Scan erfassen. Kein Login, kein Zugriff auf fremde Apps:
// Stand kommt aus einem Screenshot der Guthaben-Seite oder vom Kassenbon.

import 'package:flutter/material.dart';
import '../../core/services/app_links.dart';
import '../../core/services/loyalty_service.dart';
import '../../core/theme/app_theme.dart';
import '../stores_map/chain_style.dart';
import 'balance_scan_flow.dart';

class MyAppsScreen extends StatelessWidget {
  const MyAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Apps')),
      body: ValueListenableBuilder<int>(
        valueListenable: LoyaltyService.revision,
        builder: (context, _, __) => ListView(
          padding: const EdgeInsets.all(AppSpace.l),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpace.m),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: AppRadius.medium),
              child: const Text(
                'Tippe „App öffnen“, um an der Kasse den Code der Händler-App zu zeigen. '
                'Punkte und Guthaben liest die App per Scan: Screenshot der Guthaben-Seite oder Kassenbon. '
                'Es gibt keinen Login und keine Verbindung zu den Händlern.',
                style: TextStyle(fontSize: 13, height: 1.35, color: AppColors.ink),
              ),
            ),
            const SizedBox(height: AppSpace.m),
            for (final p in LoyaltyService.programs) ...[
              _ProgramCard(program: p),
              const SizedBox(height: AppSpace.m),
            ],
            const _ScreenshotHelp(),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime d) => '${d.day}.${d.month}.${d.year}';

class _ProgramCard extends StatelessWidget {
  final LoyaltyProgram program;
  const _ProgramCard({required this.program});

  Color get _color => program.chains.isEmpty ? const Color(0xFF0046AA) : chainColorFor(program.chains.first);

  @override
  Widget build(BuildContext context) {
    final balance = LoyaltyService.balance(program.id);
    final checkout = LoyaltyService.lastCheckout(program.id);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.l),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _color,
              child: Text(program.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(program.name, style: AppText.bodyStrong),
                Text(program.benefit, style: AppText.small),
              ]),
            ),
          ]),
          if (program.balanceKind != null) ...[
            const SizedBox(height: AppSpace.m),
            Container(
              padding: const EdgeInsets.all(AppSpace.m),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: AppRadius.medium),
              child: balance == null
                  ? const Text('Noch nicht gescannt', style: AppText.small)
                  : Row(children: [
                      Expanded(
                        child: Text(
                          balance.valueCents != null ? '${euro(balance.valueCents!)} Guthaben' : '${balance.points} Punkte',
                          style: AppText.bodyStrong.copyWith(fontSize: 18),
                        ),
                      ),
                      Text('Stand ${_date(balance.at)}\n${balance.source}', textAlign: TextAlign.right, style: AppText.tiny),
                    ]),
            ),
          ],
          if (checkout != null) ...[
            const SizedBox(height: AppSpace.s),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(
                checkout.scanned ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                size: 18,
                color: checkout.scanned ? AppColors.primary : AppColors.warning,
              ),
              const SizedBox(width: AppSpace.xs),
              Expanded(child: Text(_checkoutText(checkout), style: AppText.small)),
            ]),
          ],
          const SizedBox(height: AppSpace.m),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                label: const Text('App öffnen'),
                onPressed: () => AppLinks.openProgramApp(program),
              ),
            ),
            if (program.balanceKind != null) ...[
              const SizedBox(width: AppSpace.s),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.document_scanner_outlined, size: 20),
                  label: const Text('Stand scannen'),
                  onPressed: () => scanBalanceFlow(context, program),
                ),
              ),
            ],
          ]),
        ]),
      ),
    );
  }

  String _checkoutText(CheckoutRecord c) {
    final parts = <String>[];
    if (c.earnedCents != null) parts.add('+${euro(c.earnedCents!)} gesammelt');
    if (c.redeemedCents != null) parts.add('${euro(c.redeemedCents!)} eingelöst');
    if (c.points != null) parts.add('${c.points} Punkte');
    if (c.scanned) {
      return 'Bon vom ${_date(c.date)}: an der Kasse gescannt${parts.isEmpty ? '' : ', ${parts.join(', ')}'}';
    }
    return 'Bon vom ${_date(c.date)}: keine ${program.name}-Zeile gefunden. App an der Kasse vergessen?';
  }
}

class _ScreenshotHelp extends StatelessWidget {
  const _ScreenshotHelp();

  @override
  Widget build(BuildContext context) {
    return const ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text('So scannst du den Stand', style: AppText.bodyStrong),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Am einfachsten: Kassenbon einlesen, bei REWE den eBon aus der App (PDF). Steht dort eine Bonus- oder Punktezeile, '
            'übernimmt die App den Stand ohne weiteren Schritt.\n\n'
            'Ohne Bon: In der Händler-App einen Screenshot machen (iPhone: Seitentaste und Lauter-Taste), '
            'zurück in diese App, „Stand scannen“ tippen und den Screenshot wählen. Fertig.\n'
            'Kommst du gerade aus der Händler-App zurück, bietet die App den Scan von selbst an.\n'
            'Die Texterkennung läuft auf dem Gerät, das Bild wird nicht hochgeladen.',
            style: AppText.small,
          ),
        ),
      ],
    );
  }
}
