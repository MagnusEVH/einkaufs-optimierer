// app/lib/core/services/preferences_storage.dart
//
// Lokale App-Daten (Liste, Einstellungen, übernommene Angebote, Flags).
// Liegen in SharedPreferences (im Browser: localStorage), unverschlüsselt.
// Hier liegen keine Geheimnisse, daher braucht es keine Verschlüsselung.
//
// Früher lag alles in flutter_secure_storage. Dessen Web-Variante erzeugt den
// Schlüssel ohne Sperre: Laufen beim ersten Start mehrere Schreibvorgänge
// gleichzeitig, gewinnt ein Schlüssel und die übrigen Werte sind danach nicht
// mehr lesbar. Folge: Liste weg nach dem Neuladen. Alte Werte werden beim
// ersten Lesen einmalig übernommen, soweit sie noch lesbar sind.

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  static const _legacy = FlutterSecureStorage();
  static Future<SharedPreferences>? _prefs;

  static Future<SharedPreferences> get _store => _prefs ??= SharedPreferences.getInstance();

  static const _keyOnboardingDone = 'has_completed_onboarding_v1';
  static const _keyAdminUnlocked = 'is_admin_mode_unlocked';
  static const _keyShoppingList = 'shopping_list_v1';
  static const _keyUserPreferences = 'user_preferences_v1';
  static const _keyImportedOffers = 'imported_offers_v1';

  static Future<String?> _read(String key) async {
    try {
      final prefs = await _store;
      final value = prefs.getString(key);
      if (value != null) return value;
      // Einmalige Übernahme aus dem alten Speicher
      final old = await _readLegacy(key);
      if (old != null) await prefs.setString(key, old);
      return old;
    } catch (e) {
      debugPrint('[PreferencesStorage] Error reading $key: $e');
      return null;
    }
  }

  static Future<String?> _readLegacy(String key) async {
    try {
      return await _legacy.read(key: key);
    } catch (_) {
      return null; // nicht vorhanden, Plugin fehlt oder Wert unlesbar
    }
  }

  static Future<void> _write(String key, String value) async {
    try {
      await (await _store).setString(key, value);
    } catch (e) {
      debugPrint('[PreferencesStorage] Error writing $key: $e');
    }
  }

  /// Check whether the first-run onboarding wizard has been completed
  static Future<bool> isOnboardingCompleted() async => await _read(_keyOnboardingDone) == 'true';

  /// Mark onboarding wizard as completed
  static Future<void> setOnboardingCompleted(bool completed) =>
      _write(_keyOnboardingDone, completed ? 'true' : 'false');

  /// Check whether admin developer dashboard is unlocked
  static Future<bool> isAdminUnlocked() async => await _read(_keyAdminUnlocked) == 'true';

  static Future<void> setAdminUnlocked(bool unlocked) =>
      _write(_keyAdminUnlocked, unlocked ? 'true' : 'false');

  /// Gespeicherte Einkaufsliste als JSON-Liste, oder null, wenn noch nie gespeichert.
  static Future<List<Map<String, dynamic>>?> loadShoppingList() async {
    final raw = await _read(_keyShoppingList);
    if (raw == null) return null;
    try {
      return (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[PreferencesStorage] Invalid shopping list: $e');
      return null;
    }
  }

  static Future<void> saveShoppingList(List<Map<String, dynamic>> items) =>
      _write(_keyShoppingList, json.encode(items));

  static Future<Map<String, dynamic>?> loadUserPreferences() async {
    final raw = await _read(_keyUserPreferences);
    if (raw == null) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[PreferencesStorage] Invalid preferences: $e');
      return null;
    }
  }

  static Future<void> saveUserPreferences(Map<String, dynamic> prefs) =>
      _write(_keyUserPreferences, json.encode(prefs));

  /// Vom Übernehmen-Knopf übernommene Angebote (JSON-Liste).
  static Future<List<Map<String, dynamic>>> loadImportedOffers() async {
    final raw = await _read(_keyImportedOffers);
    if (raw == null) return [];
    try {
      return (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[PreferencesStorage] Invalid imported offers: $e');
      return [];
    }
  }

  static Future<void> saveImportedOffers(List<Map<String, dynamic>> offers) =>
      _write(_keyImportedOffers, json.encode(offers));

  /// Beliebiger JSON-Wert unter [key] (Bonpreise, Zuordnungen, Import-Protokoll).
  static Future<dynamic> loadJson(String key) async {
    final raw = await _read(key);
    if (raw == null) return null;
    try {
      return json.decode(raw);
    } catch (e) {
      debugPrint("[PreferencesStorage] Invalid JSON in $key: $e");
      return null;
    }
  }

  static Future<void> saveJson(String key, Object value) => _write(key, json.encode(value));

  /// Nur für Tests: simuliert ein Neuladen der Seite (Speicher bleibt erhalten).
  /// Leeren Speicher vorher mit `SharedPreferences.setMockInitialValues({})` setzen.
  @visibleForTesting
  static void simulateReload() => _prefs = null;
}
