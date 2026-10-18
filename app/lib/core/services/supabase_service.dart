// app/lib/core/services/supabase_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/list_item.dart';
import '../models/user_preferences.dart';
import 'catalog_service.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isDemoMode = true; // Default to dev/demo mode until configured

  static bool get isDemoMode => _isDemoMode;
  static SupabaseClient? get client => _client;

  static Future<void> initialize({
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) async {
    if (supabaseUrl != null &&
        supabaseAnonKey != null &&
        supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
        _client = Supabase.instance.client;
        _isDemoMode = false;
        debugPrint('Supabase initialized successfully.');
      } catch (e) {
        debugPrint('Supabase init error: $e. Running in Developer Demo Mode.');
        _isDemoMode = true;
      }
    } else {
      _isDemoMode = true;
      debugPrint('No Supabase credentials provided. Running in Developer Demo Mode.');
    }
  }

  /// Current user ID (or demo developer user ID)
  static String get currentUserId {
    if (!_isDemoMode && _client?.auth.currentUser != null) {
      return _client!.auth.currentUser!.id;
    }
    return '00000000-0000-0000-0000-000000000001'; // Default Dev User
  }

  /// Sign In with Email & Password
  static Future<void> signInWithEmail(String email, String password) async {
    if (_isDemoMode || _client == null) {
      debugPrint('Demo Sign In for: $email');
      return;
    }
    await _client!.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign Up with Email & Password
  static Future<void> signUpWithEmail(String email, String password) async {
    if (_isDemoMode || _client == null) {
      debugPrint('Demo Sign Up for: $email');
      return;
    }
    await _client!.auth.signUp(email: email, password: password);
  }

  /// Sign Out
  static Future<void> signOut() async {
    if (!_isDemoMode && _client != null) {
      await _client!.auth.signOut();
    }
  }

  /// DSGVO: Delete user account and all personal shopping data permanently
  static Future<void> deleteUserAccount() async {
    if (_isDemoMode || _client == null) {
      debugPrint('Demo mode: User account and data erased.');
      return;
    }
    await _client!.rpc('delete_user_account');
    await signOut();
  }

  /// Fetch active shopping list items for current user (RLS protected)
  static Future<List<ShoppingListItem>> fetchListItems(String listId) async {
    if (_isDemoMode || _client == null) {
      return [];
    }

    try {
      final response = await _client!
          .from('list_items')
          .select('id, list_id, raw_text, matched_product_id, quantity, unit, is_checked, notes')
          .eq('list_id', listId)
          .order('created_at', ascending: true);

      final List<ShoppingListItem> items = [];
      for (final map in response) {
        final prodId = map['matched_product_id'] as String?;
        final matched = prodId != null
            ? CatalogService.products.firstWhere(
                (p) => p.id == prodId,
                orElse: () => CatalogService.matchRawText(map['raw_text'])!,
              )
            : CatalogService.matchRawText(map['raw_text']);

        items.add(ShoppingListItem.fromJson(map, matched: matched));
      }
      return items;
    } catch (e) {
      debugPrint('Error fetching list items from Supabase: $e');
      return [];
    }
  }

  /// Save or update list item in Supabase
  static Future<void> saveListItem(ShoppingListItem item) async {
    if (_isDemoMode || _client == null) return;

    await _client!.from('list_items').upsert({
      'id': item.id,
      'list_id': item.listId,
      'user_id': currentUserId,
      'raw_text': item.rawText,
      'matched_product_id': item.matchedProduct?.id,
      'quantity': item.quantity,
      'unit': item.unit,
      'is_checked': item.isChecked,
      'notes': item.notes,
    });
  }

  /// Delete list item
  static Future<void> deleteListItem(String itemId) async {
    if (_isDemoMode || _client == null) return;
    await _client!.from('list_items').delete().eq('id', itemId);
  }

  /// Fetch user preferences
  static Future<UserPreferences> fetchPreferences() async {
    if (_isDemoMode || _client == null) return const UserPreferences();

    try {
      final res = await _client!
          .from('user_preferences')
          .select()
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (res != null) {
        return UserPreferences.fromJson(res);
      }
    } catch (e) {
      debugPrint('Error fetching preferences: $e');
    }
    return const UserPreferences();
  }

  /// Save user preferences
  static Future<void> savePreferences(UserPreferences prefs) async {
    if (_isDemoMode || _client == null) return;
    await _client!.from('user_preferences').upsert({
      'user_id': currentUserId,
      ...prefs.toJson(),
    });
  }
}
