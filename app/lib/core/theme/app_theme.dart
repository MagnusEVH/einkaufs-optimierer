// app/lib/core/theme/app_theme.dart
//
// Einheitliches Design: alle Farben, Abstände, Radien und Schriftgrößen der App.
// Neue Screens nutzen nur diese Werte, keine eigenen Farbcodes.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Akzent: Grün der Marke, dunkel genug für weiße Schrift (5,5 zu 1).
  // Selten einsetzen: Hauptaktion, Auswahl, die eine Zahl, die zählt.
  static const primary = Color(0xFF047857);
  static const primaryDark = Color(0xFF065F46);
  static const primarySoft = Color(0xFFDCEFE6);
  static const primaryFaint = Color(0xFFEFF6F1);

  // Neutral, leicht warm (Welt: Kassenbon und Einkaufszettel).
  // Drei Textrollen: ink (primär), inkMuted (sekundär), inkSubtle (leise).
  static const ink = Color(0xFF1F1B16);
  static const inkMuted = Color(0xFF5E554A);
  static const inkSubtle = Color(0xFF7B7266);
  static const line = Color(0x171F1B16); // Haarlinie: ink mit 9 %
  static const lineStrong = Color(0x261F1B16);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF2EFE9);
  static const background = Color(0xFFF8F6F2);

  // Status, gedämpft
  static const warning = Color(0xFF9A5B13);
  static const warningSoft = Color(0xFFFBF3E6);
  static const warningLine = Color(0xFFEBD3B0);
  static const danger = Color(0xFFC2352B);
  static const dangerSoft = Color(0xFFFBEDEB);
  static const info = Color(0xFF2F5D8A);
  static const infoSoft = Color(0xFFEEF2F6);
}

class AppSpace {
  AppSpace._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xxl = 20;
  static const double xl = 24;
  static const double xxxl = 32;
}

class AppRadius {
  AppRadius._();
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static final BorderRadius small = BorderRadius.circular(s);
  static final BorderRadius medium = BorderRadius.circular(m);
  static final BorderRadius large = BorderRadius.circular(l);
}

/// Schrift: Größe und Farbe machen die Hierarchie, Gewichte 400 bis 600.
/// Preise und Zahlen immer mit Tabellenziffern, rechtsbündig (Signatur: wie auf dem Bon).
class AppText {
  AppText._();
  static const tab = [FontFeature.tabularFigures()];
  static const title = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const section = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.inkMuted);
  static const body = TextStyle(fontSize: 15, color: AppColors.ink);
  static const bodyStrong = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink);
  static const small = TextStyle(fontSize: 13, color: AppColors.inkMuted);
  static const tiny = TextStyle(fontSize: 12, color: AppColors.inkSubtle);
  static const price = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink, fontFeatures: tab);
  static const figure = TextStyle(fontSize: 28, height: 1.1, fontWeight: FontWeight.w500, color: AppColors.ink, fontFeatures: tab);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.primaryDark,
    surface: AppColors.surface,
    error: AppColors.danger,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.line,
    dividerTheme: const DividerThemeData(color: AppColors.line, space: 1, thickness: 1),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.inkSubtle),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: Border(bottom: BorderSide(color: AppColors.line)),
      centerTitle: false,
      titleTextStyle: AppText.title,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
        side: const BorderSide(color: AppColors.line),
      ),
      color: AppColors.surface,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xxl, vertical: AppSpace.m),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(48, 44),
        side: const BorderSide(color: AppColors.lineStrong),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: AppSpace.m),
      border: OutlineInputBorder(borderRadius: AppRadius.medium, borderSide: BorderSide.none),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceAlt,
      selectedColor: AppColors.primarySoft,
      side: BorderSide.none,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : null),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : null),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary, linearTrackColor: AppColors.line),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primarySoft,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.inkSubtle,
          )),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.inkSubtle,
          )),
    ),
  );
}

/// Einheitliches Abzeichen für nicht echte Funktionen.
class DemoBadge extends StatelessWidget {
  final String label;
  const DemoBadge({super.key, this.label = 'Demo'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.warning)),
    );
  }
}

/// Abschnittsüberschrift in Listen.
class SectionHeader extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionHeader(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.xl, AppSpace.l, AppSpace.s),
      child: Row(
        children: [
          Expanded(child: Text(text, style: AppText.section)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

String euro(int cents) => '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';
