// app/lib/features/onboarding/onboarding_screen.dart
// Strict adherence to Apple Human Interface Guidelines:
// - San Francisco hierarchy & spacious white margins
// - Clean subtle glyphs & soft rounded container cards
// - Smooth swipe physics with iOS-style pill pagination

import 'package:flutter/material.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/preferences_storage.dart';
import '../../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      icon: Icons.savings_rounded,
      iconColor: Color(0xFF007AFF), // Apple System Blue
      headline: 'Willkommen beim Einkaufs-Optimierer',
      subtitle: 'Spare bares Geld bei jedem Wocheneinkauf durch intelligenten Filial- und Preisvergleich.',
      bulletPoints: [
        'Echte Live-Preise von Lidl, Aldi, Rewe, Netto & Drogerien',
        'Multi-Store-Optimierung: die günstigste Kombination deiner Produkte',
        'Transparent und werbefrei – keine fiktiven Schein-Rabatte',
      ],
    ),
    OnboardingSlideData(
      icon: Icons.map_rounded,
      iconColor: Color(0xFF34C759), // Apple System Green
      headline: 'Smarte Routen & Filial-Cluster',
      subtitle: 'Kaufe in benachbarten Läden ein, ohne zusätzliche Fahrzeit oder Spritkosten zu verschwenden.',
      bulletPoints: [
        'Cluster-Erkennung: Läden im 200m–500m Umkreis zu Fuß verbinden',
        'PostGIS-Umkreissuche für Mainz-Bingen & Rhein-Hunsrück',
        'Kein nerviges Umherfahren – nur echte Netto-Ersparnis zählt',
      ],
    ),
    OnboardingSlideData(
      icon: Icons.wallet_rounded,
      iconColor: Color(0xFFAF52DE), // Apple System Purple
      headline: 'Deine Apps & Coupons gebündelt',
      subtitle: 'Verbinde Lidl Plus, PAYBACK & Rossmann für automatische Punkte- und Coupon-Aktivierung.',
      bulletPoints: [
        'Coupons werden vollautomatisch beim besten Laden angerechnet',
        'Volle Datensouveränität: Zugangsdaten bleiben verschlüsselt auf deinem iPhone',
        'Jederzeit anpassbare Store- & Bio-Präferenzen',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.trackOnboardingStep(0, skipped: false);
  }

  void _finishOnboarding({bool skipped = false}) async {
    AnalyticsService.trackOnboardingStep(_currentPage, skipped: skipped);
    await PreferencesStorage.setOnboardingCompleted(true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavigationShell(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Apple System Grouped Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => _finishOnboarding(skipped: true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8E8E93), // Apple Label Secondary
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: const Text('Überspringen'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  AnalyticsService.trackOnboardingStep(index, skipped: false);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        // Soft Apple Icon Container
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: slide.iconColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 46,
                            color: slide.iconColor,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Large Title (Apple HIG)
                        Text(
                          slide.headline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: Color(0xFF1C1C1E),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subheadline
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8E8E93),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Apple Grouped Inset List
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: slide.bulletPoints.asMap().entries.map((entry) {
                              final isLast = entry.key == slide.bulletPoints.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            size: 20,
                                            color: slide.iconColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF2C2C2E),
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    const Divider(
                                      height: 1,
                                      indent: 48,
                                      endIndent: 16,
                                      color: Color(0xFFE5E5EA),
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Controls (Pill Indicators & CTA Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  // iOS Pill Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF007AFF) : const Color(0xFFD1D1D6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),

                  // Apple Filled Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finishOnboarding(skipped: false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF), // Apple Accent
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      child: Text(_currentPage == _slides.length - 1 ? 'Jetzt starten' : 'Weiter'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlideData {
  final IconData icon;
  final Color iconColor;
  final String headline;
  final String subtitle;
  final List<String> bulletPoints;

  const OnboardingSlideData({
    required this.icon,
    required this.iconColor,
    required this.headline,
    required this.subtitle,
    required this.bulletPoints,
  });
}
