// Abgleich der gemeinsamen Liste (Stufe 3c): offline hinzufügen, gleichzeitig
// ändern, Löschen gegen Ändern, Warteschlange und Zwischenspeicher.
// Der Fake-Server bildet den Trigger stamp_shopping_item nach.

import 'package:einkaufs_optimierer/core/services/household_service.dart';
import 'package:einkaufs_optimierer/core/services/list_sync.dart';
import 'package:einkaufs_optimierer/core/services/preferences_storage.dart';
import 'package:einkaufs_optimierer/features/shopping_list/shopping_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ein Server für alle Geräte.
class FakeServer {
  final rows = <String, Map<String, dynamic>>{};
  var _t = DateTime.utc(2026, 11, 27, 12);
  final listeners = <void Function()>[];

  DateTime _tick() => _t = _t.add(const Duration(seconds: 1));

  void insert(Map<String, dynamic> row) {
    if (rows.containsKey(row['id'])) return; // 23505 gilt als angekommen
    rows[row['id'] as String] = {...row, 'deleted_at': null, 'updated_at': _tick().toIso8601String()};
    _ping();
  }

  void patch(String id, Map<String, dynamic> fields) {
    final old = rows[id];
    if (old == null) return; // RLS: 0 Zeilen
    final next = {...old, ...fields, 'id': old['id'], 'household_id': old['household_id']};
    // Trigger: schon abgehakt bleibt beim ersten Zeitpunkt
    if (old['checked_at'] != null && next['checked_at'] != null) next['checked_at'] = old['checked_at'];
    next['updated_at'] = _tick().toIso8601String();
    rows[id] = next;
    _ping();
  }

  List<Map<String, dynamic>> since(String hh, DateTime? since) => [
        for (final r in rows.values)
          if (r['household_id'] == hh &&
              (since == null ? r['deleted_at'] == null : !DateTime.parse(r['updated_at'] as String).isBefore(since)))
            Map<String, dynamic>.from(r),
      ];

  void _ping() {
    for (final l in List.of(listeners)) {
      l();
    }
  }
}

/// Ein Gerät mit eigener Verbindung (online/offline).
class Device implements ListRemote {
  final FakeServer server;
  bool online = true;
  String? rejectNext; // dauerhafter Fehler (z. B. RLS)
  Device(this.server);

  void _check() {
    if (!online) throw const SyncFailure(SyncProblem.offline, 'offline');
    final r = rejectNext;
    rejectNext = null;
    if (r != null) throw SyncFailure(null, r);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(String householdId, DateTime? since) async {
    _check();
    return server.since(householdId, since);
  }

  @override
  Future<void> insert(Map<String, dynamic> row) async {
    _check();
    server.insert(row);
  }

  @override
  Future<void> patch(String id, Map<String, dynamic> fields) async {
    _check();
    server.patch(id, fields);
  }

  @override
  void Function() listen(String householdId, void Function() onChange) => () {};
}

ListRow row(String id, String text, {double qty = 1}) =>
    ListRow(id: id, householdId: 'h1', rawText: text, quantity: qty);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PreferencesStorage.simulateReload();
  });

  test('Offline hinzufügen: sofort sichtbar, wartet, geht mit Netz raus', () async {
    final server = FakeServer();
    final dev = Device(server)..online = false;
    final a = ListSync(dev, 'h1');
    await a.open(listen: false);
    expect(a.problem, SyncProblem.offline);

    await a.add(row('1', 'Milch'));
    expect(a.rows.map((r) => r.rawText), ['Milch']);
    expect(a.pendingCount, 1);
    expect(server.rows, isEmpty);

    dev.online = true;
    await a.sync();
    expect(a.pendingCount, 0);
    expect(a.problem, isNull);
    expect(server.rows['1']!['raw_text'], 'Milch');
  });

  test('Zweites Gerät sieht Änderungen nach dem Nachladen', () async {
    final server = FakeServer();
    final a = ListSync(Device(server), 'h1');
    final b = ListSync(Device(server), 'h1');
    await a.open(listen: false);
    await b.open(listen: false);
    await a.add(row('1', 'Eier'));
    await b.sync();
    expect(b.rows.single.rawText, 'Eier');
  });

  test('Gleichzeitig: einer hakt ab, der andere ändert die Menge, beides bleibt', () async {
    final server = FakeServer();
    final a = ListSync(Device(server), 'h1');
    final b = ListSync(Device(server), 'h1');
    await a.open(listen: false);
    await a.add(row('1', 'Butter'));
    await b.open(listen: false);

    await a.setChecked('1', true);
    await b.patch('1', {'quantity': 3});
    await a.sync();
    await b.sync();
    for (final s in [a, b]) {
      expect(s.rows.single.checked, isTrue);
      expect(s.rows.single.quantity, 3);
    }
  });

  test('Beide haken gleichzeitig ab: bleibt abgehakt, kein Fehler', () async {
    final server = FakeServer();
    final a = ListSync(Device(server), 'h1');
    final b = ListSync(Device(server), 'h1');
    await a.open(listen: false);
    await a.add(row('1', 'Brot'));
    await b.open(listen: false);
    await a.setChecked('1', true);
    await b.setChecked('1', true);
    await a.sync();
    await b.sync();
    expect(a.rows.single.checked && b.rows.single.checked, isTrue);
    expect(a.pendingCount + b.pendingCount, 0);
  });

  test('Löschen gegen Ändern: Löschen gewinnt, egal in welcher Reihenfolge', () async {
    final server = FakeServer();
    final devA = Device(server);
    final a = ListSync(devA, 'h1');
    final b = ListSync(Device(server), 'h1');
    await a.open(listen: false);
    await a.add(row('1', 'Käse'));
    await a.add(row('2', 'Wurst'));
    await b.open(listen: false);

    // 1: A löscht offline, B ändert, A kommt zurück
    devA.online = false;
    await a.delete('1');
    await b.patch('1', {'quantity': 2});
    devA.online = true;
    await a.sync();
    await b.sync();
    expect(a.rows.map((r) => r.id), ['2']);
    expect(b.rows.map((r) => r.id), ['2']);

    // 2: A löscht zuerst, B ändert danach (B kennt das Löschen noch nicht)
    await a.delete('2');
    await b.patch('2', {'quantity': 5});
    await b.sync();
    await a.sync();
    expect(a.rows, isEmpty);
    expect(b.rows, isEmpty);
  });

  test('Eigene wartende Änderung wird beim Nachladen nicht überschrieben', () async {
    final server = FakeServer();
    final devA = Device(server);
    final a = ListSync(devA, 'h1');
    await a.open(listen: false);
    await a.add(row('1', 'Reis'));
    devA.online = false;
    await a.patch('1', {'quantity': 4}); // wartet
    server.patch('1', {'note': 'Basmati'}); // jemand anderes, A sieht es beim Nachladen
    devA.online = true;
    await a.pull(); // erst nachladen, Warteschlange noch voll
    expect(a.rows.single.quantity, 4, reason: 'eigene Änderung bleibt sichtbar');
    expect(a.rows.single.note, 'Basmati');
    await a.sync();
    expect(server.rows['1']!['quantity'], 4);
    expect(server.rows['1']!['note'], 'Basmati');
  });

  test('Abgelehnte Änderung blockiert nicht den Rest', () async {
    final server = FakeServer();
    final dev = Device(server);
    final a = ListSync(dev, 'h1');
    await a.open(listen: false);
    dev.online = false;
    await a.add(row('1', 'A'));
    await a.add(row('2', 'B'));
    dev
      ..online = true
      ..rejectNext = 'new row violates row-level security policy';
    await a.sync();
    expect(a.pendingCount, 0);
    expect(server.rows.keys, ['2']);
    expect(a.droppedMessage, contains('abgelehnt'));
  });

  test('Ändern vor dem ersten Senden landet im Anlegen (ein Aufruf statt zwei)', () async {
    final server = FakeServer();
    final dev = Device(server)..online = false;
    final a = ListSync(dev, 'h1');
    await a.open(listen: false);
    await a.add(row('1', 'Tee'));
    await a.patch('1', {'quantity': 2});
    expect(a.pendingCount, 1);
    dev.online = true;
    await a.sync();
    expect(server.rows['1']!['quantity'], 2);
  });

  test('Zwischenspeicher und Warteschlange überstehen das Neuladen', () async {
    final server = FakeServer();
    final dev = Device(server);
    final a = ListSync(dev, 'h1');
    await a.open(listen: false);
    await a.add(row('1', 'Nudeln'));
    dev.online = false;
    await a.add(row('2', 'Soße'));

    PreferencesStorage.simulateReload();
    final again = ListSync(dev, 'h1');
    await again.open(listen: false); // offline
    expect(again.rows.map((r) => r.rawText).toSet(), {'Nudeln', 'Soße'});
    expect(again.pendingCount, 1);
    dev.online = true;
    await again.sync();
    expect(server.rows.keys.toSet(), {'1', '2'});
  });

  group('Liste in der App', () {
    late FakeServer server;
    late Device device;
    late ProviderContainer container;

    setUp(() async {
      server = FakeServer();
      device = Device(server);
      container = ProviderContainer(overrides: [
        householdApiProvider.overrideWithValue(_OneHousehold()),
        listRemoteProvider.overrideWithValue(device),
      ]);
      container.read(shoppingListProvider);
      await _settle(container);
    });

    tearDown(() => container.dispose());

    test('Angemeldet mit Haushalt: Hinzufügen geht an den Server, Beispielkorb lässt sich übernehmen', () async {
      final st = container.read(shoppingListProvider);
      expect(st.shared, isTrue);
      expect(st.items, isEmpty, reason: 'Haushalt hat noch nichts');
      expect(st.importable, 6, reason: 'Beispielkorb auf dem Gerät');

      final ctrl = container.read(shoppingListProvider.notifier);
      ctrl.addItem('eier');
      await _settle(container);
      expect(server.rows.values.map((r) => r['raw_text']), ['eier']);

      await ctrl.importLocal();
      await _settle(container);
      expect(server.rows.length, 7);
      expect(container.read(shoppingListProvider).importable, 0);
    });

    test('Abhaken, Menge, Löschen und Einkauf abschließen laufen über den Server', () async {
      final ctrl = container.read(shoppingListProvider.notifier);
      await ctrl.declineImport();
      ctrl.addItem('milch');
      ctrl.addItem('brot');
      await _settle(container);
      final items = container.read(shoppingListProvider).items;
      final milch = items.firstWhere((i) => i.rawText == 'milch').id;
      final brot = items.firstWhere((i) => i.rawText == 'brot').id;
      ctrl.toggleChecked(milch);
      ctrl.updateQuantity(brot, 1);
      await _settle(container);
      expect(server.rows[milch]!['checked_at'], isNotNull);
      expect(server.rows[brot]!['quantity'], 2);

      ctrl.removeItems({milch});
      await _settle(container);
      expect(server.rows[milch]!['deleted_at'], isNotNull);
      expect(container.read(shoppingListProvider).items.map((i) => i.rawText), ['brot']);
    });

    test('Offline: Hinweis mit Zahl wartender Änderungen', () async {
      final ctrl = container.read(shoppingListProvider.notifier);
      device.online = false;
      ctrl.addItem('käse');
      await _settle(container);
      final st = container.read(shoppingListProvider);
      expect(st.problem, SyncProblem.offline);
      expect(st.pendingCount, 1);
      expect(st.items.single.rawText, 'käse');
      device.online = true;
      await ctrl.syncNow();
      await _settle(container);
      expect(container.read(shoppingListProvider).pendingCount, 0);
    });
  });
}

Future<void> _settle(ProviderContainer c) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _OneHousehold extends HouseholdApi {
  @override
  bool get available => true;
  @override
  Future<List<Household>> list() async => const [Household(id: 'h1', name: 'Zuhause', myRole: HouseholdRole.owner)];
  @override
  Future<String?> lastHouseholdId() async => 'h1';
  @override
  Future<void> rememberHousehold(String id) async {}
}
