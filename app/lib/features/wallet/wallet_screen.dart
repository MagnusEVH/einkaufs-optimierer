// app/lib/features/wallet/wallet_screen.dart
//
// Refactored: Now a pure "Angebote" (Deals) feed.
// Loyalty accounts / Kundenkarten have moved to MyAppsScreen.

import 'package:flutter/material.dart';
import '../../core/models/loyalty_wallet.dart';
import '../../core/models/store.dart';
import '../../core/services/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<UserCoupon> _coupons = [];
  List<WeeklyOffer> _offers = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _coupons = WalletService.coupons;
      _offers = WalletService.weeklyOffers;
    });
  }

  Color _getChainColor(SupermarketChain chain) {
    switch (chain) {
      case SupermarketChain.lidl:
        return const Color(0xFF0050AA);
      case SupermarketChain.aldi_nord:
      case SupermarketChain.aldi_sued:
        return const Color(0xFF001A9C);
      case SupermarketChain.netto:
        return const Color(0xFFE2A800);
      case SupermarketChain.rewe:
        return const Color(0xFFCC071E);
      case SupermarketChain.dm:
        return const Color(0xFF2F2482);
      case SupermarketChain.rossmann:
        return const Color(0xFFC8102E);
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
              const Text('Coupon manuell hinzufügen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  style: FilledButton.styleFrom(backgroundColor: Colors.teal),
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
                  child: const Text('Coupon speichern', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final theme = Theme.of(context);
    final activeCoupons = _coupons.where((c) => c.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Angebote & Coupons', style: TextStyle(fontWeight: FontWeight.bold)),
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
          // Hero Banner: Deals Overview
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_offer_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text('AKTIVE ANGEBOTE', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$activeCoupons Coupons',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '+ ${_offers.length} Wochenangebote',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Alle aktiven Coupons fließen automatisch in die Routen-Optimierung ein.',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Active Coupons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text('Aktive Coupons ($activeCoupons)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
          Text(
            'Manuell hinzugefügt oder über „Meine Apps" importiert.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),

          ..._coupons.map((coup) {
            final chainColor = _getChainColor(coup.chain);
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: coup.isActive ? Colors.teal.shade300 : theme.dividerColor.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: chainColor.withOpacity(0.1),
                  child: Text(
                    coup.discountType == 'percent' ? '${coup.discountValue.toInt()}%' : '€',
                    style: TextStyle(color: chainColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                title: Text(coup.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${coup.chain.displayName}${coup.minSpendCents > 0 ? " • Ab ${(coup.minSpendCents / 100).toStringAsFixed(2)} €" : ""}',
                ),
                trailing: Switch(
                  value: coup.isActive,
                  activeColor: Colors.teal,
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
              const Icon(Icons.campaign, color: Color(0xFF059669)),
              const SizedBox(width: 8),
              Text('Wöchentliche Angebote', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Aktuelle Prospekt-Angebote aus Bingen, Oberwesel & Umgebung.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),

          ..._offers.map((off) {
            final chainColor = _getChainColor(off.chain);
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: chainColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: chainColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '-${off.discountPercent}%',
                    style: TextStyle(color: chainColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                title: Text(off.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${off.chain.displayName} • ${off.title}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${off.discountPriceEuros.toStringAsFixed(2)} €',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'statt ${off.regularPriceEuros.toStringAsFixed(2)} €',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11, decoration: TextDecoration.lineThrough),
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
