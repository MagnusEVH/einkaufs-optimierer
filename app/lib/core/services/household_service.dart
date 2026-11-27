// app/lib/core/services/household_service.dart
//
// Haushalte und Gruppen (Stufe 3b): wählen, anlegen, einladen, beitreten,
// Rollen, austreten. Alles läuft über RLS bzw. die RPC-Funktionen aus
// supabase/migrations. Ohne Anmeldung gibt es keine Haushalte.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'preferences_storage.dart';
import 'supabase_service.dart';

enum HouseholdRole { owner, member }

HouseholdRole _role(Object? v) => v == 'owner' ? HouseholdRole.owner : HouseholdRole.member;

@immutable
class Household {
  final String id;
  final String name;
  final HouseholdRole myRole;
  const Household({required this.id, required this.name, required this.myRole});
  bool get isOwner => myRole == HouseholdRole.owner;
}

@immutable
class HouseholdMember {
  final String userId;
  final String name;
  final HouseholdRole role;
  final bool isMe;
  const HouseholdMember({required this.userId, required this.name, required this.role, required this.isMe});
  bool get isOwner => role == HouseholdRole.owner;
}

/// Server-Zugriffe, austauschbar für Tests.
class HouseholdApi {
  const HouseholdApi();

  SupabaseClient get _c => SupabaseService.client!;
  String get _me => SupabaseService.currentUser!.id;

  bool get available => SupabaseService.isSignedIn;

  Future<List<Household>> list() => _guard(() async {
        final rows = await _c
            .from('household_members')
            .select('role, households(id, name)')
            .eq('user_id', _me);
        final result = [
          for (final r in rows)
            if (r['households'] != null)
              Household(
                id: r['households']['id'] as String,
                name: r['households']['name'] as String,
                myRole: _role(r['role']),
              ),
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return result;
      });

  Future<String?> lastHouseholdId() => _guard(() async {
        final row = await _c.from('profiles').select('last_household_id').eq('id', _me).maybeSingle();
        return row?['last_household_id'] as String?;
      });

  Future<void> rememberHousehold(String id) =>
      _guard(() => _c.from('profiles').update({'last_household_id': id}).eq('id', _me));

  Future<String> create(String name) => _guard(() async => await _c.rpc('create_household', params: {'p_name': name}) as String);

  Future<void> rename(String id, String name) => _guard(() => _c.from('households').update({'name': name}).eq('id', id));

  /// Liefert den Code genau einmal (auf dem Server liegt nur der Hash).
  Future<String> invite(String household, HouseholdRole role) => _guard(() async => await _c.rpc('create_invitation',
      params: {'p_household': household, 'p_max_uses': 1, 'p_role': role.name}) as String);

  /// Haushalts-ID, oder null bei ungültigem/abgelaufenem Code.
  Future<String?> accept(String code) => _guard(() async => await _c.rpc('accept_invitation', params: {'p_code': code}) as String?);

  Future<List<HouseholdMember>> members(String household) => _guard(() async {
        final rows = await _c
            .from('household_members')
            .select('user_id, role, joined_at')
            .eq('household_id', household)
            .order('joined_at');
        final ids = [for (final r in rows) r['user_id'] as String];
        final profiles = ids.isEmpty
            ? const <Map<String, dynamic>>[]
            : await _c.from('profiles').select('id, display_name').inFilter('id', ids);
        final names = {for (final p in profiles) p['id'] as String: (p['display_name'] as String?) ?? ''};
        return [
          for (final r in rows)
            HouseholdMember(
              userId: r['user_id'] as String,
              name: names[r['user_id']] ?? '',
              role: _role(r['role']),
              isMe: r['user_id'] == _me,
            ),
        ];
      });

  Future<void> setRole(String household, String user, HouseholdRole role) => _guard(() =>
      _c.rpc('set_member_role', params: {'p_household': household, 'p_user': user, 'p_role': role.name}));

  Future<void> remove(String household, String user) =>
      _guard(() => _c.rpc('remove_member', params: {'p_household': household, 'p_user': user}));

  /// Eigener Name, den die anderen im Haushalt sehen.
  Future<String> myName() => _guard(() async {
        final row = await _c.from('profiles').select('display_name').eq('id', _me).maybeSingle();
        return (row?['display_name'] as String?) ?? '';
      });

  Future<void> setMyName(String name) =>
      _guard(() => _c.from('profiles').update({'display_name': name.trim()}).eq('id', _me));

  Future<void> leave(String household) => _guard(() => _c.rpc('leave_household', params: {'p_household': household}));

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      throw AccountException(describeHouseholdError(e.message));
    } on AccountException {
      rethrow;
    } catch (e) {
      throw AccountException.network(e);
    }
  }
}

/// Übersetzt die Fehlertexte unserer SQL-Funktionen.
@visibleForTesting
String describeHouseholdError(String message) {
  if (message.contains('last owner')) {
    return 'Mindestens eine Person muss Owner bleiben. Mach vorher jemand anderen zum Owner.';
  }
  if (message.contains('too many households')) return 'Du bist schon in 20 Haushalten oder Gruppen.';
  if (message.contains('too many attempts')) return 'Zu viele falsche Codes. Bitte in einer Stunde noch einmal.';
  if (message.contains('only owners')) return 'Das dürfen nur Owner des Haushalts.';
  if (message.contains('not authenticated')) return 'Bitte zuerst anmelden.';
  if (message.contains('violates check constraint')) return 'Der Name ist zu lang oder leer (1 bis 60 Zeichen).';
  return 'Das hat nicht geklappt: $message';
}

@immutable
class HouseholdState {
  final List<Household> households;
  final String? currentId;
  final bool loading;
  final String? error;
  const HouseholdState({this.households = const [], this.currentId, this.loading = false, this.error});

  Household? get current {
    for (final h in households) {
      if (h.id == currentId) return h;
    }
    return households.isEmpty ? null : households.first;
  }
}

class HouseholdController extends StateNotifier<HouseholdState> {
  final HouseholdApi api;
  HouseholdController(this.api) : super(const HouseholdState()) {
    refresh();
    // Nach An- und Abmelden neu laden
    _auth = SupabaseService.authChanges.listen((_) => refresh(), onError: (Object _) {});
  }

  StreamSubscription<Object?>? _auth;

  @override
  void dispose() {
    _auth?.cancel();
    super.dispose();
  }

  static const _keyCurrent = 'current_household_v1';

  /// Lädt die Haushalte neu (nach Anmelden, Beitreten, Anlegen).
  Future<void> refresh() async {
    if (!api.available) {
      state = const HouseholdState();
      return;
    }
    state = HouseholdState(households: state.households, currentId: state.currentId, loading: true);
    try {
      final list = await api.list();
      var current = state.currentId ?? await PreferencesStorage.loadJson(_keyCurrent) as String?;
      if (current == null || !list.any((h) => h.id == current)) {
        current = await api.lastHouseholdId();
      }
      if (current != null && !list.any((h) => h.id == current)) current = null;
      state = HouseholdState(households: list, currentId: current ?? (list.isEmpty ? null : list.first.id));
    } on AccountException catch (e) {
      state = HouseholdState(households: state.households, currentId: state.currentId, error: e.message);
    }
  }

  Future<void> select(String id) async {
    state = HouseholdState(households: state.households, currentId: id);
    await PreferencesStorage.saveJson(_keyCurrent, id);
    try {
      await api.rememberHousehold(id);
    } on AccountException catch (e) {
      debugPrint('Haushalt merken: $e'); // lokal gemerkt reicht
    }
  }

  Future<void> create(String name) async {
    final id = await api.create(name.trim());
    await refresh();
    await select(id);
  }

  /// true, wenn der Code gültig war.
  Future<bool> join(String code) async {
    final id = await api.accept(code.trim());
    if (id == null) return false;
    await refresh();
    await select(id);
    return true;
  }

  Future<void> leave(String id) async {
    await api.leave(id);
    if (state.currentId == id) state = HouseholdState(households: state.households);
    await refresh();
  }

  void clear() => state = const HouseholdState();
}

final householdApiProvider = Provider<HouseholdApi>((ref) => const HouseholdApi());

final householdProvider = StateNotifierProvider<HouseholdController, HouseholdState>(
  (ref) => HouseholdController(ref.watch(householdApiProvider)),
);
