// app/lib/core/services/preferences_storage.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferencesStorage {
  static const _storage = FlutterSecureStorage();
  static final Map<String, String> _memoryCache = {};

  static const _keyOnboardingDone = 'has_completed_onboarding_v1';
  static const _keyAdminUnlocked = 'is_admin_mode_unlocked';
  static const _keyShoppingList = 'shopping_list_v1';
  static const _keyUserPreferences = 'user_preferences_v1';

  /// Check whether the first-run onboarding wizard has been completed
  static Future<bool> isOnboardingCompleted() async {
    if (_memoryCache.containsKey(_keyOnboardingDone)) {
      return _memoryCache[_keyOnboardingDone] == 'true';
    }
    try {
      final value = await _storage.read(key: _keyOnboardingDone);
      _memoryCache[_keyOnboardingDone] = value ?? 'false';
      return value == 'true';
    } catch (e) {
      debugPrint('[PreferencesStorage] Error reading onboarding flag: $e');
      return _memoryCache[_keyOnboardingDone] == 'true';
    }
  }

  /// Mark onboarding wizard as completed
  static Future<void> setOnboardingCompleted(bool completed) async {
    final strVal = completed ? 'true' : 'false';
    _memoryCache[_keyOnboardingDone] = strVal;
    try {
      await _storage.write(key: _keyOnboardingDone, value: strVal);
    } catch (e) {
      debugPrint('[PreferencesStorage] Error writing onboarding flag: $e');
    }
  }

  /// Check whether admin developer dashboard is unlocked
  static Future<bool> isAdminUnlocked() async {
    if (_memoryCache.containsKey(_keyAdminUnlocked)) {
      return _memoryCache[_keyAdminUnlocked] == 'true';
    }
    try {
      final value = await _storage.read(key: _keyAdminUnlocked);
      return value == 'true';
    } catch (e) {
      return true; // Default accessible in developer builds
    }
  }

  static Future<void> setAdminUnlocked(bool unlocked) async {
    final strVal = unlocked ? 'true' : 'false';
    _memoryCache[_keyAdminUnlocked] = strVal;
    try {
      await _storage.write(key: _keyAdminUnlocked, value: strVal);
    } catch (e) {
      debugPrint('[PreferencesStorage] Error writing admin flag: $e');
    }
  }

  // --- Lokale Daten (Demo-Modus, V16) ---

  static Future<String?> _read(String key) async {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    try {
      final value = await _storage.read(key: key);
      if (value != null) _memoryCache[key] = value;
      return value;
    } catch (e) {
      debugPrint('[PreferencesStorage] Error reading $key: $e');
      return null;
    }
  }

  static Future<void> _write(String key, String value) async {
    _memoryCache[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('[PreferencesStorage] Error writing $key: $e');
    }
  }

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

  /// Nur für Tests: Zwischenspeicher leeren.
  @visibleForTesting
  static void clearMemoryCache() => _memoryCache.clear();
}

