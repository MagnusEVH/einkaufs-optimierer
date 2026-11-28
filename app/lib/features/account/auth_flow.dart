// app/lib/features/account/auth_flow.dart
//
// Ablauf für Anmelden, Registrieren und Passwort zurücksetzen, ohne Oberfläche.
//
// Grundsatz: Alles geht per Code aus der Mail, man bleibt in der App. Der Link
// in der Mail ist nur ein Notnagel (siehe [AuthLink]). Jeder Schritt hat einen
// nächsten Schritt und einen Weg zurück, jeder Fehler eine passende Aktion.

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';

/// Was der Ablauf vom Server braucht. Austauschbar für Tests.
class AccountApi {
  const AccountApi();
  bool get isSignedIn => SupabaseService.isSignedIn;
  String? get email => SupabaseService.currentUser?.email;
  Stream<Object?> get changes => SupabaseService.authChanges;
  Future<void> signIn(String email, String password) => SupabaseService.signIn(email, password);
  Future<void> signUp(String email, String password, String? inviteCode) =>
      SupabaseService.signUp(email, password, inviteCode: inviteCode);
  Future<void> confirmSignUp(String email, String code) => SupabaseService.confirmSignUp(email, code);
  Future<void> resendSignUpCode(String email) => SupabaseService.resendSignUpCode(email);
  Future<void> requestPasswordReset(String email) => SupabaseService.requestPasswordReset(email);
  Future<void> resetPassword(String email, String code, String password) =>
      SupabaseService.resetPassword(email, code, password);
  Future<void> updatePassword(String password) => SupabaseService.updatePassword(password);
  Future<void> signOut() => SupabaseService.signOut();
}

enum AuthStep {
  signIn,
  signUp,

  /// Code aus der Bestätigungsmail eingeben
  verifySignup,

  /// E-Mail für "Passwort vergessen" eingeben
  forgot,

  /// Code aus der Mail und neues Passwort eingeben
  resetCode,

  /// Mail-Link war abgelaufen oder schon benutzt
  linkFailed,
}

/// Knopf, den die Oberfläche zu einem Fehler anbietet.
enum AuthAction { forgotPassword, goSignIn, resendCode, retry, haveCode }

class AuthFlow extends ChangeNotifier {
  final AccountApi api;
  final DateTime Function() _now;

  /// Wartezeit zwischen zwei Mails an dieselbe Adresse (Supabase: 60 s).
  static const cooldown = Duration(seconds: 60);

  AuthFlow({this.api = const AccountApi(), DateTime Function()? now, AuthStep start = AuthStep.signIn})
      : _now = now ?? DateTime.now,
        _step = start;

  AuthStep _step;
  AuthStep get step => _step;

  String _email = '';
  String get email => _email;

  bool busy = false;
  String? error;
  List<AuthAction> actions = const [];
  String? info;

  DateTime? _resendAt;
  Future<void> Function()? _lastAction;

  /// Sekunden bis zur nächsten Mail (0 = jetzt möglich).
  int get resendIn {
    final at = _resendAt;
    if (at == null) return 0;
    final s = at.difference(_now()).inMilliseconds;
    return s <= 0 ? 0 : (s / 1000).ceil();
  }

  bool get canResend => resendIn == 0 && !busy;

  // ── Navigation ───────────────────────────────────────────────────────────

  void goTo(AuthStep step, {String? email, String? info}) {
    _step = step;
    if (email != null) _email = normEmail(email);
    error = null;
    actions = const [];
    this.info = info;
    notifyListeners();
  }

  /// "Zurück": nie ins Leere, immer ein sinnvoller Schritt davor.
  void back() => goTo(switch (_step) {
        AuthStep.verifySignup => AuthStep.signUp,
        AuthStep.resetCode => AuthStep.forgot,
        _ => AuthStep.signIn,
      });

  bool get canGoBack => _step != AuthStep.signIn;

  // ── Aktionen ─────────────────────────────────────────────────────────────

  Future<bool> signIn(String email, String password) async {
    final problem = checkEmail(email) ?? (password.isEmpty ? 'Bitte das Passwort eingeben.' : null);
    if (problem != null) return _fail(problem);
    _email = normEmail(email);
    return _run(() => api.signIn(_email, password), onError: (e) async {
      if (e.kind == AuthErrorKind.emailNotConfirmed) {
        // Noch nicht bestätigt: direkt zur Code-Eingabe, neuen Code schicken
        goTo(AuthStep.verifySignup);
        await _send(() => api.resendSignUpCode(_email),
            info: 'Deine E-Mail ist noch nicht bestätigt. Wir haben dir einen neuen Code an $_email geschickt.');
        return true;
      }
      if (e.kind == AuthErrorKind.invalidCredentials) actions = const [AuthAction.forgotPassword];
      return false;
    });
  }

  Future<bool> signUp(String email, String password, String? inviteCode) async {
    final problem = checkEmail(email) ?? checkPassword(password);
    if (problem != null) return _fail(problem);
    _email = normEmail(email);
    final ok = await _run(() => api.signUp(_email, password, inviteCode), onError: (e) async {
      if (e.kind == AuthErrorKind.userExists) {
        actions = const [AuthAction.goSignIn, AuthAction.forgotPassword];
      }
      return false;
    });
    if (ok) {
      _startCooldown();
      goTo(AuthStep.verifySignup, info: 'Wir haben dir einen Code an $_email geschickt. Gib ihn hier ein.');
    }
    return ok;
  }

  Future<bool> verifySignup(String code) async {
    final problem = checkCode(code);
    if (problem != null) return _fail(problem);
    return _run(() => api.confirmSignUp(_email, code.trim()), onError: _codeError);
  }

  Future<bool> requestReset(String email) async {
    final problem = checkEmail(email);
    if (problem != null) return _fail(problem);
    _email = normEmail(email);
    final ok = await _send(() => api.requestPasswordReset(_email));
    if (ok) {
      goTo(AuthStep.resetCode,
          info: 'Falls es ein Konto mit $_email gibt, ist ein Code unterwegs. '
              'Gib ihn hier ein und wähle ein neues Passwort.');
    } else if (actions.isEmpty) {
      actions = const [AuthAction.haveCode];
      notifyListeners();
    }
    return ok;
  }

  Future<bool> resetWithCode(String code, String password) async {
    final problem = checkCode(code) ?? checkPassword(password);
    if (problem != null) return _fail(problem);
    return _run(() => api.resetPassword(_email, code.trim(), password), onError: _codeError);
  }

  /// Neuen Code schicken, passend zum Schritt.
  Future<bool> resend() async {
    if (!canResend) return false;
    final ok = await _send(_step == AuthStep.verifySignup
        ? () => api.resendSignUpCode(_email)
        : () => api.requestPasswordReset(_email));
    if (ok) {
      error = null;
      actions = const [];
      info = 'Neuer Code an $_email ist unterwegs. Der alte gilt nicht mehr.';
      notifyListeners();
    }
    return ok;
  }

  /// Letzte Aktion nach einem Netzfehler wiederholen.
  Future<void> retry() async {
    final a = _lastAction;
    if (a != null) await a();
  }

  /// Knopf zu einem Fehler ausführen.
  Future<void> perform(AuthAction action) async {
    switch (action) {
      case AuthAction.forgotPassword:
        goTo(AuthStep.forgot);
      case AuthAction.goSignIn:
        goTo(AuthStep.signIn);
      case AuthAction.resendCode:
        await resend();
      case AuthAction.retry:
        await retry();
      case AuthAction.haveCode:
        goTo(AuthStep.resetCode, info: 'Gib den Code aus der letzten Mail ein und wähle ein neues Passwort.');
    }
  }

  // ── Intern ───────────────────────────────────────────────────────────────

  Future<bool> _codeError(AccountException e) async {
    if (e.kind == AuthErrorKind.codeInvalid) actions = const [AuthAction.resendCode];
    return false;
  }

  /// Schickt eine Mail und startet die Wartezeit.
  Future<bool> _send(Future<void> Function() call, {String? info}) async {
    final ok = await _run(call);
    if (ok) {
      _startCooldown();
      if (info != null) {
        this.info = info;
        notifyListeners();
      }
    }
    return ok;
  }

  void _startCooldown([Duration? d]) => _resendAt = _now().add(d ?? cooldown);

  bool _fail(String message) {
    error = message;
    actions = const [];
    notifyListeners();
    return false;
  }

  /// Führt [call] aus. Bei einem Fehler entscheidet [onError], ob es trotzdem
  /// weitergeht (true). Netzfehler bieten immer "Erneut versuchen".
  Future<bool> _run(Future<void> Function() call, {Future<bool> Function(AccountException e)? onError}) async {
    if (busy) return false;
    busy = true;
    error = null;
    actions = const [];
    notifyListeners();
    AccountException? err;
    try {
      await call();
      _lastAction = null;
    } on AccountException catch (e) {
      err = e;
      error = e.message;
      if (e.kind == AuthErrorKind.rateLimit) {
        _startCooldown(e.retryAfter ?? cooldown);
        if (e.retryAfter == null) {
          error = 'Gerade gehen keine Mails mehr raus (Grenze pro Stunde erreicht). '
              'Bitte später noch einmal. Hast du schon einen Code, kannst du ihn eingeben.';
        }
      }
      if (e.kind == AuthErrorKind.network) {
        _lastAction = () => _run(call, onError: onError);
        actions = const [AuthAction.retry];
      }
    } finally {
      busy = false;
      notifyListeners();
    }
    if (err == null) return true;
    final go = await (onError?.call(err) ?? Future.value(false));
    notifyListeners();
    return go;
  }

  // ── Prüfungen (auch für die Oberfläche) ──────────────────────────────────

  static String normEmail(String e) => e.trim().toLowerCase();

  static String? checkEmail(String email) {
    final e = email.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e) ? null : 'Bitte eine gültige E-Mail-Adresse eingeben.';
  }

  static String? checkPassword(String p) => p.length < 8 ? 'Das Passwort braucht mindestens 8 Zeichen.' : null;

  /// Supabase-Codes haben 6 bis 10 Ziffern (Einstellung im Dashboard).
  static String? checkCode(String c) =>
      RegExp(r'^\d{6,10}$').hasMatch(c.trim()) ? null : 'Bitte den Code aus der Mail eingeben (nur Ziffern).';
}

/// Was ein Mail-Link beim Öffnen der App mitbringt.
enum AuthLinkKind { recovery, signup, failed }

@immutable
class AuthLink {
  final AuthLinkKind kind;
  final String? message;
  const AuthLink(this.kind, [this.message]);

  /// Liest die Adresse, mit der die App geöffnet wurde. null = kein Mail-Link.
  /// Supabase hängt `#access_token=…&type=recovery` an, bei Fehlern
  /// `#error=…&error_code=otp_expired&error_description=…`.
  static AuthLink? parse(Uri u) {
    final p = <String, String>{...u.queryParameters};
    var f = u.fragment;
    if (f.startsWith('/')) f = f.substring(1); // Hash-Routing: "#/…"
    if (f.contains('=')) {
      try {
        p.addAll(Uri.splitQueryString(f.contains('?') ? f.substring(f.indexOf('?') + 1) : f));
      } catch (_) {}
    }
    if (p.containsKey('error') || p.containsKey('error_code')) {
      final code = p['error_code'];
      return AuthLink(
        AuthLinkKind.failed,
        code == 'otp_expired'
            ? 'Der Link aus der Mail ist abgelaufen oder wurde schon benutzt.'
            : 'Der Link aus der Mail hat nicht funktioniert.',
      );
    }
    if (!p.containsKey('access_token') && !p.containsKey('token_hash') && !p.containsKey('code')) return null;
    return switch (p['type']) {
      'recovery' => const AuthLink(AuthLinkKind.recovery),
      'signup' || 'email' || 'invite' => const AuthLink(AuthLinkKind.signup),
      _ => null,
    };
  }
}
