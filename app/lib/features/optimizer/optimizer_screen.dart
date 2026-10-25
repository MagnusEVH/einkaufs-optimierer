// app/lib/features/optimizer/optimizer_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/optimization_result.dart';
import '../../core/models/store.dart';
import '../../core/models/user_preferences.dart';
import '../../core/services/location_service.dart';
import '../../core/services/optimizer_service.dart';
import '../shopping_list/shopping_list_controller.dart';

class OptimizerResultScreen extends ConsumerStatefulWidget {
  const OptimizerResultScreen({super.key});

  @override
  ConsumerState<OptimizerResultScreen> createState() => _OptimizerResultScreenState();
}

class _OptimizerResultScreenState extends ConsumerState<OptimizerResultScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  OptimizationResult? _result;
  UserLocation? _userLocation;

  @override
  void initState() {
    super.initState();
    _runOptimization();
  }

  Future<void> _runOptimization() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = ref.read(shoppingListProvider).items;
      final location = await LocationService.getCurrentLocation();
      _userLocation = location;

      final res = await OptimizerService.optimizeShoppingList(
        userLocation: location,
        items: items,
        preferences: const UserPreferences(),
      );

      setState(() {
        _result = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Color _getChainColor(SupermarketChain chain) {
    switch (chain) {
      case SupermarketChain.lidl:
        return Colors.blue.shade700;
      case SupermarketChain.aldi_nord:
      case SupermarketChain.aldi_sued:
        return Colors.indigo.shade800;
      case SupermarketChain.rewe:
        return Colors.red.shade700;
      case SupermarketChain.netto:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routen- & Preisoptimierung', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Neu berechnen',
            onPressed: _isLoading ? null : _runOptimization,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.teal),
                  const SizedBox(height: 16),
                  const Text('Berechne günstigste Filialen & Cluster...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Vergleiche Preise bei Lidl, Aldi & Rewe', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _runOptimization,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Erneut versuchen'),
                        ),
                      ],
                    ),
                  ),
                )
              : _result == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Net Savings Hero Card
                        _buildHeroSavingsCard(theme),
                        const SizedBox(height: 16),

                        // Comparison Card: Single Store vs Multi Store
                        _buildComparisonCard(theme),
                        const SizedBox(height: 20),

                        // Section Title: Route Stops
                        Row(
                          children: [
                            const Icon(Icons.pin_drop, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text('Geplante Einkaufs-Route', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text('${_result!.stops.length} Stopps', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List of Stops
                        ..._result!.stops.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final stop = entry.value;
                          final isLast = idx == _result!.stops.length - 1;

                          return Column(
                            children: [
                              _buildStopCard(stop, theme),
                              if (!isLast) _buildClusterConnector(stop, _result!.stops[idx + 1]),
                            ],
                          );
                        }),
                      ],
                    ),
    );
  }

  Widget _buildHeroSavingsCard(ThemeData theme) {
    final summary = _result!.summary;
    final isMulti = _result!.isMultiStore;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMulti
              ? [Colors.teal.shade800, Colors.teal.shade600]
              : [Colors.blueGrey.shade800, Colors.blueGrey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isMulti ? '⭐ EMPFOHLENE ROUTE' : 'ℹ️ BEQUEMSTE ROUTE',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              if (isMulti)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${summary.netSavingsEuros.toStringAsFixed(2)} € Netto-Ersparnis',
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${summary.totalBasketPriceEuros.toStringAsFixed(2)} €',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            isMulti
                ? 'Optimiert über ${summary.totalStops} Läden im selben Cluster'
                : 'Gesamter Einkauf in einer einzigen Filiale',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem('Ersparnis brutto', '${summary.grossSavingsEuros.toStringAsFixed(2)} €'),
              _buildMetricItem('Fahrtkosten-Abzug', '-${summary.travelPenaltyEuros.toStringAsFixed(2)} €'),
              _buildMetricItem('Gesamtstrecke', '${summary.routeDistanceKm.toStringAsFixed(1)} km'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildComparisonCard(ThemeData theme) {
    final baseline = _result!.baselineSingleStore;
    if (baseline == null) return const SizedBox.shrink();

    final singlePrice = ((baseline['total_basket_price_cents'] as int?) ?? 0) / 100.0;
    final singleName = baseline['name'] ?? 'Einzelladen';
    final isMulti = _result!.isMultiStore;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isMulti ? Icons.compare_arrows : Icons.check_circle_outline,
              color: Colors.teal,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vergleich: Einzelladen-Lösung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    '$singleName: ${singlePrice.toStringAsFixed(2)} €',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
            if (isMulti)
              Text(
                '-${_result!.summary.netSavingsEuros.toStringAsFixed(2)} €',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopCard(RouteStop stop, ThemeData theme) {
    final chainColor = _getChainColor(stop.chain);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: chainColor.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: chainColor,
                  radius: 14,
                  child: Text(
                    '${stop.stopIndex}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stop.storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(stop.address, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: chainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stop.chain.displayName,
                    style: TextStyle(color: chainColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Hier kaufen (${stop.items.length} Artikel):',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            ...stop.items.map((it) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_box_outline_blank, size: 18, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${it.quantity.toInt()}x ${it.itemName}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '${it.totalPriceEuros.toStringAsFixed(2)} €',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Zwischensumme:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${stop.stopSubtotalEuros.toStringAsFixed(2)} €',
                  style: TextStyle(color: chainColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterConnector(RouteStop from, RouteStop to) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_walk, size: 16, color: Colors.teal),
                SizedBox(width: 6),
                Text(
                  'Gemeinsames Cluster (< 500 m) • 0 € Umwegkosten',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
