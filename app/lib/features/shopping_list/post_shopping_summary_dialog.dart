// app/lib/features/shopping_list/post_shopping_summary_dialog.dart
// Post-Shopping Savings & Receipt Summary following Apple Human Interface Guidelines:
// - Verifiable, transparent calculations (no fictional savings)
// - Clean Cupertino modal sheet presentation
// - Large readable figures & clear breakdown between purchased vs. skipped items

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/models/list_item.dart';
import '../../core/services/analytics_service.dart';

class PostShoppingSummarySheet extends StatelessWidget {
  final List<ShoppingListItem> purchasedItems;
  final List<ShoppingListItem> skippedItems;
  final VoidCallback onFinishAndClear;

  const PostShoppingSummarySheet({
    super.key,
    required this.purchasedItems,
    required this.skippedItems,
    required this.onFinishAndClear,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate realistic expenditures
    int totalEstimatedCents = 0;
    int totalSavingsCents = 0;

    for (final it in purchasedItems) {
      final product = it.matchedProduct;
      if (product != null && product.prices.isNotEmpty) {
        final sortedPrices = product.prices.values.toList()..sort();
        final bestPrice = sortedPrices.first;
        final maxStorePrice = sortedPrices.last;
        final qty = it.quantity;

        totalEstimatedCents += (bestPrice * qty).round();
        if (maxStorePrice > bestPrice) {
          totalSavingsCents += ((maxStorePrice - bestPrice) * qty).round();
        }
      }
    }

    final totalItemsCount = purchasedItems.length + skippedItems.length;
    final completionRate = totalItemsCount > 0 ? (purchasedItems.length / totalItemsCount * 100).round() : 100;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7), // Apple System Grouped Background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Apple Modal Drag Handle
              Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 18),

              // Celebration Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: Color(0xFF34C759),
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Einkauf abgeschlossen!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completionRate% deiner Einkaufsliste erledigt',
                style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 20),

              // Metrics Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gekaufte Artikel',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF3A3A3C)),
                        ),
                        Text(
                          '${purchasedItems.length} von $totalItemsCount',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Geschätzte Ausgaben',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF3A3A3C)),
                        ),
                        Text(
                          totalEstimatedCents > 0
                              ? '${(totalEstimatedCents / 100).toStringAsFixed(2)} €'
                              : '–',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_offer_rounded, size: 18, color: Color(0xFF34C759)),
                            SizedBox(width: 6),
                            Text(
                              'Nachweisbare Ersparnis',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF34C759)),
                            ),
                          ],
                        ),
                        Text(
                          totalSavingsCents > 0
                              ? '${(totalSavingsCents / 100).toStringAsFixed(2)} €'
                              : '0,00 €',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF34C759)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (skippedItems.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: Color(0xFFFF9500)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${skippedItems.length} Artikel nicht abgehakt (bleiben auf deiner Liste).',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF8E5A00)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Apple Primary Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    AnalyticsService.trackShoppingRouteCompleted(
                      stopCount: 1,
                      totalSavingsCents: totalSavingsCents,
                      itemsPurchasedCount: purchasedItems.length,
                      itemsSkippedCount: skippedItems.length,
                    );
                    Navigator.pop(context);
                    onFinishAndClear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Erledigte Artikel aufräumen & fertig'),
                ),
              ),
              const SizedBox(height: 8),
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Später aufräumen', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
