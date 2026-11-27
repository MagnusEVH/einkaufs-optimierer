// Konto (Stufe 3a): Abläufe der Oberfläche gegen einen Fake-Server,
// Fehlertexte und Verhalten ohne Server im Build.

import 'dart:async';

import 'package:einkaufs_optimierer/core/services/supabase_service.dart';
import 'package:einkaufs_optimierer/features/account/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApi extends AccountApi {
  final calls = <String>[];
  final _changes = StreamController<Object?>.broadcast();
  bool signedIn = false;
  AccountException? failNext;

  @override
  bool get isSignedIn => signedIn;
  @override
  String? get email => signedIn ? 'test@example.com' : null;
  @override
  Stream<Object?> get changes => _changes.stream;

  Future<void> _do(String call, {bool signIn = false}) async {
    calls.add(call);
    final f = failNext;
    failNext = null;
    if (f != null) throw f;
    if (signIn) {
      signedIn = true;
      _changes.add(null);
    }
  }

  @override
  Future<void> signIn(String email, String password) => _do('signIn $email', signIn: true);
  @override
  Future<void> signUp(String email, String password, String? inviteCode) => _do('signUp $email ${inviteCode ?? ''}');
  @override
  Future<void> confirmSignUp(String email, String code) => _do('confirm $email $code', signIn: true);
  @override
  Future<void> resendSignUpCode(String email) => _do('resend $email');
  @override
  Future<void> requestPasswordReset(String email) => _do('forgot $email');
  @override
  Future<void> resetPassword(String email, String code, String password) => _do('reset $email $code', signIn: true);
  @override
  Future<void> signOut() async {
    calls.add('signOut');
    signedIn = false;
    _changes.add(null);
  }
}

void main() {
  Future<FakeApi> open(WidgetTester tester) async {
    final api = FakeApi();
    await tester.pumpWidget(MaterialApp(home: AccountScreen(api: api)));
    return api;
  }

  Future<void> type(WidgetTester tester, String key, String text) =>
      tester.enterText(find.byKey(Key(key)), text);

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('account_submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('Registrieren mit Code, dann Mail-Code bestätigen = angemeldet', (tester) async {
    final api = await open(tester);
    await tester.tap(find.text('Neu hier? Registrieren'));
    await tester.pumpAndSettle();
    await type(tester, 'account_email', ' Eltern@Example.com ');
    await type(tester, 'account_password', 'geheim123');
    await type(tester, 'account_invite', 'ABCD-EFGH-IJKL-MNOP');
    await submit(tester);
    expect(api.calls.last, startsWith('signUp'));
    expect(api.calls.last, contains('ABCD-EFGH-IJKL-MNOP'));
    expect(find.textContaining('Mail an Eltern@Example.com'), findsOneWidget);

    await type(tester, 'account_code', '12345');
    await submit(tester);
    expect(find.text('Bitte den 6-stelligen Code aus der Mail eingeben.'), findsOneWidget);

    await type(tester, 'account_code', '123456');
    await submit(tester);
    expect(api.calls.last, contains('confirm'));
    expect(find.text('Angemeldet als'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
  });

  testWidgets('Passwort vergessen: Code anfordern, mit Code neues Passwort setzen', (tester) async {
    final api = await open(tester);
    await tester.tap(find.text('Passwort vergessen'));
    await tester.pumpAndSettle();
    await type(tester, 'account_email', 'a@b.de');
    await submit(tester);
    expect(api.calls.last, 'forgot a@b.de');
    await type(tester, 'account_code', '654321');
    await type(tester, 'account_password', 'kurz');
    await submit(tester);
    expect(find.text('Das Passwort braucht mindestens 8 Zeichen.'), findsOneWidget);
    await type(tester, 'account_password', 'lang-genug');
    await submit(tester);
    expect(api.calls.last, 'reset a@b.de 654321');
    expect(find.text('Angemeldet als'), findsOneWidget);
  });

  testWidgets('Fehler vom Server erscheinen als Text, Abmelden führt zurück', (tester) async {
    final api = await open(tester);
    await type(tester, 'account_email', 'a@b.de');
    await type(tester, 'account_password', 'falsch');
    api.failNext = const AccountException('E-Mail oder Passwort stimmt nicht.');
    await submit(tester);
    expect(find.text('E-Mail oder Passwort stimmt nicht.'), findsOneWidget);
    expect(api.signedIn, isFalse);

    await submit(tester);
    expect(api.signedIn, isTrue);
    await tester.tap(find.text('Abmelden'));
    await tester.pumpAndSettle();
    expect(api.calls.last, 'signOut');
    expect(find.byKey(const Key('account_submit')), findsOneWidget);
  });

  testWidgets('Ungültige E-Mail wird nicht abgeschickt', (tester) async {
    final api = await open(tester);
    await type(tester, 'account_email', 'keine-mail');
    await type(tester, 'account_password', 'x');
    await submit(tester);
    expect(api.calls, isEmpty);
    expect(find.text('Bitte eine gültige E-Mail-Adresse eingeben.'), findsOneWidget);
  });

  test('Fehlertexte auf Deutsch, Registrierung ohne Einladung verständlich', () {
    expect(describeAuthError('invalid_credentials', 'Invalid login credentials', '400'), 'E-Mail oder Passwort stimmt nicht.');
    expect(describeAuthError(null, 'Database error saving new user', '500'), contains('Einladungscode'));
    expect(describeAuthError('otp_expired', 'Token has expired or is invalid', '403'), contains('abgelaufen'));
    expect(describeAuthError(null, 'irgendwas', '429'), contains('Zu viele Versuche'));
  });

  test('Ohne Server im Build: lokal, nicht angemeldet, Konto-Aufrufe melden das', () async {
    await SupabaseService.initialize(supabaseUrl: '', supabaseKey: '');
    expect(SupabaseService.isDemoMode, isTrue);
    expect(SupabaseService.isSignedIn, isFalse);
    expect(SupabaseService.signIn('a@b.de', 'x'), throwsA(isA<AccountException>()));
    expect(await SupabaseService.needsReload(), isFalse);
  });

  testWidgets('Ohne Code (nur Link in der Mail): Weiter führt zur Anmeldung', (tester) async {
    final api = await open(tester);
    await tester.tap(find.text('Neu hier? Registrieren'));
    await tester.pumpAndSettle();
    await type(tester, 'account_email', 'a@b.de');
    await type(tester, 'account_password', 'geheim123');
    await submit(tester);
    await submit(tester); // "Weiter" ohne Code
    expect(api.calls.where((c) => c.startsWith('confirm')), isEmpty);
    expect(find.textContaining('Nach dem Bestätigen hier'), findsOneWidget);
    expect(find.byKey(const Key('account_password')), findsOneWidget);
  });

  testWidgets('Neues Passwort nach dem Mail-Link', (tester) async {
    final api = _PwApi();
    await tester.pumpWidget(MaterialApp(home: NewPasswordScreen(api: api)));
    await tester.enterText(find.byKey(const Key('new_password')), 'kurz');
    await tester.tap(find.byKey(const Key('new_password_save')));
    await tester.pumpAndSettle();
    expect(api.saved, isNull);
    await tester.enterText(find.byKey(const Key('new_password')), 'lang-genug');
    await tester.tap(find.byKey(const Key('new_password_save')));
    await tester.pumpAndSettle();
    expect(api.saved, 'lang-genug');
    expect(find.textContaining('Gespeichert'), findsOneWidget);
  });
}

class _PwApi extends AccountApi {
  String? saved;
  @override
  Future<void> updatePassword(String password) async => saved = password;
}
