// app/lib/core/models/store.dart

enum SupermarketChain {
  lidl,
  aldi_nord,
  aldi_sued,
  netto,
  rewe;

  String get displayName {
    switch (this) {
      case SupermarketChain.lidl:
        return 'Lidl';
      case SupermarketChain.aldi_nord:
        return 'ALDI Nord';
      case SupermarketChain.aldi_sued:
        return 'ALDI SÜD';
      case SupermarketChain.netto:
        return 'Netto';
      case SupermarketChain.rewe:
        return 'REWE';
    }
  }

  static SupermarketChain fromString(String val) {
    switch (val.toLowerCase().replaceAll(' ', '_')) {
      case 'lidl':
        return SupermarketChain.lidl;
      case 'aldi_nord':
      case 'aldi':
        return SupermarketChain.aldi_nord;
      case 'aldi_sued':
      case 'aldi_süd':
        return SupermarketChain.aldi_sued;
      case 'netto':
        return SupermarketChain.netto;
      case 'rewe':
        return SupermarketChain.rewe;
      default:
        return SupermarketChain.rewe;
    }
  }
}

class Store {
  final String id;
  final SupermarketChain chain;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int? clusterNum;
  final double? distanceMeters;

  const Store({
    required this.id,
    required this.chain,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.clusterNum,
    this.distanceMeters,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? '',
      chain: SupermarketChain.fromString(json['chain'] ?? 'rewe'),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 50.9335,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 6.9942,
      clusterNum: json['cluster_num'] ?? json['cluster_id'],
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chain': chain.name,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'cluster_num': clusterNum,
      'distance_meters': distanceMeters,
    };
  }
}
