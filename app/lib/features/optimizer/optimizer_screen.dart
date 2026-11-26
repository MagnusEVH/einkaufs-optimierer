// app/lib/features/optimizer/optimizer_screen.dart
//
// Einkauf planen: bis zu drei Vorschläge zum Wählen (empfohlen, ein Markt,
// eigene Wahl), Details zur gewählten Route und "Einkauf starten".

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/optimization_result.dart';
import '../../core/models/store.dart';
import '../../core/models/user_preferences.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/item_icons.dart';
import '../../core/services/location_service.dart';
import '../../core/services/my_stores_service.dart';
import '../../core/services/optimizer_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/item_tile.dart';
import '../shopping_list/shopping_list_controller.dart';
import '../stores_map/chain_style.dart';
import '../stores_map/data/rlp_stores.dart';
import '../trip/trip_controller.dart';
import '../trip/trip_screen.dart';

enum _Option { recommended, single, custom }

class OptimizerResultScreen extends ConsumerStatefulWidget {
  /// Startmarkt aus der Karte ("Von hier planen").
  final Store? startStore;

  const OptimizerResultScreen({super.key, this.startStore});

  @override
  ConsumerState<OptimizerResultScreen> createState() => _OptimizerResultScreenState();
}

class _OptimizerResultScreenState extends ConsumerState<OptimizerResultScreen> {
  bool _loading = true;
  String? _error;
  UserLocation? _location;
  UserPreferences? _prefs;
  final Map<_Option, OptimizationResult> _results = {};
  _Option _selected = _Option.recommended;
  List<Store> _customStores = [];

  @override
  void initState() {
    super.initState();
    _run();
  }

  String _routeKey(OptimizationResult r) => r.stops.map((s) => s.storeId).join('|');

  Future<void> _run() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = ref.read(shoppingListProvider).items;
      _location = await LocationService.getCurrentLocation();
      _prefs = await SupabaseService.fetchPreferences();
      _results.clear();
      final recommended = await OptimizerService.optimizeShoppingList(
        userLocation: _location!,
        items: items,
        preferences: _prefs!,
        anchorStore: widget.startStore,
      );
      _results[_Option.recommended] = recommended;
      if (widget.startStore == null && _prefs!.maxStops > 1) {
        final single = await OptimizerService.optimizeShoppingList(
          userLocation: _location!,
          items: items,
          preferences: _prefs!.copyWith(maxStops: 1),
        );
        if (_routeKey(single) != _routeKey(recommended)) _results[_Option.single] = single;
      }
      if (_customStores.isNotEmpty) await _runCustom();
      if (!_results.containsKey(_selected)) _selected = _Option.recommended;
      if (!mounted) return;
      setState(() => _loading = false);
      AnalyticsService.trackShoppingRouteStarted(stopCount: recommended.stops.length, totalDistanceKm: recommended.summary.routeDistanceKm);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _runCustom() async {
    if (_customStores.isEmpty) {
      setState(() {
        _results.remove(_Option.custom);
        _selected = _Option.recommended;
      });
      return;
    }
    final res = await OptimizerService.optimizeShoppingList(
      userLocation: _location!,
      items: ref.read(shoppingListProvider).items,
      preferences: _prefs!,
      fixedRoute: _customStores,
    );
    if (!mounted) return;
    setState(() {
      _results[_Option.custom] = res;
      _selected = _Option.custom;
    });
  }

  Future<void> _pickStores() async {
    final loc = _location;
    final prefs = _prefs;
    if (loc == null || prefs == null) return;
    final candidates = OptimizerService.candidateStores(
      userLocation: loc,
      preferences: prefs,
      stores: rlpStores,
      excludedStoreIds: MyStoresService.disabledStoreIds,
    )..sort((a, b) => _dist(loc, a).compareTo(_dist(loc, b)));
    final chosen = await showModalBottomSheet<List<Store>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StorePickerSheet(candidates: candidates.take(20).toList(), initial: _customStores, location: loc),
    );
    if (chosen == null) return;
    _customStores = chosen;
    try {
      await _runCustom();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    }
  }

  static double _dist(UserLocation l, Store s) => OptimizerService.haversineMeters(l.latitude, l.longitude, s.latitude, s.longitude);

  void _start() {
    final res = _results[_selected];
    if (res == null || res.stops.isEmpty) return;
    ref.read(tripProvider.notifier).start(res);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TripScreen()));
  }

  String _title(_Option o, OptimizationResult r) => switch (o) {
        _Option.recommended => r.isMultiStore ? 'Empfohlen: ${r.stops.length} Märkte' : 'Empfohlen: ein Markt',
        _Option.single => 'Nur ein Markt',
        _Option.custom => 'Deine Wahl',
      };

  @override
  Widget build(BuildContext context) {
    final res = _results[_selected];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkauf planen'),
        actions: [
          IconButton(tooltip: 'Neu berechnen', icon: const Icon(Icons.refresh), onPressed: _loading ? null : _run),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpace.l),
                Text('Vergleiche deine Märkte …', style: AppText.bodyStrong),
              ]),
            )
          : _error != null
              ? _buildError()
              : ListView(
                  padding: const EdgeInsets.all(AppSpace.l),
                  children: [
                    if (widget.startStore != null) ...[
                      _InfoBox(icon: Icons.flag_rounded, text: 'Start im Markt ${widget.startStore!.name}'),
                      const SizedBox(height: AppSpace.m),
                    ],
                    const Text('Vorschläge', style: AppText.section),
                    const SizedBox(height: AppSpace.s),
                    for (final o in _Option.values)
                      if (_results[o] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.s),
                          child: _OptionCard(
                            title: _title(o, _results[o]!),
                            result: _results[o]!,
                            reference: o == _Option.recommended ? null : _results[_Option.recommended],
                            selected: _selected == o,
                            onTap: () => setState(() => _selected = o),
                          ),
                        ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.storefront_outlined),
                      label: Text(_customStores.isEmpty ? 'Märkte selbst wählen' : 'Eigene Wahl ändern (${_customStores.length})'),
                      onPressed: _pickStores,
                    ),
                    if (res != null) ...[
                      const SizedBox(height: AppSpace.xl),
                      if (res.unpricedItems.isNotEmpty) ...[
                        _InfoBox(
                          icon: Icons.help_outline_rounded,
                          warning: true,
                          text: '${res.unpricedItems.length} Artikel ohne Preis, nicht in der Summe: ${res.unpricedItems.join(', ')}',
                        ),
                        const SizedBox(height: AppSpace.m),
                      ],
                      Text('Route · ${_km(res.summary.totalRouteDistanceMeters)}', style: AppText.section),
                      const SizedBox(height: AppSpace.s),
                      for (var i = 0; i < res.stops.length; i++) ...[
                        _StopCard(stop: res.stops[i]),
                        if (i + 1 < res.stops.length) _Connector(from: res.stops[i], to: res.stops[i + 1]),
                      ],
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
      bottomNavigationBar: _loading || _error != null || res == null
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(AppSpace.l),
                decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.line))),
                child: FilledButton.icon(
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: Text('Einkauf starten · ${euro(res.summary.totalBasketPriceCents)}'),
                  onPressed: res.stops.isEmpty ? null : _start,
                ),
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: AppSpace.m),
          Text(_error!, textAlign: TextAlign.center, style: AppText.body),
          const SizedBox(height: AppSpace.l),
          FilledButton.icon(onPressed: _run, icon: const Icon(Icons.refresh), label: const Text('Erneut versuchen')),
        ]),
      ),
    );
  }
}

String _km(num meters) => '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';

class _OptionCard extends StatelessWidget {
  final String title;
  final OptimizationResult result;
  final OptimizationResult? reference;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({required this.title, required this.result, this.reference, required this.selected, required this.onTap});

  static int _cost(OptimizationResult r) => r.summary.totalBasketPriceCents + r.summary.totalTravelCents;

  @override
  Widget build(BuildContext context) {
    final s = result.summary;
    final chains = result.stops.map((x) => x.chain.displayName).join(' + ');
    String? note;
    final ref = reference;
    if (ref != null) {
      // Vergleich mit dem Vorschlag inkl. Fahrtkosten, nur bei gleicher Abdeckung sinnvoll
      if (ref.unpricedItems.length == result.unpricedItems.length) {
        final diff = _cost(result) - _cost(ref);
        note = diff > 0
            ? '${euro(diff)} teurer als empfohlen (inkl. Fahrt)'
            : diff < 0
                ? '${euro(-diff)} günstiger als empfohlen (inkl. Fahrt)'
                : 'gleich teuer wie empfohlen';
      } else {
        note = '${result.unpricedItems.length} statt ${ref.unpricedItems.length} Artikel ohne Preis';
      }
    } else if (result.isMultiStore && s.netSavingsCents > 0) {
      note = '${euro(s.netSavingsCents)} gespart gegenüber einem Markt (inkl. Fahrt)';
    }
    return Material(
      color: selected ? AppColors.primaryFaint : AppColors.surface,
      borderRadius: AppRadius.large,
      child: InkWell(
        borderRadius: AppRadius.large,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpace.l),
          decoration: BoxDecoration(
            borderRadius: AppRadius.large,
            border: Border.all(color: selected ? AppColors.primary : AppColors.line),
          ),
          child: Row(children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.primary : AppColors.inkSubtle),
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppText.bodyStrong),
                const SizedBox(height: 2),
                Text('$chains · ${_km(s.totalRouteDistanceMeters)}', style: AppText.small),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(note, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: note.contains('teurer') || note.contains('ohne Preis') ? AppColors.inkMuted : AppColors.primaryDark)),
                ],
              ]),
            ),
            Text(euro(s.totalBasketPriceCents), style: AppText.price.copyWith(fontSize: 17)),
          ]),
        ),
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  final RouteStop stop;
  const _StopCard({required this.stop});

  @override
  Widget build(BuildContext context) {
    final color = chainColorFor(stop.chain);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.l),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Text('${stop.stopIndex}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
            ),
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(stop.storeName, style: AppText.bodyStrong),
                Text(stop.address, style: AppText.tiny),
              ]),
            ),
            Text(euro(stop.stopSubtotalCents), style: AppText.price),
          ]),
          const Divider(height: AppSpace.xl),
          for (final it in stop.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                ItemIconBox(_icon(it), size: 30),
                const SizedBox(width: AppSpace.s),
                Expanded(child: Text('${it.quantity.toInt()}× ${it.itemName}', style: AppText.body.copyWith(fontSize: 14))),
                Text(euro(it.totalPriceCents), style: AppText.price.copyWith(fontSize: 14)),
              ]),
            ),
        ]),
      ),
    );
  }

  static String _icon(AllocatedItem it) {
    final p = it.productId == null ? null : CatalogService.products.where((x) => x.id == it.productId).firstOrNull;
    return ItemIcons.iconFor(it.itemName, product: p);
  }
}

/// Weg zwischen zwei Stopps, ehrlich nach Entfernung.
class _Connector extends StatelessWidget {
  final RouteStop from;
  final RouteStop to;
  const _Connector({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    final m = OptimizerService.haversineMeters(from.latitude, from.longitude, to.latitude, to.longitude);
    final walk = m <= OptimizerService.walkableMeters;
    final text = walk ? '${m.round()} m zu Fuß, Auto bleibt stehen' : '${_km(m)} Fahrt (Luftlinie)';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(walk ? Icons.directions_walk : Icons.directions_car, size: 16, color: AppColors.inkSubtle),
        const SizedBox(width: AppSpace.xs),
        Text(text, style: AppText.small),
      ]),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool warning;
  const _InfoBox({required this.icon, required this.text, this.warning = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.m),
      decoration: BoxDecoration(color: warning ? AppColors.warningSoft : AppColors.surfaceAlt, borderRadius: AppRadius.medium),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: warning ? AppColors.warning : AppColors.inkMuted),
        const SizedBox(width: AppSpace.s),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 13, height: 1.35, color: warning ? AppColors.warning : AppColors.ink)),
        ),
      ]),
    );
  }
}

/// Märkte selbst wählen (bis zu drei), Reihenfolge = Reihenfolge der Auswahl.
class _StorePickerSheet extends StatefulWidget {
  final List<Store> candidates;
  final List<Store> initial;
  final UserLocation location;
  const _StorePickerSheet({required this.candidates, required this.initial, required this.location});

  @override
  State<_StorePickerSheet> createState() => _StorePickerSheetState();
}

class _StorePickerSheetState extends State<_StorePickerSheet> {
  late final List<Store> _picked = List.of(widget.initial);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.s),
            child: Text('Märkte selbst wählen', style: AppText.title),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpace.l),
            child: Text(
              'Bis zu 3 Märkte in der Reihenfolge, in der du sie anfährst. Die App verteilt die Artikel auf den jeweils günstigsten.',
              style: AppText.small,
            ),
          ),
          const SizedBox(height: AppSpace.s),
          Flexible(
            child: widget.candidates.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(AppSpace.xl),
                    child: Text('Keine aktiven Märkte im Umkreis. Unter „Meine Märkte“ einschalten.', textAlign: TextAlign.center),
                  )
                : ListView(shrinkWrap: true, children: [
                    for (final s in widget.candidates) _tile(s),
                  ]),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.l),
            child: Row(children: [
              if (widget.initial.isNotEmpty)
                TextButton(onPressed: () => Navigator.pop(context, <Store>[]), child: const Text('Eigene Wahl löschen')),
              const Spacer(),
              FilledButton(
                onPressed: _picked.isEmpty ? null : () => Navigator.pop(context, _picked),
                child: Text('${_picked.length} übernehmen'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _tile(Store s) {
    final pos = _picked.indexWhere((p) => p.id == s.id);
    final km = OptimizerService.haversineMeters(widget.location.latitude, widget.location.longitude, s.latitude, s.longitude);
    return CheckboxListTile(
      value: pos >= 0,
      onChanged: (v) => setState(() {
        if (v == true) {
          if (_picked.length < 3) _picked.add(s);
        } else {
          _picked.removeWhere((p) => p.id == s.id);
        }
      }),
      secondary: CircleAvatar(
        radius: 16,
        backgroundColor: chainColorFor(s.chain),
        child: Text(pos >= 0 ? '${pos + 1}' : '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('${s.address} · ${_km(km)}', style: AppText.tiny),
    );
  }
}
