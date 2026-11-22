// app/lib/features/stores_map/widgets/selected_store_sheet.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/store.dart';
import '../chain_style.dart';

/// Karte am unteren Rand mit Öffnungszeiten, Wegzeiten und „Von hier ausplanen".
class SelectedStoreSheet extends StatelessWidget {
  const SelectedStoreSheet({
    super.key,
    required this.store,
    required this.onClose,
    required this.onPlanFromStore,
  });

  final Store store;
  final VoidCallback onClose;
  final ValueChanged<Store> onPlanFromStore;

  @override
  Widget build(BuildContext context) {
    final chainColor = chainColorFor(store.chain);
    final distanceMeters = store.distanceMeters?.toInt() ?? 250;
    final walkMinutes = (distanceMeters / 75).ceil();
    final driveMinutes = math.max(1, (distanceMeters / 400).ceil());

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Chain Icon, Name, Badge, and Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: chainColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: chainColor.withValues(alpha: 0.25)),
                ),
                child: Icon(
                  store.chain == SupermarketChain.dm ||
                          store.chain == SupermarketChain.rossmann
                      ? Icons.clean_hands_rounded
                      : Icons.storefront_rounded,
                  color: chainColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      store.address,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded,
                    size: 20, color: Color(0xFF64748B)),
                tooltip: 'Schließen',
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Opening Hours Pill (prominent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF86EFAC).withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded,
                    size: 15, color: Color(0xFF15803D)),
                const SizedBox(width: 6),
                const Text(
                  'Geöffnet',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D)),
                ),
                const SizedBox(width: 6),
                Text(
                  '•  ${store.displayOpeningHours}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF166534)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Details row: Walking / Driving times & Cluster
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_walk_rounded,
                        size: 14, color: Color(0xFF475569)),
                    const SizedBox(width: 4),
                    Text(
                      '~$walkMinutes Min.',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_rounded,
                        size: 14, color: Color(0xFF475569)),
                    const SizedBox(width: 4),
                    Text(
                      '~$driveMinutes Min.',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cluster ${store.clusterNum ?? '-'}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary Action Button: "Von diesem Laden ausplanen"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              icon: const Icon(Icons.alt_route_rounded, size: 20),
              label: const Text(
                'Von diesem Laden ausplanen 🚀',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () => onPlanFromStore(store),
            ),
          ),
        ],
      ),
    );
  }
}
