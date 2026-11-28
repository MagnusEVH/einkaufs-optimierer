// Anmelde-Ablauf ohne Oberfläche: jeder Schritt, jeder Fehler hat einen
// nächsten Schritt. Fake-Server und Fake-Uhr.

import 'dart:async';

import 'package:einkaufs_optimierer/core/services/supabase_service.dart';
import 'package:einkaufs_optimierer/features/account/auth_flow.dart';
import 'package:flutter_test/flutter_test.dart';

class FlowApi extends AccountApi {
  final calls = <String>[];
  final fails = <String, AccountException>{};
  bool signedIn = false;

  @override
  bool get isSignedIn => signedIn;
  @override
  Stream<Object?> get changes => const Stream.empty();

  Future<void> _do(String name, String call, {bool signIn = false}) async {
    calls.add(call);
    final f = fails.remove(name);
    if (f != null) throw f;
    if (signIn) signedIn = true;
  }

  @override
  Future<void> signIn(String email, String password) => _do('signIn', 'signIn $email', signIn: true);
  @override
  Future<void> signUp(String email, String password, String? inviteCode) => _do('signUp', 'signUp $email');
  @override
  Future<void> confirmSignUp(String email, String code) => _do('confirm', 'confirm $email $code', signIn: true);
  @override
  Future<void> resendSignUpCode(String email) => _do('resend', 'resend $email');
  @override
  Future<void> requestPasswordReset(String email) => _do('forgot', 'forgot $email');
  @override
  Future<void> resetPassword(String email, String code, String password) =>
      _do('reset', 'reset $email $code', signIn: true);
}

const _codeWrong = AccountException('Code falsch', kind: AuthErrorKind.codeInvalid);
const _offline = AccountException('offline', kind: AuthErrorKind.network);

void main() {
  late FlowApi api;
  late DateTime now;
  late AuthFlow flow;

  setUp(() {
    api = FlowApi();
    now = DateTime(2026, 11, 28, 12);
    flow = AuthFlow(api: api, now: () => now);
  });

  test('Registrieren → Code → angemeldet, E-Mail klein und ohne Leerzeichen', () async {
    expect(await flow.signUp(' Eltern@Example.com ', 'geheim123', 'ABCD'), isTrue);
    expect(flow.step, AuthStep.verifySignup);
    expect(flow.email, 'eltern@example.com');
    expect(flow.info, contains('eltern@example.com'));
    expect(await flow.verifySignup('123456'), isTrue);
    expect(api.signedIn, isTrue);
    expect(api.calls.last, 'confirm eltern@example.com 123456');
  });

  test('Neuen Code erst nach 60 s, Zähler läuft runter', () async {
    await flow.signUp('a@b.de', 'geheim123', null);
    expect(flow.resendIn, 60);
    expect(await flow.resend(), isFalse);
    now = now.add(const Duration(seconds: 45));
    expect(flow.resendIn, 15);
    now = now.add(const Duration(seconds: 15));
    expect(await flow.resend(), isTrue);
    expect(api.calls.last, 'resend a@b.de');
    expect(flow.info, contains('Neuer Code'));
  });

  test('Falscher Code: Fehler bleibt im Schritt und bietet neuen Code an', () async {
    await flow.signUp('a@b.de', 'geheim123', null);
    api.fails['confirm'] = _codeWrong;
    expect(await flow.verifySignup('111111'), isFalse);
    expect(flow.step, AuthStep.verifySignup);
    expect(flow.actions, [AuthAction.resendCode]);
    now = now.add(AuthFlow.cooldown);
    await flow.perform(AuthAction.resendCode);
    expect(api.calls.last, 'resend a@b.de');
  });

  test('Anmelden mit unbestätigter E-Mail führt zur Code-Eingabe statt in eine Sackgasse', () async {
    api.fails['signIn'] =
        const AccountException('bitte bestätigen', kind: AuthErrorKind.emailNotConfirmed);
    expect(await flow.signIn('a@b.de', 'geheim123'), isTrue);
    expect(flow.step, AuthStep.verifySignup);
    expect(api.calls.last, 'resend a@b.de');
    expect(flow.info, contains('noch nicht bestätigt'));
  });

  test('Falsches Passwort bietet "Passwort vergessen" mit schon eingetragener E-Mail', () async {
    api.fails['signIn'] =
        const AccountException('falsch', kind: AuthErrorKind.invalidCredentials);
    expect(await flow.signIn('a@b.de', 'x'), isFalse);
    expect(flow.actions, [AuthAction.forgotPassword]);
    await flow.perform(AuthAction.forgotPassword);
    expect(flow.step, AuthStep.forgot);
    expect(flow.email, 'a@b.de');
  });

  test('Passwort vergessen: Code anfordern, mit Code und neuem Passwort direkt angemeldet', () async {
    expect(await flow.requestReset('a@b.de'), isTrue);
    expect(flow.step, AuthStep.resetCode);
    expect(await flow.resetWithCode('654321', 'kurz'), isFalse);
    expect(flow.error, contains('8 Zeichen'));
    expect(await flow.resetWithCode('654321', 'lang-genug'), isTrue);
    expect(api.calls.last, 'reset a@b.de 654321');
    expect(api.signedIn, isTrue);
  });

  test('Mail-Grenze: ehrlicher Hinweis, Code von vorher lässt sich trotzdem eingeben', () async {
    api.fails['forgot'] = const AccountException('limit', kind: AuthErrorKind.rateLimit);
    expect(await flow.requestReset('a@b.de'), isFalse);
    expect(flow.error, contains('Grenze'));
    expect(flow.actions, [AuthAction.haveCode]);
    await flow.perform(AuthAction.haveCode);
    expect(flow.step, AuthStep.resetCode);
  });

  test('Server nennt Wartezeit: Zähler übernimmt sie', () async {
    api.fails['forgot'] =
        const AccountException('warten', kind: AuthErrorKind.rateLimit, retryAfter: Duration(seconds: 42));
    await flow.requestReset('a@b.de');
    expect(flow.resendIn, 42);
    expect(flow.error, 'warten');
  });

  test('Kein Netz: "Erneut versuchen" wiederholt genau die Aktion', () async {
    api.fails['signUp'] = _offline;
    expect(await flow.signUp('a@b.de', 'geheim123', null), isFalse);
    expect(flow.actions, [AuthAction.retry]);
    await flow.perform(AuthAction.retry);
    expect(api.calls, ['signUp a@b.de', 'signUp a@b.de']);
  });

  test('Konto gibt es schon: Anmelden oder Passwort vergessen', () async {
    api.fails['signUp'] = const AccountException('gibt es', kind: AuthErrorKind.userExists);
    await flow.signUp('a@b.de', 'geheim123', null);
    expect(flow.actions, [AuthAction.goSignIn, AuthAction.forgotPassword]);
  });

  test('Zurück führt nie ins Leere', () async {
    await flow.signUp('a@b.de', 'geheim123', null);
    flow.back();
    expect(flow.step, AuthStep.signUp);
    flow.back();
    expect(flow.step, AuthStep.signIn);
    expect(flow.canGoBack, isFalse);
    await flow.requestReset('a@b.de');
    flow.back();
    expect(flow.step, AuthStep.forgot);
  });

  test('Eingaben werden vor dem Abschicken geprüft', () async {
    expect(await flow.signIn('keine-mail', 'x'), isFalse);
    expect(await flow.signUp('a@b.de', 'kurz', null), isFalse);
    expect(AuthFlow.checkCode('12345'), isNotNull);
    expect(AuthFlow.checkCode(' 12345678 '), isNull);
    expect(api.calls, isEmpty);
  });

  group('Mail-Link', () {
    test('Reset-Link', () {
      expect(AuthLink.parse(Uri.parse('https://x.io/app/#access_token=a&type=recovery'))?.kind,
          AuthLinkKind.recovery);
    });
    test('Bestätigungs-Link', () {
      expect(AuthLink.parse(Uri.parse('https://x.io/app/#access_token=a&type=signup'))?.kind, AuthLinkKind.signup);
    });
    test('Abgelaufener Link wird erkannt und erklärt', () {
      final l = AuthLink.parse(Uri.parse(
          'https://x.io/app/#error=access_denied&error_code=otp_expired&error_description=Email+link+is+invalid'));
      expect(l?.kind, AuthLinkKind.failed);
      expect(l?.message, contains('abgelaufen'));
    });
    test('Normaler Start ist kein Link', () {
      expect(AuthLink.parse(Uri.parse('https://x.io/app/')), isNull);
      expect(AuthLink.parse(Uri.parse('https://x.io/app/#/')), isNull);
    });
  });

  test('Fehlerarten und Wartezeit aus Server-Texten', () {
    expect(authErrorKind('otp_expired', '', '403'), AuthErrorKind.codeInvalid);
    expect(authErrorKind(null, 'x', '429'), AuthErrorKind.rateLimit);
    expect(authErrorKind('reauthentication_needed', '', '400'), AuthErrorKind.reauthNeeded);
    expect(retryAfterFrom('For security purposes, you can only request this after 42 seconds.'),
        const Duration(seconds: 42));
    expect(describeAuthError('over_email_send_rate_limit', 'only request this after 7 seconds.', '429'),
        contains('7 Sekunden'));
  });

  test('Doppelt tippen schickt nur einmal', () async {
    final slow = _SlowApi();
    final f = AuthFlow(api: slow);
    unawaited(f.requestReset('a@b.de'));
    expect(await f.requestReset('a@b.de'), isFalse);
    slow.done.complete();
    expect(slow.count, 1);
  });
}

class _SlowApi extends AccountApi {
  final done = Completer<void>();
  int count = 0;
  @override
  Future<void> requestPasswordReset(String email) {
    count++;
    return done.future;
  }
}
