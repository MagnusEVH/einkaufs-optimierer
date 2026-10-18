// app/lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/user_preferences.dart';
import '../../core/services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _costPerKm = 30.0;
  int _maxStops = 2;
  bool _preferPrivateLabel = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SupabaseService.fetchPreferences();
    setState(() {
      _costPerKm = prefs.costPerKmCents;
      _maxStops = prefs.maxStops;
      _preferPrivateLabel = prefs.preferPrivateLabel;
    });
  }

  Future<void> _savePreferences() async {
    final updated = UserPreferences(
      costPerKmCents: _costPerKm,
      maxStops: _maxStops,
      preferPrivateLabel: _preferPrivateLabel,
    );
    await SupabaseService.savePreferences(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einstellungen gespeichert')),
      );
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konto und Daten löschen?'),
        content: const Text(
          'Gemäß Art. 17 DSGVO werden alle deine Einkaufslisten, Präferenzen und persönlichen Daten unwiderruflich aus der Datenbank gelöscht.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await SupabaseService.deleteUserAccount();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alle Nutzerdaten wurden erfolgreich gelöscht.')),
                );
              }
            },
            child: const Text('Endgültig löschen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen & DSGVO', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Optimierungs-Parameter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Fahrtkosten-Abzug je Kilometer'),
                  subtitle: Text('${(_costPerKm / 100.0).toStringAsFixed(2)} € / km (Abwägung Ersparnis vs. Umweg)'),
                ),
                Slider(
                  value: _costPerKm,
                  min: 0.0,
                  max: 100.0,
                  divisions: 20,
                  activeColor: Colors.teal,
                  label: '${(_costPerKm / 100.0).toStringAsFixed(2)} €/km',
                  onChanged: (val) {
                    setState(() => _costPerKm = val);
                    _savePreferences();
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Maximale Stopps je Einkauf'),
                  subtitle: Text('Bis zu $_maxStops Filialen'),
                  trailing: DropdownButton<int>(
                    value: _maxStops,
                    items: [1, 2, 3, 4]
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e Stopps')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _maxStops = val);
                        _savePreferences();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Datenschutz & DSGVO (Art. 17)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.security, color: Colors.teal),
                  title: Text('Standortdaten'),
                  subtitle: Text('GPS-Koordinaten werden nur flüchtig während aktiver Nutzung abgefragt.'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Konto und Daten löschen', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Recht auf Vergessenwerden (Löschung aller Datensätze)'),
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
