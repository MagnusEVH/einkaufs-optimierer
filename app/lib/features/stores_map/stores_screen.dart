// app/lib/features/stores_map/stores_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/store.dart';
import '../../core/services/location_service.dart';
import '../../core/services/optimizer_service.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  UserLocation? _location;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final loc = await LocationService.getCurrentLocation();
    setState(() {
      _location = loc;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stores = [
      const Store(
        id: '1',
        chain: SupermarketChain.lidl,
        name: 'Lidl Filiale Köln Kalk',
        address: 'Rolshover Str. 11, 51105 Köln',
        latitude: 50.9335,
        longitude: 6.9942,
        clusterNum: 1,
        distanceMeters: 450,
      ),
      const Store(
        id: '2',
        chain: SupermarketChain.rewe,
        name: 'REWE Center Kalk',
        address: 'Kalker Hauptstraße 55, 51103 Köln',
        latitude: 50.9348,
        longitude: 6.9965,
        clusterNum: 1,
        distanceMeters: 620,
      ),
      const Store(
        id: '3',
        chain: SupermarketChain.aldi_sued,
        name: 'ALDI SÜD Köln Deutz',
        address: 'Siegburger Str. 149, 50679 Köln',
        latitude: 50.9270,
        longitude: 6.9805,
        clusterNum: 2,
        distanceMeters: 1800,
      ),
      const Store(
        id: '4',
        chain: SupermarketChain.lidl,
        name: 'Lidl Filiale Köln Deutz',
        address: 'Deutzer Freiheit 70, 50679 Köln',
        latitude: 50.9290,
        longitude: 6.9775,
        clusterNum: 2,
        distanceMeters: 1950,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filialen im Umkreis', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.share_location, color: Colors.teal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Filial-Clustering aktiv (< 500 m)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                            const SizedBox(height: 2),
                            Text(
                              'Läden mit derselben Cluster-ID liegen in Gehdistanz. Einkäufe werden ohne Umwegstrafe aufgeteilt.',
                              style: TextStyle(fontSize: 12, color: Colors.teal.shade900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                ...stores.map((s) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Icon(Icons.storefront, color: Colors.teal.shade800),
                        ),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${s.address}\nDistanz: ${s.distanceMeters?.toInt()} m'),
                        trailing: Chip(
                          label: Text('Cluster ${s.clusterNum}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.teal.shade50,
                          side: BorderSide(color: Colors.teal.shade300),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
