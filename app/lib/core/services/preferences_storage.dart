// app/lib/core/services/preferences_storage.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferencesStorage {
  static const _storage = FlutterSecureStorage();
  static final Map<String, String> _memoryCache = {};

  static const _keyOnboardingDone = 'has_completed_onboarding_v1';
  static const _keyAdminUnlocked = 'is_admin_mode_unlocked';

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
}

