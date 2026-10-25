// app/lib/features/wallet/wallet_screen.dart

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
  List<LoyaltyAccount> _accounts = [];
  List<UserCoupon> _coupons = [];
  List<WeeklyOffer> _offers = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _accounts = WalletService.accounts;
      _coupons = WalletService.coupons;
      _offers = WalletService.weeklyOffers;
    });
  }

  Color _getChainColor(SupermarketChain chain) {
    switch (chain) {
      case SupermarketChain.lidl:
        return Colors.blue.shade700;
      case SupermarketChain.aldi_nord:
      case SupermarketChain.aldi_sued:
        return Colors.indigo.shade800;
      case SupermarketChain.netto:
        return Colors.orange.shade800;
      case SupermarketChain.rewe:
        return Colors.red.shade700;
      case SupermarketChain.dm:
        return Colors.purple.shade700;
      case SupermarketChain.rossmann:
        return Colors.red.shade900;
    }
  }

  void _editPoints(LoyaltyAccount acc) {
    final controller = TextEditingController(text: acc.pointsBalance.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${acc.programName} Punktestand'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Punkte-Guthaben',
            suffixText: 'Punkte',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              final newPoints = int.tryParse(controller.text) ?? acc.pointsBalance;
              WalletService.updatePoints(acc.chain, newPoints);
              Navigator.pop(ctx);
              _refresh();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
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
    final totalPointsValue = _accounts.fold<double>(0, (acc, a) => acc + a.pointsValueEuros);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bonus-Wallet & Angebote', style: TextStyle(fontWeight: FontWeight.bold)),
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
          // Total Loyalty Value Hero Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wallet, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text('GESAMTES PUNKTE-GUTHABEN', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${totalPointsValue.toStringAsFixed(2)} €',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Über ${_accounts.where((a) => a.pointsBalance > 0).length} aktive Treueprogramme',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Retail Loyalty Accounts
          Row(
            children: [
              const Icon(Icons.credit_card, color: Colors.teal),
              const SizedBox(width: 8),
              Text('Deine Kundenkarten & Punktestände', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),

          ..._accounts.map((acc) {
            final chainColor = _getChainColor(acc.chain);
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: chainColor.withOpacity(0.2)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: chainColor.withOpacity(0.1),
                  child: Icon(Icons.loyalty, color: chainColor),
                ),
                title: Row(
                  children: [
                    Text(acc.programName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text('(${acc.chain.displayName})', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                subtitle: Text('${acc.pointsBalance} Punkte • entspricht ${acc.pointsValueEuros.toStringAsFixed(2)} €'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _editPoints(acc),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // 2. Active User Coupons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text('Aktive Coupons (${_coupons.where((c) => c.isActive).length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Coupon'),
                onPressed: _showAddCouponDialog,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Aktive Coupons werden automatisch in der Routen-Optimierung angerechnet.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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

          // 3. Weekly Promotional Offers from Brochures
          Row(
            children: [
              const Icon(Icons.campaign, color: Colors.teal),
              const SizedBox(width: 8),
              Text('Wöchentliche Prospekt-Angebote', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    '-${off.discountPercent}%',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
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
