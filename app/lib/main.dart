// app/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/analytics_service.dart';
import 'core/services/catalog_service.dart';
import 'core/services/preferences_storage.dart';
import 'core/services/supabase_service.dart';
import 'features/my_apps/my_apps_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/shopping_list/shopping_list_screen.dart';
import 'features/stores_map/stores_screen.dart';
import 'features/wallet/wallet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (with fallback to dev demo mode)
  await SupabaseService.initialize();

  // Preload catalog
  await CatalogService.loadCatalog();

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
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF059669),
          primary: const Color(0xFF059669),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.black.withValues(alpha: 0.07)),
          ),
          color: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 8,
          indicatorColor: const Color(0xFFD1FAE5),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF065F46),
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            );
          }),
        ),
      ),
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
  int _currentIndex = 0;

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
          setState(() => _currentIndex = idx);
          const tabNames = ['Einkaufsliste', 'Karte', 'Meine Apps', 'Angebote', 'Profil'];
          if (idx < tabNames.length) {
            AnalyticsService.trackScreenView(tabNames[idx]);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.format_list_bulleted_outlined),
            selectedIcon: Icon(Icons.format_list_bulleted, color: Color(0xFF059669)),
            label: 'Einkaufsliste',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: Color(0xFF059669)),
            label: 'Karte',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps, color: Color(0xFF059669)),
            label: 'Meine Apps',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer, color: Color(0xFF059669)),
            label: 'Angebote',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person, color: Color(0xFF059669)),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
