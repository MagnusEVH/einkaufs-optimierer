// app/lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/store.dart';
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
  String _brandPreference = 'prefer_private_label';
  bool _preferBio = false;
  
  // Category-specific store prioritization (Phase 2)
  Map<String, String> _categoryStorePreferences = {
    'obst': 'netto',
    'gemuese': 'lidl',
    'fleisch': 'rewe',
    'molkerei': 'aldi_sued',
  };

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
      _brandPreference = prefs.brandPreference;
      _preferBio = prefs.bioPreference == 'prefer_bio';
      _categoryStorePreferences = Map<String, String>.from(prefs.categoryStorePreferences);
    });
  }

  Future<void> _savePreferences() async {
    final updated = UserPreferences(
      costPerKmCents: _costPerKm,
      maxStops: _maxStops,
      brandPreference: _brandPreference,
      bioPreference: _preferBio ? 'prefer_bio' : 'neutral',
      categoryStorePreferences: _categoryStorePreferences,
    );
    await SupabaseService.savePreferences(updated);
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konto und Daten löschen?'),
        content: const Text(
          'Gemäß Art. 17 DSGVO werden alle deine Einkaufslisten, Präferenzen, hochgeladenen Bons und persönlichen Daten unwiderruflich aus der Datenbank gelöscht.',
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Präferenzen & DSGVO', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Category Store Prioritization (Phase 2 Highlight)
          Row(
            children: [
              const Icon(Icons.store_mall_directory, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'Kategorie-Lieblingsläden (Priorisierung)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lege fest, wo du rohe Lebensmittel bevorzugt kaufst (z. B. Obst von Netto, Gemüse von Lidl).',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  _buildCategoryDropdown(
                    label: '🍎 Obst & Früchte',
                    categoryKey: 'obst',
                    currentChain: _categoryStorePreferences['obst'] ?? 'netto',
                  ),
                  const Divider(height: 12),
                  _buildCategoryDropdown(
                    label: '🥦 Gemüse & Salat',
                    categoryKey: 'gemuese',
                    currentChain: _categoryStorePreferences['gemuese'] ?? 'lidl',
                  ),
                  const Divider(height: 12),
                  _buildCategoryDropdown(
                    label: '🥩 Fleisch & Fisch',
                    categoryKey: 'fleisch',
                    currentChain: _categoryStorePreferences['fleisch'] ?? 'rewe',
                  ),
                  const Divider(height: 12),
                  _buildCategoryDropdown(
                    label: '🥛 Molkerei & Käse',
                    categoryKey: 'molkerei',
                    currentChain: _categoryStorePreferences['molkerei'] ?? 'aldi_sued',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Brand & Private Label Preference
          Row(
            children: [
              const Icon(Icons.branding_watermark, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'Marken & Eigenmarken-Regel',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Eigenmarken bevorzugen (Günstigster Preis)'),
                  subtitle: const Text('Wählt ja!, Milbona, Milsani & Co.'),
                  value: 'prefer_private_label',
                  groupValue: _brandPreference,
                  activeColor: Colors.teal,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _brandPreference = val);
                      _savePreferences();
                    }
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('Eigenmarken ablehnen (Nur Markenartikel)'),
                  subtitle: const Text('Wählt bevorzugt Hersteller-Marken (Barilla, Kerrygold, Ferrero)'),
                  value: 'reject_private_label',
                  groupValue: _brandPreference,
                  activeColor: Colors.teal,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _brandPreference = val);
                      _savePreferences();
                    }
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('Neutral / Rein nach Preis'),
                  subtitle: const Text('Das absolut billigste Angebot gewinnt'),
                  value: 'neutral',
                  groupValue: _brandPreference,
                  activeColor: Colors.teal,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _brandPreference = val);
                      _savePreferences();
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Bio-Produkte bevorzugen'),
                  subtitle: const Text('Wählt nach Möglichkeit Bio-Artikel aus'),
                  value: _preferBio,
                  activeColor: Colors.teal,
                  onChanged: (val) {
                    setState(() => _preferBio = val);
                    _savePreferences();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Routing & Cost Parameters
          Row(
            children: [
              const Icon(Icons.alt_route, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'Routen-Abwägung & Stopps',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Fahrtkosten-Abzug je Kilometer'),
                  subtitle: Text('${(_costPerKm / 100.0).toStringAsFixed(2)} € / km Umwegstrafe'),
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
                const Divider(height: 1),
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

          // 4. DSGVO
          Row(
            children: [
              const Icon(Icons.security, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'Datenschutz & DSGVO (Art. 17)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.location_on_outlined, color: Colors.teal),
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

  Widget _buildCategoryDropdown({
    required String label,
    required String categoryKey,
    required String currentChain,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        DropdownButton<String>(
          value: currentChain,
          underline: const SizedBox.shrink(),
          items: const [
            DropdownMenuItem(value: 'netto', child: Text('Netto')),
            DropdownMenuItem(value: 'lidl', child: Text('Lidl')),
            DropdownMenuItem(value: 'aldi_sued', child: Text('ALDI SÜD')),
            DropdownMenuItem(value: 'aldi_nord', child: Text('ALDI Nord')),
            DropdownMenuItem(value: 'rewe', child: Text('REWE')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _categoryStorePreferences[categoryKey] = val;
              });
              _savePreferences();
            }
          },
        ),
      ],
    );
  }
}
