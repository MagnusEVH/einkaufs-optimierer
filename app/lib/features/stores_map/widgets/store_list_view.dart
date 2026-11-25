// app/lib/features/stores_map/widgets/store_list_view.dart

import 'package:flutter/material.dart';
import '../../../core/models/store.dart';
import '../chain_style.dart';
import '../../../core/theme/app_theme.dart';

/// Listenansicht der gefilterten Filialen.
class StoreListView extends StatelessWidget {
  const StoreListView({
    super.key,
    required this.stores,
    required this.selectedStoreId,
    required this.onPlanFromStore,
  });

  final List<Store> stores;
  final String? selectedStoreId;
  final ValueChanged<Store> onPlanFromStore;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: stores.length,
      itemBuilder: (ctx, index) {
        final store = stores[index];
        final chainColor = chainColorFor(store.chain);
        final isSelected = selectedStoreId == store.id;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : Colors.black.withValues(alpha: 0.08),
              width: isSelected ? 2 : 1,
            ),
          ),
          color: isSelected ? AppColors.primaryFaint : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: chainColor.withValues(alpha: 0.15),
                  child: Icon(
                    store.chain == SupermarketChain.dm ||
                            store.chain == SupermarketChain.rossmann
                        ? Icons.sanitizer_outlined
                        : Icons.storefront_rounded,
                    color: chainColor,
                    size: 20,
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
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        store.address,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.inkSubtle),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            store.displayOpeningHours,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary),
                          ),
                          const Spacer(),
                          Text(
                            'Cluster ${store.clusterNum ?? '-'}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.inkSubtle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                    foregroundColor: AppColors.primaryDark,
                  ),
                  tooltip: 'Von hier ausplanen',
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  onPressed: () => onPlanFromStore(store),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
