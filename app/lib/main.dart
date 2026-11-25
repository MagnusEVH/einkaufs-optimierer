// app/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_navigation.dart';
import 'core/services/analytics_service.dart';
import 'core/services/loyalty_service.dart';
import 'core/services/my_stores_service.dart';
import 'core/services/catalog_service.dart';
import 'core/services/observed_price_service.dart';
import 'core/services/offer_import_service.dart';
import 'core/services/preferences_storage.dart';
import 'core/services/supabase_service.dart';
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

  // Initialize Supabase (with fallback to dev demo mode)
  await SupabaseService.initialize();

  // Preload catalog
  await CatalogService.loadCatalog();

  // Echte Bonpreise und gemerkte Zuordnungen
  await ObservedPriceService.load();
  await OfferImportService.loadMappings();
  await MyStoresService.load();
  await LoyaltyService.load();

  // Angebote vom Übernehmen-Knopf (#import=…), nach dem Katalog für die Zuordnung
  OfferImportService.pending = OfferImportService.fromUri(Uri.base);
  // Guthaben-Scan aus konto.html (#import=…, kind = balance)
  LoyaltyService.pending = LoyaltyService.fromUri(Uri.base);

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

  @override
  void dispose() {
    AppTab.current.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AppTab.current.addListener(_onTabChanged);
    final balance = LoyaltyService.pending;
    if (balance != null) {
      LoyaltyService.pending = null;
      AppTab.current.value = AppTab.apps;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        SystemNavigator.routeInformationUpdated(uri: Uri(path: '/'), replace: true);
        await LoyaltyService.saveBalance(balance);
        if (!mounted) return;
        final p = LoyaltyService.byId(balance.programId)!;
        final value = balance.valueCents != null ? euro(balance.valueCents!) : '${balance.points} Punkte';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name}: Stand $value übernommen')));
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
