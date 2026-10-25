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
        id: 'b-1',
        chain: SupermarketChain.aldi_sued,
        name: 'ALDI SÜD Bingen-Büdesheim',
        address: 'Saarlandstraße 165, 55411 Bingen am Rhein',
        latitude: 49.9545,
        longitude: 7.9172,
        clusterNum: 10,
        postalCode: '55411',
        city: 'Bingen am Rhein',
        distanceMeters: 80,
      ),
      const Store(
        id: 'b-2',
        chain: SupermarketChain.lidl,
        name: 'Lidl Filiale Bingen-Büdesheim',
        address: 'Saarlandstraße 171, 55411 Bingen am Rhein',
        latitude: 49.9542,
        longitude: 7.9160,
        clusterNum: 10,
        postalCode: '55411',
        city: 'Bingen am Rhein',
        distanceMeters: 120,
      ),
      const Store(
        id: 'b-3',
        chain: SupermarketChain.rewe,
        name: 'REWE Markt Bingen',
        address: 'Mainzer Straße 44, 55411 Bingen am Rhein',
        latitude: 49.9658,
        longitude: 7.9045,
        clusterNum: 11,
        postalCode: '55411',
        city: 'Bingen am Rhein',
        distanceMeters: 950,
      ),
      const Store(
        id: 'b-4',
        chain: SupermarketChain.dm,
        name: 'dm-drogerie markt Bingen',
        address: 'Vorstadt 10-12, 55411 Bingen am Rhein',
        latitude: 49.9662,
        longitude: 7.8965,
        clusterNum: 12,
        postalCode: '55411',
        city: 'Bingen am Rhein',
        distanceMeters: 1400,
      ),
      const Store(
        id: 'b-5',
        chain: SupermarketChain.rossmann,
        name: 'Rossmann Drogeriemarkt Bingen',
        address: 'Basilikastraße 3, 55411 Bingen am Rhein',
        latitude: 49.9670,
        longitude: 7.8940,
        clusterNum: 12,
        postalCode: '55411',
        city: 'Bingen am Rhein',
        distanceMeters: 1450,
      ),
      const Store(
        id: 'o-1',
        chain: SupermarketChain.netto,
        name: 'Netto Marken-Discount Oberwesel',
        address: 'Chrishausener Str. 2, 55430 Oberwesel',
        latitude: 50.1082,
        longitude: 7.7285,
        clusterNum: 20,
        postalCode: '55430',
        city: 'Oberwesel',
        distanceMeters: 350,
      ),
      const Store(
        id: 'o-2',
        chain: SupermarketChain.rewe,
        name: 'REWE City Oberwesel',
        address: 'Koblenzer Str. 18, 55430 Oberwesel',
        latitude: 50.1105,
        longitude: 7.7260,
        clusterNum: 20,
        postalCode: '55430',
        city: 'Oberwesel',
        distanceMeters: 550,
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
