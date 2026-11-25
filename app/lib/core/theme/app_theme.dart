// app/lib/core/theme/app_theme.dart
//
// Einheitliches Design: alle Farben, Abstände, Radien und Schriftgrößen der App.
// Neue Screens nutzen nur diese Werte, keine eigenen Farbcodes.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Marke (Emerald)
  static const primary = Color(0xFF059669);
  static const primaryDark = Color(0xFF065F46);
  static const primarySoft = Color(0xFFD1FAE5);
  static const primaryFaint = Color(0xFFECFDF5);

  // Neutral (Slate)
  static const ink = Color(0xFF0F172A);
  static const inkMuted = Color(0xFF475569);
  static const inkSubtle = Color(0xFF64748B);
  static const line = Color(0xFFE2E8F0);
  static const surface = Colors.white;
  static const surfaceAlt = Color(0xFFF1F5F9);
  static const background = Color(0xFFF8FAFC);

  // Status
  static const warning = Color(0xFFB45309);
  static const warningSoft = Color(0xFFFFF7ED);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEF2F2);
  static const info = Color(0xFF2563EB);
  static const infoSoft = Color(0xFFEFF6FF);
}

class AppSpace {
  AppSpace._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
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

class AppText {
  AppText._();
  static const title = TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink);
  static const section = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.inkMuted, letterSpacing: 0.3);
  static const body = TextStyle(fontSize: 15, color: AppColors.ink);
  static const bodyStrong = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const small = TextStyle(fontSize: 13, color: AppColors.inkSubtle);
  static const tiny = TextStyle(fontSize: 11, color: AppColors.inkSubtle);
  static const price = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink, fontFeatures: [FontFeature.tabularFigures()]);
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
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        minimumSize: const Size(48, 44),
        side: const BorderSide(color: AppColors.line),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
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
      elevation: 3,
      indicatorColor: AppColors.primarySoft,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.inkSubtle,
          )),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
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
      decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: AppRadius.small, border: Border.all(color: const Color(0xFFFED7AA))),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning)),
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
      padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.s),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: AppText.section)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

String euro(int cents) => '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';
