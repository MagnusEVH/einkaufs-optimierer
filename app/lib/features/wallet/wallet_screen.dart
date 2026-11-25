// app/lib/features/wallet/wallet_screen.dart
//
// Refactored: Now a pure "Angebote" (Deals) feed.
// Loyalty accounts / Kundenkarten have moved to MyAppsScreen.

import 'package:flutter/material.dart';
import '../../core/models/loyalty_wallet.dart';
import '../../core/models/store.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/wallet_service.dart';
import 'weekly_round_card.dart';
import '../../core/theme/app_theme.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<UserCoupon> _coupons = [];
  List<WeeklyOffer> _offers = [];
  int _expiredCount = 0;

  @override
  void initState() {
    super.initState();
    WalletService.offersRevision.addListener(_refresh);
    _refresh();
  }

  @override
  void dispose() {
    WalletService.offersRevision.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _refresh() async {
    await WalletService.loadScrapedOffers();
    final offers = WalletService.weeklyOffers;
    final now = DateTime.now();
    final valid = offers.where((o) => o.isValidAt(now)).toList();
    if (mounted) {
      setState(() {
        _coupons = WalletService.coupons;
        _offers = valid;
        _expiredCount = offers.length - valid.length;
      });
    }
  }

  void _showAddCouponDialog() {
    SupermarketChain selectedChain = SupermarketChain.rewe;
    final titleController = TextEditingController();
    final valueController = TextEditingController(text: '10');
    final minSpendController = TextEditingController(text: '0');
    String discountType = 'percent';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coupon manuell hinzufügen', style: AppText.title),
              const SizedBox(height: 16),
              DropdownButtonFormField<SupermarketChain>(
                value: selectedChain,
                decoration: const InputDecoration(labelText: 'Supermarkt-Kette', border: OutlineInputBorder()),
                items: SupermarketChain.values.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName))).toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedChain = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Coupon-Titel (z. B. 15% auf Molkereiprodukte)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: discountType,
                      decoration: const InputDecoration(labelText: 'Rabatt-Art', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'percent', child: Text('Prozent (%)')),
                        DropdownMenuItem(value: 'fixed_amount', child: Text('Betrag (€)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => discountType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: valueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: discountType == 'percent' ? 'Rabatt in %' : 'Rabatt in Cent',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minSpendController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mindesteinkaufswert in Euro (optional, 0 = kein)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    final val = double.tryParse(valueController.text) ?? 10.0;
                    final minSpendEuro = double.tryParse(minSpendController.text) ?? 0.0;

                    WalletService.addCoupon(UserCoupon(
                      id: 'coup-${DateTime.now().millisecondsSinceEpoch}',
                      chain: selectedChain,
                      title: title,
                      discountType: discountType,
                      discountValue: val,
                      minSpendCents: (minSpendEuro * 100).round(),
                      isActive: true,
                    ));

                    Navigator.pop(ctx);
                    _refresh();
                  },
                  child: const Text('Coupon speichern', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCoupons = _coupons.where((c) => c.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Angebote & Coupons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card),
            tooltip: 'Coupon hinzufügen',
            onPressed: _showAddCouponDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Überblick: nur Zahlen, ruhige Fläche
          Container(
            padding: const EdgeInsets.all(AppSpace.xxl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.large,
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aktive Angebote', style: AppText.small),
                const SizedBox(height: AppSpace.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$activeCoupons Coupons', style: AppText.figure),
                    const SizedBox(width: AppSpace.s),
                    Text('und ${_offers.length} Wochenangebote', style: AppText.small.copyWith(fontFeatures: AppText.tab)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.l),
          const WeeklyRoundCard(),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined, color: AppColors.inkMuted),
              title: const Text('Kassenbon einlesen', style: AppText.bodyStrong),
              subtitle: const Text('Papierbon fotografieren oder eBon aus der REWE-App (PDF) wählen: echte Preise deiner Filiale. Alles bleibt auf dem Gerät.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => launchUrl(Uri.base.resolve('bon.html'), webOnlyWindowName: '_self'),
            ),
          ),
          const SizedBox(height: 20),

          // ── Active Coupons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_offer_outlined, size: 20, color: AppColors.inkMuted),
                  const SizedBox(width: 8),
                  Text('Aktive Coupons ($activeCoupons)', style: AppText.title.copyWith(fontSize: 17)),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Coupon'),
                onPressed: _showAddCouponDialog,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Manuell hinzugefügt oder über „Meine Apps" importiert.',
            style: TextStyle(fontSize: 12, color: AppColors.inkSubtle),
          ),
          const SizedBox(height: 10),

          ..._coupons.map((coup) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.medium,
                side: const BorderSide(color: AppColors.line),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.surfaceAlt,
                  child: Text(
                    coup.discountType == 'percent' ? '${coup.discountValue.toInt()} %' : '€',
                    style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500, fontSize: 13, fontFeatures: AppText.tab),
                  ),
                ),
                title: Text(coup.title, style: AppText.bodyStrong),
                subtitle: Text(
                  '${coup.chain.displayName}${coup.minSpendCents > 0 ? " · ab ${euro(coup.minSpendCents)}" : ""}',
                ),
                trailing: Switch(
                  value: coup.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (_) {
                    WalletService.toggleCoupon(coup.id);
                    _refresh();
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // ── Weekly Promotional Offers ──
          Row(
            children: [
              const Icon(Icons.campaign_outlined, size: 20, color: AppColors.inkMuted),
              const SizedBox(width: 8),
              Text('Wöchentliche Angebote', style: AppText.title.copyWith(fontSize: 17)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Beispieldaten und Angebote, die du mit dem Übernehmen-Knopf übernommen hast (Einrichtung: uebernehmen.html neben der App). Nur gültige Angebote werden angezeigt und im Optimierer berücksichtigt.',
            style: TextStyle(fontSize: 12, color: AppColors.inkSubtle),
          ),
          if (_expiredCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              '$_expiredCount abgelaufene Angebote ausgeblendet',
              style: const TextStyle(fontSize: 12, color: AppColors.inkSubtle),
            ),
          ],
          const SizedBox(height: 10),
          if (_offers.isEmpty)
            Card(
              elevation: 0,
              color: AppColors.surfaceAlt,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
              child: const ListTile(
                leading: Icon(Icons.event_busy_outlined),
                title: Text('Zurzeit keine gültigen Angebote'),
                subtitle: Text('Die Beispiel-Angebote sind abgelaufen. Echte Daten folgen mit der Datenquelle (D1).'),
              ),
            ),

          ..._offers.map((off) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.medium,
                side: const BorderSide(color: AppColors.line),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: AppSpace.s),
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: AppRadius.small,
                  ),
                  child: Text(
                    '−${off.discountPercent} %',
                    style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500, fontSize: 12, fontFeatures: AppText.tab),
                  ),
                ),
                title: Text(off.productName, style: AppText.bodyStrong),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      '${off.chain.displayName} · ${off.unitInfo ?? off.title}',
                      style: AppText.small,
                    ),
                    Text(
                      off.source ?? 'Beispieldaten',
                      style: AppText.tiny,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 14,
                          color: off.isExpired ? AppColors.danger : AppColors.inkSubtle,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          off.displayValidity,
                          style: TextStyle(
                            fontSize: 12,
                            color: off.isExpired ? AppColors.danger : AppColors.inkMuted,
                          ),
                        ),
                        if (off.daysRemaining != null && off.daysRemaining! <= 3 && !off.isExpired) ...[
                          const SizedBox(width: AppSpace.s),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warningSoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              off.daysRemaining == 0 ? 'Heute letztmals' : 'Noch ${off.daysRemaining} Tage',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      euro((off.discountPriceEuros * 100).round()),
                      style: AppText.price,
                    ),
                    Text(
                      'statt ${euro((off.regularPriceEuros * 100).round())}',
                      style: AppText.tiny.copyWith(fontFeatures: AppText.tab, decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
