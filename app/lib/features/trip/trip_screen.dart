// app/lib/features/trip/trip_screen.dart
//
// Einkaufsmodus: ein Markt nach dem anderen, Artikel in der Reihenfolge der
// Warengruppen dieses Markts, große Tippflächen, sofortiges Abhaken.
// Vor der Kasse: Hinweis auf die Treue-App mit "App öffnen".

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_links.dart';
import '../../core/services/loyalty_service.dart';
import '../../core/services/my_stores_service.dart';
import '../../core/theme/app_theme.dart';
import '../stores_map/chain_style.dart';
import '../stores_map/my_stores_screen.dart';
import 'trip_controller.dart';
import 'trip_summary_screen.dart';

class TripScreen extends ConsumerWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider);
    if (trip == null || trip.stops.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Einkauf')),
        body: const Center(child: Text('Gerade läuft kein Einkauf.', style: AppText.body)),
      );
    }
    final ctrl = ref.read(tripProvider.notifier);
    final index = trip.currentStop.clamp(0, trip.stops.length - 1);
    final stop = trip.stops[index];
    final isLast = index == trip.stops.length - 1;
    final program = LoyaltyService.forChain(stop.chain);
    final color = chainColorFor(stop.chain);

    return ValueListenableBuilder<int>(
      valueListenable: MyStoresService.revision,
      builder: (context, _, __) {
        final items = stop.sortedItems;
        final done = stop.items.where((i) => i.status == TripItemStatus.done).length;
        return Scaffold(
          appBar: AppBar(
            title: Text(trip.stops.length > 1 ? 'Markt ${index + 1} von ${trip.stops.length}' : 'Einkauf'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'order') {
                    showCategoryOrderSheet(context, stop.chain);
                  } else if (v == 'cancel') {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Einkauf abbrechen?'),
                        content: const Text('Die Liste bleibt unverändert, Abgehaktes wird nicht entfernt.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Weiter einkaufen')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Abbrechen')),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      ctrl.cancel();
                      Navigator.pop(context);
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'order', child: Text('Reihenfolge im Markt anpassen')),
                  PopupMenuItem(value: 'cancel', child: Text('Einkauf abbrechen')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.xl),
            children: [
              if (trip.stops.length > 1)
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: AppSpace.s),
                    children: [
                      for (var i = 0; i < trip.stops.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpace.s),
                          child: ChoiceChip(
                            showCheckmark: false,
                            label: Text('${i + 1}. ${trip.stops[i].chain.displayName}'
                                '${trip.stops[i].openCount == 0 ? ' ✓' : ''}'),
                            selected: i == index,
                            onSelected: (_) => ctrl.setCurrentStop(i),
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.s, AppSpace.l, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.l),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(children: [
                        Container(width: 6, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: AppSpace.m),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(stop.name, style: AppText.bodyStrong.copyWith(fontSize: 17)),
                            Text(stop.address, style: AppText.small),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: AppSpace.m),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: stop.items.isEmpty ? 1 : done / stop.items.length, minHeight: 6),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text('$done von ${stop.items.length} im Wagen', style: AppText.small),
                      const SizedBox(height: AppSpace.m),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.navigation_outlined, size: 20),
                            label: const Text('Navigation'),
                            onPressed: () => AppLinks.openNavigation(stop.latitude, stop.longitude),
                          ),
                        ),
                        if (program != null) ...[
                          const SizedBox(width: AppSpace.s),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                              label: Text(program.appName, overflow: TextOverflow.ellipsis),
                              onPressed: () => AppLinks.openProgramApp(program),
                            ),
                          ),
                        ],
                      ]),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.s),
              for (final it in items)
                _TripItemRow(
                  item: it,
                  canMoveOn: !isLast,
                  onTap: () => ctrl.toggleDone(index, it.listItemId),
                  onMissing: () => ctrl.markMissing(index, it.listItemId),
                ),
              if (program != null) _CheckoutHint(program: program),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(AppSpace.l),
              decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.line))),
              child: FilledButton.icon(
                icon: Icon(isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded),
                label: Text(isLast ? 'Einkauf abschließen' : 'Weiter zu ${trip.stops[index + 1].name}'),
                onPressed: () {
                  if (isLast) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TripSummaryScreen()));
                  } else {
                    ctrl.setCurrentStop(index + 1);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TripItemRow extends StatelessWidget {
  final TripItem item;
  final bool canMoveOn;
  final VoidCallback onTap;
  final VoidCallback onMissing;

  const _TripItemRow({required this.item, required this.canMoveOn, required this.onTap, required this.onMissing});

  @override
  Widget build(BuildContext context) {
    final done = item.status == TripItemStatus.done;
    final missing = item.status == TripItemStatus.missing;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: 3),
      child: Material(
        color: done ? AppColors.surfaceAlt : AppColors.surface,
        borderRadius: AppRadius.medium,
        child: InkWell(
          borderRadius: AppRadius.medium,
          onTap: missing ? null : onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
            decoration: BoxDecoration(borderRadius: AppRadius.medium, border: Border.all(color: AppColors.line)),
            child: Row(children: [
              Icon(
                done ? Icons.check_circle_rounded : (missing ? Icons.remove_circle_outline : Icons.radio_button_unchecked),
                size: 28,
                color: done ? AppColors.primary : (missing ? AppColors.warning : AppColors.inkSubtle),
              ),
              const SizedBox(width: AppSpace.m),
              Opacity(opacity: done ? 0.45 : 1, child: Text(item.icon, style: const TextStyle(fontSize: 30))),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    '${item.quantity > 1 ? '${item.quantity.toInt()}× ' : ''}${item.name}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: done ? AppColors.inkSubtle : AppColors.ink,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(missing ? 'Nicht da, bleibt auf der Liste' : euro((item.priceCents * item.quantity).round()), style: AppText.small),
                ]),
              ),
              if (!done && !missing)
                TextButton(
                  onPressed: onMissing,
                  child: Text(canMoveOn ? 'Nicht da →' : 'Nicht da', style: const TextStyle(fontSize: 13)),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CheckoutHint extends StatelessWidget {
  final LoyaltyProgram program;
  const _CheckoutHint({required this.program});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpace.l),
        decoration: BoxDecoration(color: AppColors.infoSoft, borderRadius: AppRadius.large),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Row(children: [
            Icon(Icons.point_of_sale_rounded, color: AppColors.info),
            SizedBox(width: AppSpace.s),
            Text('Vor der Kasse', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.info)),
          ]),
          const SizedBox(height: AppSpace.s),
          Text(program.checkoutHint!, style: const TextStyle(color: AppColors.ink)),
          const SizedBox(height: AppSpace.m),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.info),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text('${program.appName} öffnen'),
            onPressed: () => AppLinks.openProgramApp(program),
          ),
        ]),
      ),
    );
  }
}
