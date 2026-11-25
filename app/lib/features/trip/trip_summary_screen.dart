// app/lib/features/trip/trip_summary_screen.dart
//
// Abschluss eines Einkaufs: was im Wagen ist, was offen bleibt, geplante Ersparnis.
// Danach Kassenbon scannen: echte Preise und Treue-Punkte per Texterkennung.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_links.dart';
import '../../core/services/loyalty_service.dart';
import '../../core/theme/app_theme.dart';
import 'trip_controller.dart';
import '../../core/widgets/item_tile.dart';
import 'trip_screen.dart';

class TripSummaryScreen extends ConsumerWidget {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider);
    if (trip == null) {
      return Scaffold(appBar: AppBar(title: const Text('Abschluss')), body: const Center(child: Text('Kein Einkauf offen')));
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
          _Receipt(trip: trip),
          if (open.isNotEmpty) ...[
            const SizedBox(height: AppSpace.xl),
            Text('Bleibt auf der Liste (${open.length})', style: AppText.section),
            const SizedBox(height: AppSpace.s),
            Card(
              child: Column(children: [
                for (final it in open)
                  ListTile(
                    leading: ItemIconBox(it.icon, size: 36),
                    title: Text(it.name, style: AppText.body),
                    trailing: Text(it.status == TripItemStatus.missing ? 'nicht da' : 'nicht abgehakt', style: AppText.tiny),
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
                Icon(Icons.receipt_long_outlined, size: 20, color: AppColors.inkMuted),
                SizedBox(width: AppSpace.s),
                Text('Kassenbon scannen', style: AppText.bodyStrong),
              ]),
              const SizedBox(height: AppSpace.s),
              Text(
                hasProgram
                    ? 'Foto vom Bon: echte Preise deiner Filiale und, falls auf dem Bon gedruckt, Punkte und Guthaben der Treue-App.'
                    : 'Foto vom Bon: echte Preise deiner Filiale für den nächsten Einkauf.',
                style: AppText.small,
              ),
              const SizedBox(height: AppSpace.m),
              FilledButton.icon(
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Abschließen und Bon scannen'),
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

/// Der eine reiche Moment der App: der Abschluss als Kassenbon.
/// Papierfläche, gezackte Unterkante, Beträge rechtsbündig in Tabellenziffern.
class _Receipt extends StatelessWidget {
  final ShoppingTrip trip;
  const _Receipt({required this.trip});

  @override
  Widget build(BuildContext context) {
    final d = trip.startedAt;
    final date = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    final stores = trip.stops.map((s) => s.name).join(' · ');
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: ClipPath(
        clipper: const _ZigzagClipper(),
        child: Container(
          color: const Color(0xFFFFFEFB),
          padding: const EdgeInsets.fromLTRB(AppSpace.xxl, AppSpace.xxl, AppSpace.xxl, AppSpace.xxxl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Einkauf vom $date', style: AppText.small.copyWith(fontFeatures: AppText.tab)),
            if (stores.isNotEmpty) ...[
              const SizedBox(height: AppSpace.xs),
              Text(stores, style: AppText.tiny),
            ],
            const SizedBox(height: AppSpace.l),
            _row('Im Wagen', '${trip.doneCount} von ${trip.totalCount}'),
            _row('Laut Plan', euro(trip.doneCents)),
            const SizedBox(height: AppSpace.s),
            const _DashedLine(),
            const SizedBox(height: AppSpace.m),
            if (trip.plannedSavingsCents > 0) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                const Expanded(child: Text('Gespart', style: AppText.bodyStrong)),
                Text(euro(trip.plannedSavingsCents), style: AppText.figure.copyWith(color: AppColors.primary)),
              ]),
              const SizedBox(height: AppSpace.xs),
              const Text('geplant, gegenüber dem günstigsten einzelnen Markt', style: AppText.tiny, textAlign: TextAlign.right),
            ] else
              const Text('Keine Ersparnis gegenüber einem einzelnen Markt geplant', style: AppText.small),
          ]),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
        child: Row(children: [
          Expanded(child: Text(label, style: AppText.body)),
          Text(value, style: AppText.price),
        ]),
      );
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final n = (c.maxWidth / 8).floor();
      return Row(
        children: List.generate(n, (_) => Container(width: 4, height: 1, margin: const EdgeInsets.only(right: 4), color: AppColors.lineStrong)),
      );
    });
  }
}

/// Gezackte Abrisskante unten wie bei einem Bon.
class _ZigzagClipper extends CustomClipper<Path> {
  const _ZigzagClipper();

  @override
  Path getClip(Size size) {
    const tooth = 8.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - tooth);
    final count = (size.width / (tooth * 2)).ceil();
    final step = size.width / count;
    for (var i = count; i > 0; i--) {
      final x = i * step;
      path
        ..lineTo(x - step / 2, size.height)
        ..lineTo(x - step, size.height - tooth);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
