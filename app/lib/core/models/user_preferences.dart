// app/lib/core/models/user_preferences.dart

class UserPreferences {
  final String brandPreference; // 'prefer_private_label' | 'reject_private_label' | 'neutral'
  final String bioPreference; // 'prefer_bio' | 'neutral' | 'reject_bio'
  final Map<String, String> categoryStorePreferences; // e.g. {'obst': 'netto', 'gemuese': 'lidl'}
  final List<String> preferredChains;
  final String transportMode; // 'car', 'bike', 'walk'
  final double costPerKmCents; // e.g. 30.0 (0.30 EUR/km)
  final double minuteValueCents; // e.g. 15.0
  final int maxStops;
  final int searchRadiusMeters;

  const UserPreferences({
    this.brandPreference = 'prefer_private_label',
    this.bioPreference = 'neutral',
    this.categoryStorePreferences = const {
      'obst': 'netto',
      'gemuese': 'lidl',
    },
    this.preferredChains = const ['lidl', 'aldi_nord', 'aldi_sued', 'netto', 'rewe'],
    this.transportMode = 'car',
    this.costPerKmCents = 30.0,
    this.minuteValueCents = 15.0,
    this.maxStops = 2,
    this.searchRadiusMeters = 5000,
  });

  UserPreferences copyWith({
    String? brandPreference,
    String? bioPreference,
    Map<String, String>? categoryStorePreferences,
    List<String>? preferredChains,
    String? transportMode,
    double? costPerKmCents,
    double? minuteValueCents,
    int? maxStops,
    int? searchRadiusMeters,
  }) {
    return UserPreferences(
      brandPreference: brandPreference ?? this.brandPreference,
      bioPreference: bioPreference ?? this.bioPreference,
      categoryStorePreferences: categoryStorePreferences ?? this.categoryStorePreferences,
      preferredChains: preferredChains ?? this.preferredChains,
      transportMode: transportMode ?? this.transportMode,
      costPerKmCents: costPerKmCents ?? this.costPerKmCents,
      minuteValueCents: minuteValueCents ?? this.minuteValueCents,
      maxStops: maxStops ?? this.maxStops,
      searchRadiusMeters: searchRadiusMeters ?? this.searchRadiusMeters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_preference': brandPreference,
      'bio_preference': bioPreference,
      'category_store_preferences': categoryStorePreferences,
      'preferred_chains': preferredChains,
      'transport_mode': transportMode,
      'cost_per_km_cents': costPerKmCents,
      'minute_value_cents': minuteValueCents,
      'max_stops': maxStops,
      'search_radius_meters': searchRadiusMeters,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    final rawCatPrefs = json['category_store_preferences'] as Map<String, dynamic>? ?? {};
    final catPrefs = <String, String>{};
    rawCatPrefs.forEach((k, v) => catPrefs[k] = v.toString());

    return UserPreferences(
      brandPreference: json['brand_preference'] ?? 'prefer_private_label',
      bioPreference: json['bio_preference'] ?? 'neutral',
      categoryStorePreferences: catPrefs.isNotEmpty
          ? catPrefs
          : const {'obst': 'netto', 'gemuese': 'lidl'},
      preferredChains: (json['preferred_chains'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['lidl', 'aldi_nord', 'aldi_sued', 'netto', 'rewe'],
      transportMode: json['transport_mode'] ?? 'car',
      costPerKmCents: (json['cost_per_km_cents'] as num?)?.toDouble() ?? 30.0,
      minuteValueCents: (json['minute_value_cents'] as num?)?.toDouble() ?? 15.0,
      maxStops: json['max_stops'] ?? 2,
      searchRadiusMeters: json['search_radius_meters'] ?? 5000,
    );
  }
}
