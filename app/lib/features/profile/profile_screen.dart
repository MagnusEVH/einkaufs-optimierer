// app/lib/features/profile/profile_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/models/user_preferences.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/supabase_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../core/app_navigation.dart';
import '../../core/services/app_links.dart';
import '../stores_map/my_stores_screen.dart';
import '../../core/theme/app_theme.dart';

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
          'In der Demo-Version werden keine Daten auf einem Server gespeichert. Mit einem echten Konto werden hier gemäß Art. 17 DSGVO alle deine Daten gelöscht.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await SupabaseService.deleteUserAccount();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo-Version: Es waren keine Daten auf einem Server gespeichert.')),
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
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───────────────────────────────────────────────
          // Quick Actions Section
          // ───────────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.flash_on_rounded, size: 20, color: AppColors.inkMuted),
              SizedBox(width: 8),
              Text(
                'Schnellzugriff',
                style: AppText.bodyStrong,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Bon einlesen',
                  color: AppColors.inkMuted,
                  onTap: AppLinks.openReceiptScan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.storefront_rounded,
                  label: 'Meine Märkte',
                  color: AppColors.inkMuted,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyStoresScreen())),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Meine Apps',
                  color: AppColors.inkMuted,
                  onTap: () => AppTab.current.value = AppTab.apps,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ───────────────────────────────────────────────
          // 1. Category Store Prioritization
          // ───────────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.store_mall_directory, size: 20, color: AppColors.inkMuted),
              SizedBox(width: 8),
              Text(
                'Kategorie-Lieblingsläden',
                style: AppText.bodyStrong,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Lege fest, wo du bestimmte Lebensmittel bevorzugt kaufst.',
            style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.medium,
              side: const BorderSide(color: AppColors.line),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildCategoryDropdown(
                    label: 'Obst & Früchte',
                    categoryKey: 'obst',
                    currentChain: _categoryStorePreferences['obst'] ?? 'netto',
                  ),
                  const Divider(height: 12),
                  _buildCategoryDropdown(
                    label: 'Gemüse & Salat',
                    categoryKey: 'gemuese',
                    currentChain: _categoryStorePreferences['gemuese'] ?? 'lidl',
                  ),
                  const Divider(height: 12),
                  _buildCategoryDropdown(
                    label: 'Fleisch & Fisch',
                    categoryKey: 'fleisch',
                    currentChain: _categoryStorePreferences['fleisch'] ?? 'rewe',
                  ),
                  const Divider(height: 12),
                  _buildCategoryDropdown(
                    label: 'Molkerei & Käse',
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
          const Row(
            children: [
              Icon(Icons.branding_watermark, size: 20, color: AppColors.inkMuted),
              SizedBox(width: 8),
              Text(
                'Marken & Eigenmarken-Regel',
                style: AppText.bodyStrong,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.medium,
              side: const BorderSide(color: AppColors.line),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Eigenmarken bevorzugen (Günstigster Preis)'),
                  subtitle: const Text('Wählt ja!, Milbona, Milsani & Co.'),
                  value: 'prefer_private_label',
                  groupValue: _brandPreference,
                  activeColor: AppColors.primary,
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
                  activeColor: AppColors.primary,
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
                  activeColor: AppColors.primary,
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
                  activeColor: AppColors.primary,
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
          const Row(
            children: [
              Icon(Icons.alt_route, size: 20, color: AppColors.inkMuted),
              SizedBox(width: 8),
              Text(
                'Routen-Abwägung & Stopps',
                style: AppText.bodyStrong,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.medium,
              side: const BorderSide(color: AppColors.line),
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
                  activeColor: AppColors.primary,
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
          const Row(
            children: [
              Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.inkMuted),
              SizedBox(width: 8),
              Text(
                'Benachrichtigungen (Intelligent)',
                style: AppText.bodyStrong,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: _pushEnabled,
                  onChanged: (val) {
                    setState(() => _pushEnabled = val);
                    NotificationService.setNotificationsEnabled(val);
                  },
                  title: const Text('Erinnerungen & Spartipps', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  subtitle: const Text('Dezente Hinweise zu Wochenangeboten & ablaufenden Coupons (max. 1 / Tag).', style: TextStyle(fontSize: 12)),
                  activeColor: AppColors.primary,
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  value: _quietHoursEnabled,
                  onChanged: (val) {
                    setState(() => _quietHoursEnabled = val);
                    NotificationService.setQuietHoursEnabled(val);
                  },
                  title: const Text('Ruhezeiten beachten (21:00 – 08:00)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  subtitle: const Text('Keinerlei Töne oder Nachrichten in den Abend- und Nachtstunden.', style: TextStyle(fontSize: 12)),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ───────────────────────────────────────────────
          // 5. DSGVO & Privacy
          // ───────────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.security, size: 20, color: AppColors.inkMuted),
              SizedBox(width: 8),
              Text(
                'Datenschutz & DSGVO (Art. 17)',
                style: AppText.bodyStrong,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.location_on_outlined, color: AppColors.inkMuted),
                  title: Text('Standortdaten'),
                  subtitle: Text('GPS-Koordinaten werden nur flüchtig während aktiver Nutzung abgefragt.'),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.lock_outline, color: AppColors.inkMuted),
                  title: Text('App-Verknüpfungen'),
                  subtitle: Text('Demo: Verknüpfungen sind simuliert, es werden keine Zugangsdaten gespeichert.'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.danger),
                  title: const Text('Konto und Daten löschen', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Recht auf Vergessenwerden (Löschung aller Datensätze inkl. App-Verknüpfungen)'),
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Developer & Administration Area (nur im Debug-Build)
          if (kDebugMode)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.medium,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.small,
                ),
                child: const Icon(Icons.analytics_rounded, color: AppColors.primary),
              ),
              title: const Text(
                'Entwickler-Cockpit & Analytics',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: const Text(
                'Nutzungsstatistiken, DAU/MAU, Live-Events & Fehlerprotokoll',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.inkSubtle),
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
          const Center(
            child: Text(
              'Einkaufs-Optimierer v0.3.0 · Phase 3',
              style: TextStyle(fontSize: 12, color: AppColors.inkSubtle),
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
      borderRadius: AppRadius.medium,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
