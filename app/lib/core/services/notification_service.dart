// app/lib/core/services/notification_service.dart
// Intelligent Rule-Based Notification Engine (Duolingo-inspired):
// - High-relevance, timing-optimized triggers
// - Strict frequency capping (max 1 message per 24 hours)
// - Respects quiet hours (21:00 to 08:00)
// - Transparent user consent & DSGVO opt-out

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/loyalty_wallet.dart';
import 'analytics_service.dart';
import 'preferences_storage.dart';
import 'supabase_service.dart';

class NotificationService {
  static bool _notificationsEnabled = true;
  static bool _quietHoursEnabled = true;
  static DateTime? _lastNotificationSentAt;

  static bool get notificationsEnabled => _notificationsEnabled;
  static bool get quietHoursEnabled => _quietHoursEnabled;

  static void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  static void setQuietHoursEnabled(bool enabled) {
    _quietHoursEnabled = enabled;
  }

  /// Checks whether notifications are currently suppressed due to quiet hours (21:00 - 08:00)
  static bool isWithinQuietHours() {
    if (!_quietHoursEnabled) return false;
    final now = DateTime.now();
    return now.hour >= 21 || now.hour < 8;
  }

  /// Checks whether 24 hours have passed since the last notification (Anti-Spam frequency cap)
  static bool isRateLimited() {
    if (_lastNotificationSentAt == null) return false;
    final elapsed = DateTime.now().difference(_lastNotificationSentAt!);
    return elapsed.inHours < 24;
  }

  /// Dispatches a high-relevance notification if all user constraints pass
  static Future<bool> sendIntelligentNotification({
    required String triggerType,
    required String title,
    required String body,
    Map<String, dynamic> metadata = const {},
  }) async {
    // 1. Consent check
    if (!_notificationsEnabled) {
      debugPrint('[Push Engine] Skipped ($triggerType): Notifications disabled by user.');
      return false;
    }

    // 2. Quiet hours check (21:00 - 08:00)
    if (isWithinQuietHours()) {
      debugPrint('[Push Engine] Skipped ($triggerType): Suppressed during quiet hours (21:00 - 08:00).');
      return false;
    }

    // 3. Frequency cap (max 1 per 24 hours)
    if (isRateLimited()) {
      debugPrint('[Push Engine] Skipped ($triggerType): Rate limited (max 1 notification per 24h).');
      return false;
    }

    _lastNotificationSentAt = DateTime.now();

    debugPrint('[Push Engine SENT] [$triggerType] $title: $body');

    // 4. Log event in Analytics & Database
    AnalyticsService.trackEvent(
      'push_notification_delivered',
      category: 'engagement',
      properties: {
        'trigger_type': triggerType,
        'title': title,
        ...metadata,
      },
    );

    if (!SupabaseService.isDemoMode && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('push_notifications_log').insert({
          'user_id': SupabaseService.currentUserId,
          'title': title,
          'body': body,
          'trigger_type': triggerType,
          'sent_at': DateTime.now().toIso8601String(),
          'action_taken': false,
        });
      } catch (e) {
        debugPrint('[Push Engine] Error writing push log: $e');
      }
    }

    return true;
  }

  // ==========================================================================
  // Contextual Trigger Evaluators (Duolingo Style)
  // ==========================================================================

  /// Sunday list preparation prompt
  static Future<void> evaluateSundayReminder() async {
    final now = DateTime.now();
    if (now.weekday == DateTime.sunday && now.hour >= 14 && now.hour <= 19) {
      await sendIntelligentNotification(
        triggerType: 'sunday_list_reminder',
        title: 'Wocheneinkauf planen? 📝',
        body: 'Die neuen Prospekte von Lidl, Rewe & Aldi für Bingen sind da. Spare bis zu 25%!',
      );
    }
  }

  /// Warning before an activated coupon expires
  static Future<void> evaluateExpiringCoupons(List<UserCoupon> coupons) async {
    final now = DateTime.now();
    for (final c in coupons) {
      if (c.isActive && c.validUntil != null) {
        final hoursLeft = c.validUntil!.difference(now).inHours;
        if (hoursLeft > 0 && hoursLeft <= 24) {
          await sendIntelligentNotification(
            triggerType: 'expiring_coupon',
            title: 'Dein ${c.chain.displayName}-Coupon läuft bald ab! ⏳',
            body: '${c.title} ist nur noch $hoursLeft Stunden gültig.',
            metadata: {'chain': c.chain.name, 'coupon_id': c.id},
          );
          break; // Avoid spamming multiple coupons at once
        }
      }
    }
  }

  /// Gentle reminder if a list was created but route wasn't run yet
  static Future<void> evaluateUnfinishedListReminder(int itemCount) async {
    if (itemCount >= 3) {
      await sendIntelligentNotification(
        triggerType: 'unfinished_list',
        title: 'Deine Einkaufsliste ist bereit 🛒',
        body: '$itemCount Artikel warten darauf, auf der günstigsten Route eingekauft zu werden.',
        metadata: {'items_count': itemCount},
      );
    }
  }
}

