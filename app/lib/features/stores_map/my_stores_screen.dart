// app/lib/features/stores_map/my_stores_screen.dart
//
// "Meine Märkte": Filialen an- und abschalten (der Optimierer nutzt nur aktive)
// und je Kette die Reihenfolge der Warengruppen festlegen (Einkaufsmodus).

import 'package:flutter/material.dart';
import '../../core/models/store.dart';
import '../../core/services/item_icons.dart';
import '../../core/services/location_service.dart';
import '../../core/services/my_stores_service.dart';
import '../../core/services/optimizer_service.dart';
import '../../core/theme/app_theme.dart';
import 'chain_style.dart';
import 'data/rlp_stores.dart';

class MyStoresScreen extends StatefulWidget {
  const MyStoresScreen({super.key});

  @override
  State<MyStoresScreen> createState() => _MyStoresScreenState();
}

class _MyStoresScreenState extends State<MyStoresScreen> {
  UserLocation? _location;

  @override
  void initState() {
    super.initState();
    LocationService.getCurrentLocation().then((l) {
      if (mounted) setState(() => _location = l);
    });
  }

  double? _km(Store s) {
    final l = _location;
    if (l == null) return null;
    return OptimizerService.haversineMeters(l.latitude, l.longitude, s.latitude, s.longitude) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: MyStoresService.revision,
      builder: (context, _, __) {
        final byChain = <SupermarketChain, List<Store>>{};
        for (final s in rlpStores) {
          byChain.putIfAbsent(s.chain, () => []).add(s);
        }
        for (final list in byChain.values) {
          list.sort((a, b) => (_km(a) ?? 0).compareTo(_km(b) ?? 0));
        }
        final chains = byChain.keys.toList()
          ..sort((a, b) => (_km(byChain[a]!.first) ?? 0).compareTo(_km(byChain[b]!.first) ?? 0));
        final active = rlpStores.where((s) => MyStoresService.isActive(s.id)).length;

        return Scaffold(
          appBar: AppBar(title: const Text('Meine Märkte')),
          body: ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.xl),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpace.l),
                child: Text(
                  '$active von ${rlpStores.length} Märkten aktiv. Die Planung nutzt nur aktive Märkte im Umkreis. '
                  'Unter „Reihenfolge“ legst du fest, wie die Warengruppen im Markt liegen.',
                  style: AppText.small,
                ),
              ),
              for (final chain in chains) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.m, AppSpace.s, AppSpace.xs),
                  child: Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: chainColorFor(chain), shape: BoxShape.circle)),
                    const SizedBox(width: AppSpace.s),
                    Expanded(child: Text(chain.displayName, style: AppText.bodyStrong)),
                    TextButton.icon(
                      icon: const Icon(Icons.swap_vert_rounded, size: 18),
                      label: const Text('Reihenfolge'),
                      onPressed: () => showCategoryOrderSheet(context, chain),
                    ),
                  ]),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpace.l),
                  child: Column(children: [
                    for (final s in byChain[chain]!)
                      SwitchListTile(
                        value: MyStoresService.isActive(s.id),
                        onChanged: (v) => MyStoresService.setActive(s.id, v),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                          '${s.address}${_km(s) != null ? ' · ${_km(s)!.toStringAsFixed(1).replaceAll('.', ',')} km' : ''}',
                          style: AppText.tiny,
                        ),
                      ),
                  ]),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Reihenfolge der Warengruppen für eine Kette festlegen (Ziehen zum Sortieren).
Future<void> showCategoryOrderSheet(BuildContext context, SupermarketChain chain) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CategoryOrderSheet(chain: chain),
  );
}

class _CategoryOrderSheet extends StatefulWidget {
  final SupermarketChain chain;
  const _CategoryOrderSheet({required this.chain});

  @override
  State<_CategoryOrderSheet> createState() => _CategoryOrderSheetState();
}

class _CategoryOrderSheetState extends State<_CategoryOrderSheet> {
  late List<String> _order = MyStoresService.categoryOrder(widget.chain.name);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.xs),
            child: Text('Weg durch ${widget.chain.displayName}', style: AppText.title),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpace.l),
            child: Text('Ziehe die Warengruppen in die Reihenfolge, in der du sie im Markt erreichst.', style: AppText.small),
          ),
          Flexible(
            child: ReorderableListView(
              shrinkWrap: true,
              buildDefaultDragHandles: true,
              onReorder: (from, to) => setState(() {
                if (to > from) to--;
                final id = _order.removeAt(from);
                _order.insert(to, id);
              }),
              children: [
                for (final id in _order)
                  ListTile(
                    key: ValueKey(id),
                    leading: Text(ItemIcons.byId(id).icon, style: const TextStyle(fontSize: 24)),
                    title: Text(ItemIcons.byId(id).name),
                    trailing: const Icon(Icons.drag_handle_rounded),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.l),
            child: Row(children: [
              TextButton(
                onPressed: () => setState(() => _order = ItemIcons.defaultOrder),
                child: const Text('Standard'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await MyStoresService.setCategoryOrder(widget.chain.name, _order);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Speichern'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
