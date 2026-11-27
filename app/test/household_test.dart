// Haushalte (Stufe 3b): Wahl im Titel, Gruppe anlegen, Code einlösen,
// Verwalten mit Einladen, Rollen, Austreten. Gegen einen Fake-Server.

import 'package:einkaufs_optimierer/core/services/household_service.dart';
import 'package:einkaufs_optimierer/core/services/preferences_storage.dart';
import 'package:einkaufs_optimierer/features/household/household_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeHouseholdApi extends HouseholdApi {
  final households = <Household>[
    const Household(id: 'h1', name: 'Zuhause', myRole: HouseholdRole.owner),
    const Household(id: 'h2', name: 'Eltern', myRole: HouseholdRole.owner),
  ];
  final memberLists = <String, List<HouseholdMember>>{
    'h1': [
      const HouseholdMember(userId: 'me', name: 'Magnus', role: HouseholdRole.owner, isMe: true),
      const HouseholdMember(userId: 'u2', name: 'Anna', role: HouseholdRole.member, isMe: false),
    ],
  };
  final calls = <String>[];
  String? last = 'h2';
  String name = 'Magnus';

  @override
  bool get available => true;
  @override
  Future<List<Household>> list() async => List.of(households);
  @override
  Future<String?> lastHouseholdId() async => last;
  @override
  Future<void> rememberHousehold(String id) async => calls.add('remember $id');
  @override
  Future<String> create(String name) async {
    households.add(Household(id: 'h3', name: name, myRole: HouseholdRole.owner));
    calls.add('create $name');
    return 'h3';
  }

  @override
  Future<String> invite(String household, HouseholdRole role) async {
    calls.add('invite $household ${role.name}');
    return 'ABCD-1234-EF56-7890';
  }

  @override
  Future<String?> accept(String code) async {
    calls.add('accept $code');
    if (code != 'GUTE-CODE-0000-0000') return null;
    households.add(const Household(id: 'h9', name: 'WG', myRole: HouseholdRole.member));
    return 'h9';
  }

  @override
  Future<List<HouseholdMember>> members(String household) async =>
      memberLists[household] ??
      const [
        HouseholdMember(userId: 'me', name: 'Magnus', role: HouseholdRole.member, isMe: true),
        HouseholdMember(userId: 'o', name: 'Owner', role: HouseholdRole.owner, isMe: false),
      ];
  @override
  Future<void> setRole(String household, String user, HouseholdRole role) async =>
      calls.add('role $household $user ${role.name}');
  @override
  Future<void> remove(String household, String user) async => calls.add('remove $household $user');
  @override
  Future<String> myName() async => name;
  @override
  Future<void> setMyName(String n) async => name = n;
  @override
  Future<void> leave(String household) async {
    calls.add('leave $household');
    households.removeWhere((h) => h.id == household);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PreferencesStorage.simulateReload();
  });

  Future<FakeHouseholdApi> pump(WidgetTester tester, Widget child, {FakeHouseholdApi? api}) async {
    final fake = api ?? FakeHouseholdApi();
    await tester.pumpWidget(ProviderScope(
      overrides: [householdApiProvider.overrideWithValue(fake)],
      child: MaterialApp(home: child),
    ));
    await tester.pumpAndSettle();
    return fake;
  }

  Widget listTitle() => Scaffold(appBar: AppBar(title: const HouseholdTitle(title: 'Einkaufsliste')));

  testWidgets('Titel zeigt den zuletzt gewählten Haushalt, Wechsel wird gemerkt', (tester) async {
    final api = await pump(tester, listTitle());
    expect(find.text('Eltern'), findsOneWidget, reason: 'last_household_id vom Server');
    await tester.tap(find.byKey(const Key('household_title')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zuhause'));
    await tester.pumpAndSettle();
    expect(find.text('Zuhause'), findsOneWidget);
    expect(api.calls, contains('remember h1'));
  });

  testWidgets('Neue Gruppe anlegen wählt sie gleich aus', (tester) async {
    final api = await pump(tester, listTitle());
    await tester.tap(find.byKey(const Key('household_title')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Neue Gruppe'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ask_text')), 'Grillabend');
    await tester.tap(find.byKey(const Key('ask_ok')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('create Grillabend'));
    expect(find.text('Grillabend'), findsOneWidget);
  });

  testWidgets('Falscher Code: Hinweis, richtiger Code: beigetreten und ausgewählt', (tester) async {
    final api = await pump(tester, listTitle());
    Future<void> enter(String code) async {
      await tester.tap(find.byKey(const Key('household_title')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Einladungscode eingeben'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('ask_text')), code);
      await tester.tap(find.byKey(const Key('ask_ok')));
      await tester.pumpAndSettle();
    }

    await enter('FALS-CHER-CODE-0000');
    expect(find.textContaining('ungültig'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // Auswahl schließen
    await tester.pumpAndSettle();
    await enter('GUTE-CODE-0000-0000');
    expect(api.calls, contains('accept GUTE-CODE-0000-0000'));
    expect(find.text('WG'), findsOneWidget);
  });

  testWidgets('Owner: einladen mit gleichen Rechten zeigt den Code, Rolle ändern', (tester) async {
    final api = FakeHouseholdApi();
    await pump(tester, const HouseholdScreen(householdId: 'h1'), api: api);
    expect(find.text('Magnus (du)'), findsOneWidget);
    expect(find.text('Anna'), findsOneWidget);
    await tester.tap(find.byKey(const Key('invite_owner')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('invite h1 owner'));
    expect(find.text('ABCD-1234-EF56-7890'), findsOneWidget);
    expect(find.textContaining('gleichen Rechten wie du'), findsOneWidget);
    await tester.tap(find.text('Kopieren'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Mehr'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gleiche Rechte geben (Owner)'));
    await tester.pumpAndSettle();
    expect(api.calls, contains('role h1 u2 owner'));
  });

  testWidgets('Mitglied: kein Einladen, kein Verwalten anderer, Austreten mit Rückfrage', (tester) async {
    final api = FakeHouseholdApi()..households.add(const Household(id: 'h9', name: 'WG', myRole: HouseholdRole.member));
    await pump(tester, const HouseholdScreen(householdId: 'h9'), api: api);
    expect(find.byKey(const Key('invite_member')), findsNothing);
    expect(find.byTooltip('Mehr'), findsNothing);
    expect(find.byTooltip('Umbenennen'), findsNothing);
    await tester.tap(find.byKey(const Key('household_leave')));
    await tester.pumpAndSettle();
    expect(find.text('WG verlassen?'), findsOneWidget);
    await tester.tap(find.text('Austreten').last);
    await tester.pumpAndSettle();
    expect(api.calls, contains('leave h9'));
  });

  test('Fehler der SQL-Funktionen auf Deutsch', () {
    expect(describeHouseholdError('last owner'), contains('Owner bleiben'));
    expect(describeHouseholdError('too many attempts'), contains('Zu viele falsche Codes'));
    expect(describeHouseholdError('only owners can invite'), contains('nur Owner'));
  });
}
