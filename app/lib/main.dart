// app/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_navigation.dart';
import 'core/services/analytics_service.dart';
import 'core/services/app_version.dart';
import 'core/services/reload/reload.dart';
import 'core/services/app_links.dart';
import 'core/services/loyalty_service.dart';
import 'core/services/my_stores_service.dart';
import 'core/services/catalog_service.dart';
import 'core/services/observed_price_service.dart';
import 'core/services/offer_import_service.dart';
import 'core/services/preferences_storage.dart';
import 'core/services/supabase_service.dart';
import 'features/account/account_screen.dart';
import 'features/my_apps/balance_scan_flow.dart';
import 'features/my_apps/my_apps_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/shopping_list/shopping_list_screen.dart';
import 'features/stores_map/stores_screen.dart';
import 'features/wallet/import_offers_screen.dart';
import 'features/wallet/wallet_screen.dart';
import './core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Alles Unabhängige parallel laden, damit der Start schneller geht
  await Future.wait([
    SupabaseService.initialize(), // ohne Server im Build: alles lokal
    CatalogService.loadCatalog(),
    ObservedPriceService.load(), // echte Bonpreise
    OfferImportService.loadMappings(), // gemerkte Zuordnungen
    MyStoresService.load(),
    LoyaltyService.load(),
  ]);

  // Angebote vom Übernehmen-Knopf (#import=…), nach dem Katalog für die Zuordnung
  OfferImportService.pending = OfferImportService.fromUri(Uri.base);

  // "Aktiv heute" fürs Cockpit (nur Datum), wenn angemeldet
  SupabaseService.touchLastSeen();

  // Neuere Version auf dem Server? (Hinweis oben in der App)
  AppVersion.watch();

  // Check onboarding status
  final hasCompletedOnboarding = await PreferencesStorage.isOnboardingCompleted();

  // Start app analytics session
  AnalyticsService.startSession(
    entryScreen: hasCompletedOnboarding ? 'shopping_list' : 'onboarding',
  );

  runApp(ProviderScope(
    child: EinkaufsOptimiererApp(showOnboarding: !hasCompletedOnboarding),
  ));
}

class EinkaufsOptimiererApp extends StatelessWidget {
  final bool showOnboarding;

  const EinkaufsOptimiererApp({
    super.key,
    this.showOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Einkaufs-Optimierer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: showOnboarding ? const OnboardingScreen() : const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int get _currentIndex => AppTab.current.value;

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  late final AppLifecycleListener _lifecycle;

  /// Zurück aus einer Händler-App: Guthaben-Scan anbieten (Screenshot schon gemacht?).
  void _onResume() {
    final last = AppLinks.lastOpened;
    if (last == null || DateTime.now().difference(last.at) > const Duration(minutes: 15)) return;
    AppLinks.lastOpened = null;
    final program = LoyaltyService.byId(last.programId);
    if (program == null || program.balanceKind == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 10),
      content: Text('Zurück von ${program.appName}. Screenshot vom Stand gemacht?'),
      action: SnackBarAction(label: 'Scannen', onPressed: () => scanBalanceFlow(context, program)),
    ));
  }

  /// Link "Passwort zurücksetzen" aus der Mail: neues Passwort abfragen.
  void _onRecovery() {
    if (!SupabaseService.recoveryPending.value || !mounted) return;
    SupabaseService.recoveryPending.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Token aus der Adresse entfernen, damit Neuladen nicht erneut fragt
      SystemNavigator.routeInformationUpdated(uri: Uri(path: '/'), replace: true);
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewPasswordScreen()));
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    SupabaseService.recoveryPending.removeListener(_onRecovery);
    AppTab.current.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AppTab.current.addListener(_onTabChanged);
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    SupabaseService.recoveryPending.addListener(_onRecovery);
    _onRecovery();
    final batch = OfferImportService.pending;
    if (batch != null) {
      OfferImportService.pending = null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Import-Daten aus der Adresse entfernen, damit Neuladen nicht erneut fragt
        SystemNavigator.routeInformationUpdated(uri: Uri(path: '/'), replace: true);
        final imported = await Navigator.of(context).push<int>(
          MaterialPageRoute(builder: (_) => ImportOffersScreen(batch: batch)),
        );
        if (imported != null && imported > 0 && mounted) AppTab.current.value = batch.isReceipt ? AppTab.apps : AppTab.offers;
      });
    }
  }

  final List<Widget> _screens = const [
    ShoppingListScreen(),
    StoresScreen(),
    MyAppsScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  /// Tabs werden erst beim ersten Öffnen gebaut (Karte mit Kacheln und
  /// Standortabfrage nicht schon beim App-Start), danach bleiben sie erhalten.
  final Set<int> _visited = {};

  @override
  Widget build(BuildContext context) {
    _visited.add(_currentIndex);
    return Scaffold(
      body: Column(children: [
        const UpdateBanner(),
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              for (var i = 0; i < _screens.length; i++)
                _visited.contains(i) ? _screens[i] : const SizedBox.shrink(),
            ],
          ),
        ),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          AppTab.current.value = idx;
          const tabNames = ['Einkaufsliste', 'Karte', 'Meine Apps', 'Angebote', 'Profil'];
          if (idx < tabNames.length) {
            AnalyticsService.trackScreenView(tabNames[idx]);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.format_list_bulleted_outlined),
            selectedIcon: Icon(Icons.format_list_bulleted, color: AppColors.primary),
            label: 'Liste',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppColors.primary),
            label: 'Karte',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps, color: AppColors.primary),
            label: 'Meine Apps',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer, color: AppColors.primary),
            label: 'Angebote',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Oben in der App, sobald ein neuerer Build bereitliegt.
class UpdateBanner extends StatelessWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: AppVersion.updateAvailable,
        builder: (context, available, _) => !available
            ? const SizedBox.shrink()
            : const Material(
                key: Key('update_banner'),
                color: AppColors.primary,
                child: SafeArea(
                  bottom: false,
                  child: InkWell(
                    onTap: reloadPage,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: AppSpace.m),
                      child: Row(children: [
                        Expanded(
                          child: Text('Neue Version da', style: TextStyle(color: Colors.white, fontSize: 15)),
                        ),
                        Text('Neu laden', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        SizedBox(width: AppSpace.xs),
                        Icon(Icons.refresh, color: Colors.white, size: 20),
                      ]),
                    ),
                  ),
                ),
              ),
      );
}
