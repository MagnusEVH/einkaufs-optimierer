// app/lib/features/shopping_list/shopping_list_screen.dart
//
// Liste bauen: Artikel als Kacheln mit Icon (Vorbild: Bring!) oder als Liste,
// gruppiert nach Warengruppe. Unsichere Artikel oben unter "Bitte prüfen".
// Abgehakt wird erst im Einkaufsmodus (TripScreen).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_navigation.dart';
import '../../core/models/item_amount.dart';
import '../../core/models/list_item.dart';
import '../../core/models/product.dart';
import '../../core/models/store.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/item_icons.dart';
import '../../core/services/preferences_storage.dart';
import '../../core/services/wallet_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/item_tile.dart';
import '../../core/widgets/product_picker_sheet.dart';
import '../optimizer/optimizer_screen.dart';
import '../trip/trip_controller.dart';
import '../trip/trip_screen.dart';
import 'amount_editor.dart';
import 'shopping_list_controller.dart';
import '../household/household_screen.dart';
import '../account/account_screen.dart';
import '../../core/services/list_sync.dart';
import '../../core/services/household_service.dart';

/// Unsicher zugeordneter Freitext, den der Nutzer prüfen sollte.
bool itemNeedsCheck(ShoppingListItem item) {
  final matched = item.matchedProduct;
  final explicit = matched != null && (matched.name == item.rawText || genericName(matched) == item.rawText);
  if (item.isChecked || explicit) return false;
  // Text gehört klar zu einer anderen Warengruppe als das Produkt (z. B. "saft" → Thunfisch)
  if (matched != null && ItemIcons.contradicts(item.rawText, matched)) return true;
  return CatalogService.isUncertain(item.rawText);
}

String itemIcon(ShoppingListItem item) => ItemIcons.iconFor(item.rawText, product: item.matchedProduct);

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  static const _keyViewMode = 'list_view_tiles_v1';

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Product> _suggestions = [];
  bool _tiles = true;

  @override
  void initState() {
    super.initState();
    PreferencesStorage.loadJson(_keyViewMode).then((v) {
      if (v is bool && mounted) setState(() => _tiles = v);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() => _tiles = !_tiles);
    PreferencesStorage.saveJson(_keyViewMode, _tiles);
  }

  void _onSearchChanged(String query) {
    // Menge gehört nicht zur Suche: "500 g erdb" sucht "erdb"
    final name = parseItemInput(query).name;
    setState(() => _suggestions = name.trim().isEmpty ? [] : CatalogService.getSuggestions(name, limit: 5));
  }

  void _submitItem([Product? selectedProduct]) {
    final text = _inputController.text.trim();
    if (text.isEmpty && selectedProduct == null) return;
    ref.read(shoppingListProvider.notifier).addItem(text, matchedProduct: selectedProduct);
    _inputController.clear();
    setState(() => _suggestions = []);
    _focusNode.requestFocus(); // Schnell mehrere Artikel nacheinander eingeben
  }

  Future<void> _showMatchPicker(ShoppingListItem item) async {
    final chosen = await showProductPicker(context, item.rawText);
    if (chosen != null) ref.read(shoppingListProvider.notifier).assignProduct(item.id, chosen);
  }

  void _openItem(ShoppingListItem item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Consumer(builder: (ctx, ref, _) {
        final current = ref.watch(shoppingListProvider).items.where((i) => i.id == item.id).firstOrNull;
        if (current == null) return const SizedBox(height: 120);
        final ctrl = ref.read(shoppingListProvider.notifier);
        final needsCheck = itemNeedsCheck(current);
        final cat = ItemIcons.categoryFor(current.rawText, product: current.matchedProduct);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  ItemIconBox(itemIcon(current), size: 56),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(current.rawText, style: AppText.title.copyWith(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        current.matchedProduct == null
                            ? 'Kein Katalog-Treffer · ${cat.name}'
                            : '${current.matchedProduct!.brand ?? 'Eigenmarke'} · ${cat.name}',
                        style: AppText.small,
                      ),
                    ]),
                  ),
                ]),
                if (needsCheck) ...[
                  const SizedBox(height: AppSpace.m),
                  Container(
                    padding: const EdgeInsets.all(AppSpace.m),
                    decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: AppRadius.medium),
                    child: Text(
                      current.matchedProduct == null
                          ? 'Für diesen Text kennt die App kein Produkt. Ohne Zuordnung hat er keinen Preis.'
                          : 'Unsicher: Gemeint ist vielleicht „${current.matchedProduct!.name}“. Bitte prüfen.',
                      style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpace.l),
                AmountEditor(
                  amount: current.amount,
                  suggested: suggestedUnit(current.matchedProduct),
                  onChanged: (a) => ctrl.setAmount(current.id, a),
                ),
                const SizedBox(height: AppSpace.m),
                OutlinedButton.icon(
                  icon: const Icon(Icons.manage_search_rounded),
                  label: Text(current.matchedProduct == null ? 'Produkt zuordnen' : 'Anderes Produkt wählen'),
                  onPressed: () => _showMatchPicker(current),
                ),
                if (current.isChecked) ...[
                  const SizedBox(height: AppSpace.s),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.undo_rounded),
                    label: const Text('Wieder offen'),
                    onPressed: () => ctrl.toggleChecked(current.id),
                  ),
                ],
                const SizedBox(height: AppSpace.s),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Von der Liste entfernen'),
                  onPressed: () {
                    ctrl.removeItem(current.id);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Liste leeren?'),
        content: const Text('Alle Artikel werden von der Liste entfernt.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              ref.read(shoppingListProvider.notifier).clearList();
              Navigator.pop(ctx);
            },
            child: const Text('Leeren'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shoppingListProvider);
    final trip = ref.watch(tripProvider);
    final items = state.items;
    final check = items.where(itemNeedsCheck).toList();
    final rest = items.where((i) => !itemNeedsCheck(i)).toList();

    // Nach Warengruppe gruppieren, Standard-Reihenfolge
    final groups = <String, List<ShoppingListItem>>{};
    for (final it in rest) {
      groups.putIfAbsent(ItemIcons.categoryFor(it.rawText, product: it.matchedProduct).id, () => []).add(it);
    }
    final order = ItemIcons.defaultOrder.where(groups.containsKey).toList();
    final withoutPrice = items.where((i) => i.matchedProduct == null && !i.isChecked).length;
    final openCount = items.where((i) => !i.isChecked).length;

    return Scaffold(
      appBar: AppBar(
        title: const HouseholdTitle(title: 'Einkaufsliste'),
        actions: [
          IconButton(
            tooltip: _tiles ? 'Als Liste anzeigen' : 'Als Kacheln anzeigen',
            icon: Icon(_tiles ? Icons.view_list_outlined : Icons.grid_view_outlined),
            onPressed: _toggleView,
          ),
          IconButton(
            tooltip: 'Liste leeren',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: items.isEmpty ? null : _confirmClear,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => _focusNode.unfocus(),
        child: CustomScrollView(
          slivers: [
            if (trip != null) SliverToBoxAdapter(child: _TripBanner(trip: trip)),
            SliverToBoxAdapter(child: _buildInput()),
            const SliverToBoxAdapter(child: _SyncBar()),
            const SliverToBoxAdapter(child: _OfferStatusBar()),
            if (items.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _buildEmpty())
            else ...[
              if (check.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader('Bitte prüfen (${check.length})',
                      trailing: const Text('antippen', style: TextStyle(fontSize: 12, color: AppColors.warning))),
                ),
                _buildItems(check),
              ],
              for (final catId in order) ...[
                SliverToBoxAdapter(child: SectionHeader(ItemIcons.byId(catId).name)),
                _buildItems(groups[catId]!),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: AppSpace.xl)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.m, AppSpace.l, AppSpace.m),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.s),
                  child: Text(
                    '$openCount Artikel'
                    '${withoutPrice > 0 ? ' · $withoutPrice ohne Preis' : ''}'
                    '${check.isNotEmpty ? ' · ${check.length} prüfen' : ''}',
                    style: AppText.small,
                    textAlign: TextAlign.center,
                  ),
                ),
              FilledButton.icon(
                icon: const Icon(Icons.route_rounded),
                label: Text(trip != null ? 'Neu planen' : 'Einkauf planen'),
                onPressed: openCount == 0
                    ? null
                    : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OptimizerResultScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.s, AppSpace.l, AppSpace.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _inputController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _submitItem(),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Was brauchst du?',
              prefixIcon: const Icon(Icons.add_rounded, color: AppColors.primary),
              suffixIcon: _inputController.text.isEmpty
                  ? null
                  : IconButton(tooltip: 'Hinzufügen', icon: const Icon(Icons.check_circle, color: AppColors.primary), onPressed: () => _submitItem()),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: AppSpace.s),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  for (final prod in _suggestions)
                    ListTile(
                      dense: true,
                      leading: ItemIconBox(ItemIcons.iconFor(prod.name, product: prod), size: 36),
                      title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(prod.isBio ? 'Bio' : (prod.brand ?? 'Eigenmarke'), style: AppText.tiny),
                      trailing: const Icon(Icons.add_rounded, color: AppColors.primary),
                      onTap: () => _submitItem(prod),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.all(AppSpace.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🛒', style: TextStyle(fontSize: 56)),
          SizedBox(height: AppSpace.m),
          Text('Deine Liste ist leer', style: AppText.title),
          SizedBox(height: AppSpace.xs),
          Text('Tippe oben, was du brauchst. Die App sucht danach die günstigste Route.',
              style: AppText.small, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildItems(List<ShoppingListItem> list) {
    if (_tiles) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
        // Reihen statt starrem Raster: Eine nicht volle Reihe wird auf die ganze
        // Breite gestreckt (breite Kacheln), so wirkt jede Warengruppe vollständig.
        sliver: SliverLayoutBuilder(builder: (context, constraints) {
          final cols = (constraints.crossAxisExtent / 112).floor().clamp(3, 6);
          final tileSize = (constraints.crossAxisExtent - (cols - 1) * AppSpace.s) / cols;
          final rows = <List<ShoppingListItem>>[
            for (var i = 0; i < list.length; i += cols) list.sublist(i, i + cols > list.length ? list.length : i + cols),
          ];
          return SliverList.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpace.s),
            itemBuilder: (context, r) {
              final row = rows[r];
              final full = row.length == cols;
              return SizedBox(
                height: full ? tileSize / 0.95 : 68,
                child: Row(children: [
                  for (var k = 0; k < row.length; k++) ...[
                    if (k > 0) const SizedBox(width: AppSpace.s),
                    Expanded(
                      child: ItemTile(
                        key: ValueKey(row[k].id),
                        icon: itemIcon(row[k]),
                        name: row[k].rawText,
                        amount: row[k].amount.label,
                        needsCheck: itemNeedsCheck(row[k]),
                        done: row[k].isChecked,
                        onTap: () => _openItem(row[k]),
                      ),
                    ),
                  ],
                ]),
              );
            },
          );
        }),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
      sliver: SliverList.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpace.xs),
        itemBuilder: (context, i) {
          final it = list[i];
          final needsCheck = itemNeedsCheck(it);
          final ctrl = ref.read(shoppingListProvider.notifier);
          return Dismissible(
            key: ValueKey(it.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpace.l),
              decoration: BoxDecoration(color: AppColors.danger, borderRadius: AppRadius.medium),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => ctrl.removeItem(it.id),
            child: Material(
              color: needsCheck ? AppColors.warningSoft : AppColors.surface,
              borderRadius: AppRadius.medium,
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.medium, side: const BorderSide(color: AppColors.line)),
                leading: ItemIconBox(itemIcon(it), size: 40, dimmed: it.isChecked),
                title: Text(
                  it.rawText,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    decoration: it.isChecked ? TextDecoration.lineThrough : null,
                    color: it.isChecked ? AppColors.inkSubtle : AppColors.ink,
                  ),
                ),
                subtitle: needsCheck
                    ? Text(it.matchedProduct == null ? 'Kein Katalog-Treffer, tippen' : 'Unsicher, tippen zum Prüfen',
                        style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500))
                    : null,
                // Nur das Ding an sich; Menge klein daneben, wenn angegeben
                trailing: it.amount.isDefault
                    ? null
                    : Text(it.amount.label,
                        key: ValueKey('amount_${it.id}'),
                        style: AppText.small.copyWith(color: AppColors.inkMuted, fontWeight: FontWeight.w500)),
                onTap: () => _openItem(it),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Hinweis auf einen laufenden Einkauf.
class _TripBanner extends StatelessWidget {
  final ShoppingTrip trip;
  const _TripBanner({required this.trip});

  @override
  Widget build(BuildContext context) {
    final stop = trip.stops.isEmpty ? null : trip.stops[trip.currentStop.clamp(0, trip.stops.length - 1)];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.s, AppSpace.l, 0),
      child: Material(
        color: AppColors.primaryDark,
        borderRadius: AppRadius.medium,
        child: InkWell(
          borderRadius: AppRadius.medium,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripScreen())),
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.m),
            child: Row(children: [
              const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Einkauf läuft', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(
                    '${trip.doneCount} von ${trip.totalCount} im Wagen${stop != null ? ' · ${stop.name}' : ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ]),
              ),
              const Text('Fortsetzen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Icon(Icons.chevron_right, color: Colors.white),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Wie aktuell sind die Angebote je Kette? Tippen öffnet die Wochenrunde.
class _OfferStatusBar extends StatelessWidget {
  const _OfferStatusBar();

  static const _chains = [
    SupermarketChain.rewe,
    SupermarketChain.lidl,
    SupermarketChain.aldi_sued,
    SupermarketChain.netto,
    SupermarketChain.dm,
    SupermarketChain.rossmann,
  ];

  static String _short(SupermarketChain c) => switch (c) {
        SupermarketChain.aldi_sued => 'ALDI',
        SupermarketChain.aldi_nord => 'ALDI Nord',
        SupermarketChain.dm => 'dm',
        _ => c.displayName,
      };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: WalletService.offersRevision,
      builder: (context, _, __) {
        final now = DateTime.now();
        final latest = <SupermarketChain, DateTime>{};
        for (final o in WalletService.weeklyOffers) {
          if (!o.id.startsWith('imp-') || !o.isValidAt(now) || o.validTo == null) continue;
          final cur = latest[o.chain];
          if (cur == null || o.validTo!.isAfter(cur)) latest[o.chain] = o.validTo!;
        }
        final missing = _chains.where((c) => !latest.containsKey(c)).length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.m, AppSpace.l, 0),
          child: InkWell(
            borderRadius: AppRadius.medium,
            onTap: () => AppTab.current.value = AppTab.offers,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
              decoration: BoxDecoration(
                color: missing == 0 ? AppColors.primaryFaint : AppColors.surface,
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.line),
              ),
              child: Row(children: [
                const Icon(Icons.local_offer_outlined, size: 18, color: AppColors.inkMuted),
                const SizedBox(width: AppSpace.s),
                Expanded(
                  child: Text(
                    latest.isEmpty
                        ? 'Noch keine Angebote übernommen'
                        : [
                            for (final c in _chains)
                              if (latest.containsKey(c)) '${_short(c)} bis ${latest[c]!.day}.${latest[c]!.month}.',
                            if (missing > 0) '$missing ${missing == 1 ? 'Kette' : 'Ketten'} offen',
                          ].join(' · '),
                    style: AppText.small,
                  ),
                ),
                const SizedBox(width: AppSpace.s),
                Text(missing == 0 ? 'aktuell' : 'Wochenrunde', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
              ]),
            ),
          ),
        );
      },
    );
  }
}

/// Zustand der gemeinsamen Liste: übernehmen, offline, abgemeldet, neu laden.
/// Unsichtbar, solange alles stimmt.
class _SyncBar extends ConsumerWidget {
  const _SyncBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(shoppingListProvider);
    if (!st.shared) return const SizedBox.shrink();
    final ctrl = ref.read(shoppingListProvider.notifier);
    final household = ref.watch(householdProvider).current?.name ?? 'den Haushalt';

    Widget bar(String text, {Color color = AppColors.surfaceAlt, Color ink = AppColors.inkMuted, List<Widget> actions = const []}) =>
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.m, AppSpace.l, 0),
          child: Container(
            key: const Key('sync_bar'),
            padding: const EdgeInsets.fromLTRB(AppSpace.m, AppSpace.s, AppSpace.xs, AppSpace.s),
            decoration: BoxDecoration(color: color, borderRadius: AppRadius.medium),
            child: Row(children: [
              Expanded(child: Text(text, style: AppText.small.copyWith(color: ink))),
              ...actions,
            ]),
          ),
        );

    if (st.needsReload) {
      return bar('Es gibt eine neue Version. Bitte die App neu laden.',
          color: AppColors.warningSoft, ink: AppColors.warning);
    }
    if (st.problem == SyncProblem.signedOut) {
      return bar('Anmeldung abgelaufen. Deine Änderungen bleiben auf dem Gerät.',
          color: AppColors.warningSoft,
          ink: AppColors.warning,
          actions: [
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen())),
              child: const Text('Anmelden'),
            ),
          ]);
    }
    if (st.problem == SyncProblem.offline) {
      final n = st.pendingCount;
      return bar(
          n == 0
              ? 'Offline. Du siehst den letzten Stand.'
              : 'Offline. ${n == 1 ? '1 Änderung wartet' : '$n Änderungen warten'} und geht raus, sobald wieder Netz da ist.',
          actions: [TextButton(onPressed: ctrl.syncNow, child: const Text('Erneut'))]);
    }
    if (st.importable > 0) {
      return bar(
          '${st.importable == 1 ? '1 Artikel' : '${st.importable} Artikel'} von diesem Gerät in "$household" übernehmen?',
          color: AppColors.primaryFaint,
          ink: AppColors.primaryDark,
          actions: [
            TextButton(key: const Key('import_no'), onPressed: ctrl.declineImport, child: const Text('Nein')),
            TextButton(key: const Key('import_yes'), onPressed: ctrl.importLocal, child: const Text('Übernehmen')),
          ]);
    }
    if (st.errorMessage != null) return bar(st.errorMessage!, color: AppColors.dangerSoft, ink: AppColors.danger);
    return const SizedBox.shrink();
  }
}
