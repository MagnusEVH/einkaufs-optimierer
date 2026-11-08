// app/lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/user_preferences.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/supabase_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../price_reports/price_report_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _costPerKm = 30.0;
  int _maxStops = 2;
  String _brandPreference = 'prefer_private_label';
  bool _preferBio = false;
  bool _pushEnabled = true;
  bool _quietHoursEnabled = true;

  // Category-specific store prioritization
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
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───────────────────────────────────────────────
          // Quick Actions Section
          // ───────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: Color(0xFF059669)),
              const SizedBox(width: 8),
              Text(
                'Schnellzugriff',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Bon melden',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PriceReportScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.history_rounded,
                  label: 'Einkaufshistorie',
                  color: Colors.indigo,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Einkaufshistorie wird in einem kommenden Update freigeschaltet.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.bar_chart_rounded,
                  label: 'Sparstatistik',
                  color: Colors.amber.shade800,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sparstatistik wird in einem kommenden Update freigeschaltet.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ───────────────────────────────────────────────
          // 1. Category Store Prioritization
          // ───────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.store_mall_directory, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'Kategorie-Lieblingsläden',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lege fest, wo du bestimmte Lebensmittel bevorzugt kaufst.',
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

          // ───────────────────────────────────────────────
          // 2. Brand & Private Label Preference
          // ───────────────────────────────────────────────
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

          // ───────────────────────────────────────────────
          // 3. Routing & Cost Parameters
          // ───────────────────────────────────────────────
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

          // ───────────────────────────────────────────────
          // 4. Intelligente Benachrichtigungen (Duolingo-Stil)
          // ───────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'Benachrichtigungen (Intelligent)',
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
                SwitchListTile.adaptive(
                  value: _pushEnabled,
                  onChanged: (val) {
                    setState(() => _pushEnabled = val);
                    NotificationService.setNotificationsEnabled(val);
                  },
                  title: const Text('Erinnerungen & Spartipps', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                  subtitle: const Text('Dezente Hinweise zu Wochenangeboten & ablaufenden Coupons (max. 1 / Tag).', style: TextStyle(fontSize: 12)),
                  activeColor: const Color(0xFF007AFF),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  value: _quietHoursEnabled,
                  onChanged: (val) {
                    setState(() => _quietHoursEnabled = val);
                    NotificationService.setQuietHoursEnabled(val);
                  },
                  title: const Text('Ruhezeiten beachten (21:00 – 08:00)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                  subtitle: const Text('Keinerlei Töne oder Nachrichten in den Abend- und Nachtstunden.', style: TextStyle(fontSize: 12)),
                  activeColor: const Color(0xFF007AFF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ───────────────────────────────────────────────
          // 5. DSGVO & Privacy
          // ───────────────────────────────────────────────
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
                const ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.teal),
                  title: Text('App-Verknüpfungen'),
                  subtitle: Text('Zugangsdaten werden verschlüsselt nur lokal auf deinem Gerät gespeichert.'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Konto und Daten löschen', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Recht auf Vergessenwerden (Löschung aller Datensätze inkl. App-Verknüpfungen)'),
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Developer & Administration Area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF007AFF).withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded, color: Color(0xFF007AFF)),
              ),
              title: const Text(
                'Entwickler-Cockpit & Analytics',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: const Text(
                'Nutzungsstatistiken, DAU/MAU, Live-Events & Fehlerprotokoll',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF8E8E93)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // App Version Footer
          Center(
            child: Text(
              'Einkaufs-Optimierer v0.3.0 • Phase 3',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
