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
                  const Text('🛒', style: TextStyle(fontSize: 56), textAlign: TextAlign.center),
                  const SizedBox(height: AppSpace.l),
                  const Text(
                    'Günstiger einkaufen,\nohne zu suchen',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, height: 1.2, fontWeight: FontWeight.w800, color: AppColors.ink),
                  ),
                  const SizedBox(height: AppSpace.s),
                  const Text(
                    'Die App vergleicht deine Märkte in der Nähe und sagt dir, wo du was kaufst.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  const _Step(icon: '📝', title: 'Liste schreiben', text: 'Tippe, was du brauchst.'),
                  const _Step(icon: '🗺️', title: 'Einkauf planen', text: 'Günstigste Route über deine Märkte.'),
                  const _Step(icon: '✅', title: 'Einkaufen und Bon scannen', text: 'Im Laden abhaken, danach lernt die App echte Preise.'),
                  const Spacer(flex: 2),
                  const Text(
                    'Preise sind teils Beispieldaten, bis du Angebote übernimmst oder Bons scannst.',
                    textAlign: TextAlign.center,
                    style: AppText.tiny,
                  ),
                  const SizedBox(height: AppSpace.m),
                  FilledButton(onPressed: () => _start(context), child: const Text('Los geht’s')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String icon;
  final String title;
  final String text;
  const _Step({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.primaryFaint, borderRadius: AppRadius.medium),
          child: Text(icon, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: AppSpace.m),
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
