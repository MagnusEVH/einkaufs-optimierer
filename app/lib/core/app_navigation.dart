// app/lib/core/app_navigation.dart
//
// Aktiver Tab der Hauptnavigation, damit Screens zu einem anderen Tab springen können.

import 'package:flutter/foundation.dart';

class AppTab {
  AppTab._();
  static const list = 0;
  static const map = 1;
  static const apps = 2;
  static const offers = 3;
  static const profile = 4;

  static final ValueNotifier<int> current = ValueNotifier<int>(list);
}
