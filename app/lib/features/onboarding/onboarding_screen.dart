// app/lib/features/onboarding/onboarding_screen.dart
//
// Ein einziger Willkommensbildschirm statt Seiten zum Durchwischen:
// die drei Schritte der App auf einen Blick, ein Knopf, fertig.

import 'package:flutter/material.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/preferences_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _start(BuildContext context) async {
    AnalyticsService.trackOnboardingStep(0, skipped: false);
    await PreferencesStorage.setOnboardingCompleted(true);
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigationShell(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.xl, AppSpace.xl, AppSpace.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Text(
                    'Einkaufs-Optimierer',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpace.m),
                  const Text(
                    'Deine Einkaufsliste, aufgeteilt auf die günstigsten Märkte in deiner Nähe',
                    style: TextStyle(fontSize: 28, height: 1.15, fontWeight: FontWeight.w500, color: AppColors.ink),
                  ),
                  const SizedBox(height: AppSpace.m),
                  const Text(
                    'Die App vergleicht deine Märkte und sagt dir, wo du was kaufst.',
                    style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpace.xxxl),
                  const _Step(number: 1, title: 'Liste schreiben', text: 'Tippe, was du brauchst'),
                  const _Step(number: 2, title: 'Einkauf planen', text: 'Günstigste Route über deine Märkte'),
                  const _Step(number: 3, title: 'Einkaufen und Bon einlesen', text: 'Im Laden abhaken, danach lernt die App echte Preise'),
                  const Spacer(flex: 2),
                  const Text(
                    'Preise sind teils Beispieldaten, bis du Angebote übernimmst oder Bons scannst.',
                    style: AppText.tiny,
                  ),
                  const SizedBox(height: AppSpace.m),
                  FilledButton(onPressed: () => _start(context), child: const Text('Liste anlegen')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ein Schritt als Zeile mit Nummer, wie auf einem Einkaufszettel.
class _Step extends StatelessWidget {
  final int number;
  final String title;
  final String text;
  const _Step({required this.number, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.m),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 24,
          child: Text('$number', style: AppText.bodyStrong.copyWith(color: AppColors.inkSubtle, fontFeatures: AppText.tab)),
        ),
        const SizedBox(width: AppSpace.s),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.bodyStrong),
            Text(text, style: AppText.small),
          ]),
        ),
      ]),
    );
  }
}
