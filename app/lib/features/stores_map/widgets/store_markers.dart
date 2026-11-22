// app/lib/features/stores_map/widgets/store_markers.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/store.dart';
import '../chain_style.dart';

/// Blauer Punkt für den Standort des Nutzers.
class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2563EB),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Marker für alle Filialen; [selectedStoreId] wird hervorgehoben.
List<Marker> buildStoreMarkers({
  required List<Store> stores,
  required String? selectedStoreId,
  required ValueChanged<Store> onStoreTap,
}) {
  return stores.map((store) {
    final isSelected = selectedStoreId == store.id;
    final chainColor = chainColorFor(store.chain);
    final badge = chainBadgeFor(store.chain);

    return Marker(
      point: LatLng(store.latitude, store.longitude),
      width: 68,
      height: 64,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // onTapDown löst SOFORT beim ersten Touch aus (kein Wisch-Konflikt!)
        onTapDown: (_) => onStoreTap(store),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Store Badge Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isSelected ? 0.4 : 0.2),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF10B981) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: chainColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    store.city ?? '',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1),

            // Pin Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: isSelected ? 40 : 32,
                  color: chainColor,
                ),
                Positioned(
                  top: isSelected ? 6 : 5,
                  child: Container(
                    width: isSelected ? 15 : 12,
                    height: isSelected ? 15 : 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      store.chain == SupermarketChain.dm ||
                              store.chain == SupermarketChain.rossmann
                          ? Icons.sanitizer_outlined
                          : Icons.shopping_basket_rounded,
                      size: isSelected ? 9 : 7,
                      color: chainColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }).toList();
}
