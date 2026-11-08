// app/lib/features/my_apps/my_apps_screen.dart
// Strict adherence to Apple Human Interface Guidelines:
// - Clean inset-grouped lists (#F2F2F7 background, crisp white cards)
// - Native SF-style status pills & Cupertino action sheets
// - Transparent interface documentation & encrypted credential isolation

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/models/loyalty_wallet.dart';
import '../../core/models/store.dart';
import '../../core/services/wallet_service.dart';

class MyAppsScreen extends StatefulWidget {
  const MyAppsScreen({super.key});

  @override
  State<MyAppsScreen> createState() => _MyAppsScreenState();
}

class _MyAppsScreenState extends State<MyAppsScreen> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await WalletService.syncAllConnectedApps(force: true);
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alle verknüpften Konten synchronisiert ✅'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getChainColor(SupermarketChain chain) {
    switch (chain) {
      case SupermarketChain.lidl:
        return const Color(0xFF0050AA);
      case SupermarketChain.aldi_sued:
      case SupermarketChain.aldi_nord:
        return const Color(0xFF001A9C);
      case SupermarketChain.rewe:
        return const Color(0xFFCC071E);
      case SupermarketChain.netto:
        return const Color(0xFFE2A800);
      case SupermarketChain.dm:
        return const Color(0xFF2F2482);
      case SupermarketChain.rossmann:
        return const Color(0xFFC8102E);
    }
  }

  IconData _getChainIcon(SupermarketChain chain) {
    switch (chain) {
      case SupermarketChain.lidl:
        return Icons.shopping_bag_rounded;
      case SupermarketChain.aldi_sued:
      case SupermarketChain.aldi_nord:
        return Icons.storefront_rounded;
      case SupermarketChain.rewe:
        return Icons.credit_card_rounded;
      case SupermarketChain.netto:
        return Icons.card_giftcard_rounded;
      case SupermarketChain.dm:
        return Icons.health_and_safety_rounded;
      case SupermarketChain.rossmann:
        return Icons.discount_rounded;
    }
  }

  void _showAppDetailSheet(AppIntegrationInfo app) {
    final chainColor = _getChainColor(app.chain);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D6),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header with App Icon
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: chainColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_getChainIcon(app.chain), color: chainColor, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.programName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            app.description,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Imported Data Card (if connected)
                if (app.isConnected) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.sync_saved_locally_rounded, size: 18, color: Color(0xFF34C759)),
                            SizedBox(width: 8),
                            Text(
                              'Importierte Live-Daten',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...app.importedDataSummary.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, size: 16, color: Color(0xFF34C759)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(item, style: const TextStyle(fontSize: 13.5, color: Color(0xFF2C2C2E))),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sync-Rhythmus:', style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
                            Text('Alle ${app.syncIntervalHours} Stunden',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Technical API & Legal Transparency Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 18, color: Color(0xFF007AFF)),
                          SizedBox(width: 8),
                          Text(
                            'Schnittstelle & Datenschutz',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app.apiDocumentation,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF3A3A3C), height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Action Button
                if (app.isConnected) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text('Jetzt synchronisieren'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await WalletService.syncApp(app.id, force: true);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await WalletService.unlinkApp(app.id);
                        setState(() {});
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF3B30),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Verknüpfung aufheben'),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await WalletService.linkApp(app.id);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: Text('${app.programName} verknüpfen'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apps = WalletService.integratedApps;
    final connectedApps = apps.where((a) => a.isConnected).toList();
    final availableApps = apps.where((a) => !a.isConnected).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Apple System Grouped Background
      appBar: AppBar(
        title: const Text(
          'Meine Apps',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.4,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const CupertinoActivityIndicator(radius: 10)
                : const Icon(Icons.refresh_rounded, color: Color(0xFF007AFF)),
            onPressed: _isRefreshing ? null : _handleRefresh,
            tooltip: 'Alle synchronisieren',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // Section 1: Verknüpfte Apps
            if (connectedApps.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'VERKNÜPFTE BONUSPROGRAMME',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93), letterSpacing: 0.5),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: connectedApps.asMap().entries.map((entry) {
                    final isLast = entry.key == connectedApps.length - 1;
                    return Column(
                      children: [
                        _buildConnectedAppTile(entry.value),
                        if (!isLast) const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFE5E5EA)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Section 2: Verfügbare Apps
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'WEITERE VERFÜGBARE APPS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93), letterSpacing: 0.5),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: availableApps.asMap().entries.map((entry) {
                  final isLast = entry.key == availableApps.length - 1;
                  return Column(
                    children: [
                      _buildAvailableAppTile(entry.value),
                      if (!isLast) const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFE5E5EA)),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Hardware Keystore Guarantee Footer
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_rounded, size: 13, color: Color(0xFF8E8E93)),
                  SizedBox(width: 6),
                  Text(
                    'Tokens verschlüsselt in der iOS Secure Enclave gespeichert',
                    style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedAppTile(AppIntegrationInfo app) {
    final chainColor = _getChainColor(app.chain);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: chainColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_getChainIcon(app.chain), color: chainColor, size: 24),
      ),
      title: Text(
        app.programName,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1C1C1E)),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            app.statusMessage ?? 'Synchronisiert',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF34C759), fontWeight: FontWeight.w500),
          ),
          if (app.importedCouponsCount > 0 || app.pointsBalance > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${app.importedCouponsCount} Coupons • ${app.pointsBalance} Punkte',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93)),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFC7C7CC)),
      onTap: () => _showAppDetailSheet(app),
    );
  }

  Widget _buildAvailableAppTile(AppIntegrationInfo app) {
    final chainColor = _getChainColor(app.chain);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_getChainIcon(app.chain), color: Colors.grey.shade600, size: 24),
      ),
      title: Text(
        app.programName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5, color: Color(0xFF1C1C1E)),
      ),
      subtitle: Text(
        app.description,
        style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: TextButton(
        onPressed: () => _showAppDetailSheet(app),
        style: TextButton.styleFrom(
          backgroundColor: chainColor.withValues(alpha: 0.1),
          foregroundColor: chainColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Verbinden', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ),
      onTap: () => _showAppDetailSheet(app),
    );
  }
}
