// app/lib/core/services/list_sync.dart
//
// Abgleich der gemeinsamen Einkaufsliste eines Haushalts (Stufe 3c).
//
// "Online zuerst" (Plan Konten und Haushalte): Jede Änderung geht sofort an
// den Server. Kurze Aussetzer überbrückt eine kleine Warteschlange auf dem
// Gerät, der letzte Stand liegt zum Anzeigen im Zwischenspeicher.
//
// - Ändern = nur die geänderten Felder schicken (Patch). Zwei Leute ändern
//   verschiedene Felder desselben Artikels: beides bleibt.
// - Löschen = deleted_at setzen. Ein späteres Ändern fasst deleted_at nicht
//   an, Löschen gewinnt also gegen Ändern.
// - Nachladen: alles mit updated_at ab dem zuletzt gesehenen Stand, mit zwei
//   Minuten Überlappung (updated_at entsteht vor dem Commit, späte Commits
//   gingen sonst verloren). Doppelt Geladenes schadet nicht.
// - Realtime ist nur das Signal "jetzt nachladen".

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'preferences_storage.dart';
import 'supabase_service.dart';

/// Ein Artikel, wie er auf dem Server liegt.
@immutable
class ListRow {
  final String id;
  final String householdId;
  final String rawText;
  final String? productId;
  final double quantity;
  final String? note;
  final bool checked;
  final bool deleted;
  final DateTime? updatedAt;

  const ListRow({
    required this.id,
    required this.householdId,
    required this.rawText,
    this.productId,
    this.quantity = 1,
    this.note,
    this.checked = false,
    this.deleted = false,
    this.updatedAt,
  });

  factory ListRow.fromServer(Map<String, dynamic> m) => ListRow(
        id: m['id'] as String,
        householdId: m['household_id'] as String,
        rawText: m['raw_text'] as String,
        productId: m['product_id'] as String?,
        quantity: (m['quantity'] as num?)?.toDouble() ?? 1,
        note: m['note'] as String?,
        checked: m['checked_at'] != null,
        deleted: m['deleted_at'] != null,
        updatedAt: m['updated_at'] == null ? null : DateTime.parse(m['updated_at'] as String),
      );

  /// Felder für das Anlegen auf dem Server.
  Map<String, dynamic> toInsert(DateTime now) => {
        'id': id,
        'household_id': householdId,
        'raw_text': rawText,
        'product_id': productId,
        'quantity': quantity,
        'note': note,
        'checked_at': checked ? now.toUtc().toIso8601String() : null,
      };

  /// Wendet einen Patch (Server-Spaltennamen) auf die lokale Kopie an.
  ListRow apply(Map<String, dynamic> p) => ListRow(
        id: id,
        householdId: householdId,
        rawText: p.containsKey('raw_text') ? p['raw_text'] as String : rawText,
        productId: p.containsKey('product_id') ? p['product_id'] as String? : productId,
        quantity: p.containsKey('quantity') ? (p['quantity'] as num).toDouble() : quantity,
        note: p.containsKey('note') ? p['note'] as String? : note,
        checked: p.containsKey('checked_at') ? p['checked_at'] != null : checked,
        deleted: p.containsKey('deleted_at') ? p['deleted_at'] != null : deleted,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toCache() => {
        'id': id,
        'household_id': householdId,
        'raw_text': rawText,
        'product_id': productId,
        'quantity': quantity,
        'note': note,
        'checked_at': checked ? 'x' : null,
        'deleted_at': deleted ? 'x' : null,
        'updated_at': updatedAt?.toIso8601String(),
      };
}

/// Eine wartende Änderung. insert: ganze Zeile, patch: nur geänderte Felder.
@immutable
class PendingOp {
  final String kind;
  final String id;
  final Map<String, dynamic> fields;
  const PendingOp(this.kind, this.id, this.fields);

  Map<String, dynamic> toJson() => {'kind': kind, 'id': id, 'fields': fields};
  factory PendingOp.fromJson(Map<String, dynamic> m) =>
      PendingOp(m['kind'] as String, m['id'] as String, Map<String, dynamic>.from(m['fields'] as Map));
}

/// Warum eine Änderung nicht ankam.
enum SyncProblem {
  /// Netz weg oder Server schläft (Free-Projekt pausiert): später erneut.
  offline,

  /// Sitzung abgelaufen: neu anmelden, lokale Daten bleiben.
  signedOut,
}

class SyncFailure implements Exception {
  final SyncProblem? problem; // null = dauerhaft (z. B. keine Rechte): Änderung verwerfen
  final String message;
  const SyncFailure(this.problem, this.message);
  @override
  String toString() => message;
}

/// Server-Seite, austauschbar für Tests.
abstract class ListRemote {
  Future<List<Map<String, dynamic>>> fetchSince(String householdId, DateTime? since);
  Future<void> insert(Map<String, dynamic> row);
  Future<void> patch(String id, Map<String, dynamic> fields);

  /// Ruft [onChange] bei jeder Änderung im Haushalt. Liefert "abmelden".
  void Function() listen(String householdId, void Function() onChange);
}

class SupabaseListRemote implements ListRemote {
  const SupabaseListRemote();
  SupabaseClient get _c => SupabaseService.client!;

  static const _columns = 'id, household_id, raw_text, product_id, quantity, note, checked_at, deleted_at, updated_at';

  @override
  Future<List<Map<String, dynamic>>> fetchSince(String householdId, DateTime? since) => _guard(() async {
        var q = _c.from('shopping_items').select(_columns).eq('household_id', householdId);
        if (since != null) {
          q = q.gte('updated_at', since.toUtc().toIso8601String());
        } else {
          q = q.isFilter('deleted_at', null); // erster Abruf: Gelöschtes nicht nötig
        }
        return List<Map<String, dynamic>>.from(await q.order('updated_at').limit(1000));
      });

  @override
  Future<void> insert(Map<String, dynamic> row) => _guard(() async {
        try {
          await _c.from('shopping_items').insert(row);
        } on PostgrestException catch (e) {
          if (e.code == '23505') return; // schon angelegt (zweiter Versuch nach Aussetzer)
          rethrow;
        }
      });

  @override
  Future<void> patch(String id, Map<String, dynamic> fields) =>
      _guard(() => _c.from('shopping_items').update(fields).eq('id', id));

  @override
  void Function() listen(String householdId, void Function() onChange) {
    final channel = _c
        .channel('liste-$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shopping_items',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'household_id', value: householdId),
          callback: (_) => onChange(),
        )
        .subscribe();
    return () => _c.removeChannel(channel);
  }

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST301' || e.code == 'PGRST303' || e.message.contains('JWT')) {
        throw const SyncFailure(SyncProblem.signedOut, 'Anmeldung abgelaufen');
      }
      final status = int.tryParse(e.code ?? '');
      if (status != null && status >= 500) throw SyncFailure(SyncProblem.offline, e.message);
      throw SyncFailure(null, e.message);
    } on AuthException {
      throw const SyncFailure(SyncProblem.signedOut, 'Anmeldung abgelaufen');
    } on SyncFailure {
      rethrow;
    } catch (e) {
      throw SyncFailure(SyncProblem.offline, '$e');
    }
  }
}

/// Liste eines Haushalts: Zwischenspeicher, Warteschlange, Nachladen.
class ListSync {
  final ListRemote remote;
  final String householdId;
  final DateTime Function() clock;

  /// Wird bei jeder sichtbaren Änderung gerufen (lokal oder vom Server).
  void Function()? onChanged;

  ListSync(this.remote, this.householdId, {DateTime Function()? clock}) : clock = clock ?? DateTime.now;

  final Map<String, ListRow> _rows = {};
  final List<PendingOp> _queue = [];
  DateTime? _lastSeen;
  bool _flushing = false;
  void Function()? _unlisten;

  SyncProblem? problem;

  /// Letzte verworfene Änderung (z. B. keine Rechte mehr), für einen Hinweis.
  String? droppedMessage;

  static const overlap = Duration(minutes: 2);

  String get _cacheKey => 'list_cache_v1_$householdId';
  String get _queueKey => 'list_queue_v1_$householdId';

  int get pendingCount => _queue.length;

  /// Sichtbare Artikel, älteste zuerst nicht garantiert (Reihenfolge macht die Liste).
  List<ListRow> get rows => [for (final r in _rows.values) if (!r.deleted) r];

  /// Zwischenspeicher laden (sofort anzeigen), dann abgleichen.
  Future<void> open({bool listen = true}) async {
    final cache = await PreferencesStorage.loadJson(_cacheKey);
    if (cache is Map) {
      for (final r in (cache['rows'] as List? ?? const [])) {
        final row = ListRow.fromServer(Map<String, dynamic>.from(r as Map));
        _rows[row.id] = row;
      }
      final seen = cache['last_seen'] as String?;
      _lastSeen = seen == null ? null : DateTime.parse(seen);
    }
    final queue = await PreferencesStorage.loadJson(_queueKey);
    if (queue is List) {
      _queue.addAll(queue.map((m) => PendingOp.fromJson(Map<String, dynamic>.from(m as Map))));
    }
    _notify();
    if (listen) _unlisten = remote.listen(householdId, () => unawaited(sync()));
    await sync();
  }

  void close() {
    _unlisten?.call();
    _unlisten = null;
    onChanged = null;
  }

  // ── Lokale Änderungen ────────────────────────────────────────────────────

  Future<void> add(ListRow row) {
    _rows[row.id] = row;
    _queue.add(PendingOp('insert', row.id, row.toInsert(clock())));
    return _changed();
  }

  /// Patch mit Server-Spaltennamen, z. B. {'quantity': 2}.
  Future<void> patch(String id, Map<String, dynamic> fields) {
    final row = _rows[id];
    if (row == null) return Future.value();
    _rows[id] = row.apply(fields);
    // Noch nicht angelegt: in das wartende Anlegen einrechnen
    final i = _queue.indexWhere((op) => op.id == id && op.kind == 'insert');
    if (i >= 0) {
      _queue[i] = PendingOp('insert', id, {..._queue[i].fields, ...fields});
    } else {
      _queue.add(PendingOp('patch', id, fields));
    }
    return _changed();
  }

  Future<void> setChecked(String id, bool checked) =>
      patch(id, {'checked_at': checked ? clock().toUtc().toIso8601String() : null});

  Future<void> delete(String id) => patch(id, {'deleted_at': clock().toUtc().toIso8601String()});

  Future<void> _changed() async {
    _notify();
    await _persist();
    await flush();
  }

  // ── Abgleich ─────────────────────────────────────────────────────────────

  /// Wartendes senden, dann Neues holen.
  Future<void> sync() async {
    await flush();
    if (problem != null) return;
    await pull();
  }

  /// Schickt die Warteschlange der Reihe nach. Bei Netzproblemen bleibt der
  /// Rest liegen, bei dauerhaften Fehlern (z. B. keine Rechte mehr) wird die
  /// Änderung verworfen, damit sie nicht alles Weitere blockiert.
  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      while (_queue.isNotEmpty) {
        final op = _queue.first;
        try {
          if (op.kind == 'insert') {
            await remote.insert(op.fields);
          } else {
            await remote.patch(op.id, op.fields);
          }
          problem = null;
        } on SyncFailure catch (e) {
          if (e.problem != null) {
            problem = e.problem;
            _notify();
            return;
          }
          droppedMessage = 'Eine Änderung wurde vom Server abgelehnt: ${e.message}';
          debugPrint(droppedMessage);
        }
        _queue.removeAt(0);
        await _persist();
      }
      _notify();
    } finally {
      _flushing = false;
    }
  }

  /// Holt alles seit dem letzten Stand (mit Überlappung).
  Future<void> pull() async {
    final since = _lastSeen?.subtract(overlap);
    final List<Map<String, dynamic>> fresh;
    try {
      fresh = await remote.fetchSince(householdId, since);
      problem = null;
    } on SyncFailure catch (e) {
      problem = e.problem ?? SyncProblem.offline;
      _notify();
      return;
    }
    for (final m in fresh) {
      _merge(ListRow.fromServer(m));
    }
    await _persist();
    _notify();
  }

  /// Server-Stand übernehmen, eigene wartende Änderungen obendrauf.
  void _merge(ListRow server) {
    var row = server;
    for (final op in _queue) {
      if (op.id == server.id && op.kind == 'patch') row = row.apply(op.fields);
    }
    _rows[server.id] = row;
    final at = server.updatedAt;
    if (at != null && (_lastSeen == null || at.isAfter(_lastSeen!))) _lastSeen = at;
  }

  Future<void> _persist() async {
    // Gelöschte nur so lange merken, wie das Nachladen sie noch liefern kann
    await PreferencesStorage.saveJson(_cacheKey, {
      'rows': [for (final r in _rows.values) if (!r.deleted) r.toCache()],
      'last_seen': _lastSeen?.toIso8601String(),
    });
    await PreferencesStorage.saveJson(_queueKey, [for (final op in _queue) op.toJson()]);
  }

  void _notify() => onChanged?.call();
}
