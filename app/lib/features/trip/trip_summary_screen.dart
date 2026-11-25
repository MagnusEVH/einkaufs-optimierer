// app/lib/features/trip/trip_summary_screen.dart
//
// Abschluss eines Einkaufs: was im Wagen ist, was offen bleibt, geplante Ersparnis.
// Danach Kassenbon einlesen (Foto oder eBon-PDF): echte Preise und Treue-Guthaben.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_links.dart';
import '../../core/services/loyalty_service.dart';
import '../../core/theme/app_theme.dart';
import 'trip_controller.dart';
import 'trip_screen.dart';

class TripSummaryScreen extends ConsumerWidget {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider);
    if (trip == null) {
      return Scaffold(appBar: AppBar(title: const Text('Abschluss')), body: const Center(child: Text('Kein Einkauf offen.')));
    }
    final open = trip.allItems.where((i) => i.status != TripItemStatus.done).toList();
    final hasProgram = trip.stops.any((s) => LoyaltyService.forChain(s.chain) != null);

    void finish({bool scan = false}) {
      ref.read(tripProvider.notifier).finish();
      Navigator.of(context).popUntil((r) => r.isFirst);
      if (scan) AppLinks.openReceiptScan();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Einkauf abschließen'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.l),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.xl),
            decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: AppRadius.large),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Im Wagen', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpace.xs),
              Text('${trip.doneCount} von ${trip.totalCount} Artikeln',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpace.s),
              Text('laut Plan ${euro(trip.doneCents)}', style: const TextStyle(color: Colors.white, fontSize: 15)),
              if (trip.plannedSavingsCents > 0)
                Text('geplante Ersparnis ${euro(trip.plannedSavingsCents)} gegenüber einem Markt',
                    style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
          if (open.isNotEmpty) ...[
            const SizedBox(height: AppSpace.xl),
            Text('BLEIBT AUF DER LISTE (${open.length})', style: AppText.section),
            const SizedBox(height: AppSpace.s),
            Card(
              child: Column(children: [
                for (final it in open)
                  ListTile(
                    leading: Text(it.icon, style: const TextStyle(fontSize: 26)),
                    title: Text(it.name),
                    subtitle: Text(it.status == TripItemStatus.missing ? 'nicht da' : 'nicht abgehakt', style: AppText.tiny),
                  ),
              ]),
            ),
          ],
          if (trip.unpricedItems.isNotEmpty) ...[
            const SizedBox(height: AppSpace.m),
            Text('Ohne Preis geplant: ${trip.unpricedItems.join(', ')}', style: AppText.small),
          ],
          const SizedBox(height: AppSpace.xl),
          Container(
            padding: const EdgeInsets.all(AppSpace.l),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.large, border: Border.all(color: AppColors.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Row(children: [
                Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                SizedBox(width: AppSpace.s),
                Text('Kassenbon einlesen', style: AppText.bodyStrong),
              ]),
              const SizedBox(height: AppSpace.s),
              Text(
                hasProgram
                    ? 'Papierbon fotografieren oder eBon aus der REWE-App wählen: echte Preise deiner Filiale und dazu Punkte und Guthaben der Treue-App.'
                    : 'Papierbon fotografieren oder eBon wählen: echte Preise deiner Filiale für den nächsten Einkauf.',
                style: AppText.small,
              ),
              const SizedBox(height: AppSpace.m),
              FilledButton.icon(
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Abschließen und Bon einlesen'),
                onPressed: () => finish(scan: true),
              ),
            ]),
          ),
          const SizedBox(height: AppSpace.s),
          OutlinedButton(onPressed: finish, child: const Text('Ohne Bon abschließen')),
          const SizedBox(height: AppSpace.xs),
          TextButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TripScreen())),
            child: const Text('Zurück zum Einkauf'),
          ),
        ],
      ),
    );
  }
}
