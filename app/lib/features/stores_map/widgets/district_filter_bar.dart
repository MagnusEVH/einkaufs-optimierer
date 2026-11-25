// app/lib/features/stores_map/widgets/district_filter_bar.dart

import 'package:flutter/material.dart';
import '../../../core/models/store.dart';
import '../../../core/theme/app_theme.dart';

/// Chip-Leiste mit Landkreis- (Zeile 1) und Kategorie-Filter (Zeile 2).
class DistrictFilterBar extends StatelessWidget {
  const DistrictFilterBar({
    super.key,
    required this.activeDistrict,
    required this.activeChainFilter,
    required this.allStores,
    required this.onDistrictSelected,
    required this.onChainFilterSelected,
  });

  final String activeDistrict;
  final String activeChainFilter;

  /// Alle Filialen (ungefiltert) – daraus werden die Zahlen in den Chips berechnet.
  final List<Store> allStores;
  final ValueChanged<String> onDistrictSelected;
  final ValueChanged<String> onChainFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: District Isolation (Mainz-Bingen vs Rhein-Hunsrück)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Landkreis:',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkMuted),
                ),
                const SizedBox(width: 8),
                _districtChip('Alle', '${allStores.length}'),
                _districtChip('Mainz-Bingen', '${_countIn('Mainz-Bingen')}'),
                _districtChip(
                    'Rhein-Hunsrück', '${_countIn('Rhein-Hunsrück')}'),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Row 2: Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _categoryChip('Alle'),
                _categoryChip('Discounter'),
                _categoryChip('Supermarkt'),
                _categoryChip('Drogerie'),
                _categoryChip('Cluster (<500m)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _countIn(String district) =>
      allStores.where((s) => s.district == district).length;

  Widget _districtChip(String districtName, String count) {
    final isSelected = activeDistrict == districtName;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        selected: isSelected,
        label: Text('$districtName ($count)'),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF1E293B),
        ),
        selectedColor: AppColors.ink,
        backgroundColor: AppColors.surfaceAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(
          color: isSelected ? AppColors.ink : Colors.transparent,
        ),
        onSelected: (_) => onDistrictSelected(districtName),
      ),
    );
  }

  Widget _categoryChip(String filterName) {
    final isSelected = activeChainFilter == filterName;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(filterName),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.inkMuted,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
        onSelected: (_) => onChainFilterSelected(filterName),
      ),
    );
  }
}
