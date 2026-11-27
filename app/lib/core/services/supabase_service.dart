// app/lib/core/services/supabase_service.dart
//
// Verbindung zum Supabase-Projekt: Konto (Stufe 3a). Ohne SUPABASE_URL und
// SUPABASE_KEY im Build läuft alles nur lokal auf dem Gerät.
//
// Anmeldung mit E-Mail und Passwort. Bestätigen und "Passwort vergessen" gehen
// per Link oder per 6-stelligem Code aus der Mail. Den Code enthalten die Mails
// erst mit eigenem SMTP (vorher lassen sich die Vorlagen nicht ändern).
//
// Links öffnen auf dem iPhone Safari statt der Home-Bildschirm-App. Deshalb
// der Ablauf ohne PKCE (implicit): Der PKCE-Schlüssel läge nur im Speicher der
// Home-Bildschirm-App, in Safari würde der Link scheitern. Mit implicit setzt
// man in Safari das neue Passwort und meldet sich danach in der App an.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/user_preferences.dart';
import 'preferences_storage.dart';

class SupabaseService {
  static SupabaseClient? _client;

  /// Alte Tabellen (Analytics, Push-Protokoll) und die Edge Function
  /// `optimize-route` gibt es im neuen Schema nicht mehr. Bleibt aus, bis sie
  /// mit Einwilligung (V25) bzw. als Server-Optimizer (V28) neu kommen.
  static const bool legacyBackend = false;

  /// true, solange kein Server eingerichtet ist (alles bleibt auf dem Gerät).
  static bool get isDemoMode => _client == null;
  static SupabaseClient? get client => _client;

  static User? get currentUser => _client?.auth.currentUser;
  static bool get isSignedIn => currentUser != null;

  /// Meldet An- und Abmeldung (leer ohne Server).
  static Stream<AuthState> get authChanges => _client?.auth.onAuthStateChange ?? const Stream.empty();

  /// Link "Passwort zurücksetzen" aus der Mail wurde geöffnet. Das Ereignis
  /// kommt oft schon beim Start, bevor ein Bildschirm zuhört: [recoveryPending]
  /// merkt es sich, bis die Oberfläche es abholt.
  static final ValueNotifier<bool> recoveryPending = ValueNotifier(false);

  static Future<void> initialize({
    String supabaseUrl = AppConfig.supabaseUrl,
    String supabaseKey = AppConfig.supabaseKey,
  }) async {
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      debugPrint('Kein Supabase im Build: alles bleibt lokal.');
      return;
    }
    try {
      // Höchstens 8 s: Der Start der App darf nie am Server hängen
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseKey,
        authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
      ).timeout(const Duration(seconds: 8));
      _client = Supabase.instance.client;
      _client!.auth.onAuthStateChange.listen((s) {
        if (s.event == AuthChangeEvent.passwordRecovery) recoveryPending.value = true;
      }, onError: (Object e) => debugPrint('Auth: $e'));
    } catch (e) {
      debugPrint('Supabase nicht erreichbar: $e. Alles bleibt lokal.');
      _client = null;
    }
  }

  /// Nutzer-ID für alte, nur lokale Datensätze.
  static String get currentUserId => currentUser?.id ?? '00000000-0000-0000-0000-000000000001';

  static SupabaseClient get _c {
    final c = _client;
    if (c == null) throw const AccountException('Kein Server eingerichtet.');
    return c;
  }

  // ── Konto ────────────────────────────────────────────────────────────────

  static Future<void> signIn(String email, String password) =>
      _guard(() => _c.auth.signInWithPassword(email: _normEmail(email), password: password));

  /// Legt das Konto an. Danach kommt eine Mail mit Code, siehe [confirmSignUp].
  /// Ohne Code geht es nur mit einer freigeschalteten Adresse (Allowlist).
  static Future<void> signUp(String email, String password, {String? inviteCode, String? displayName}) =>
      _guard(() => _c.auth.signUp(
            email: _normEmail(email),
            password: password,
            data: {
              if (inviteCode != null && inviteCode.trim().isNotEmpty) 'invite_code': inviteCode.trim(),
              if (displayName != null && displayName.trim().isNotEmpty) 'display_name': displayName.trim(),
            },
          ));

  static Future<void> confirmSignUp(String email, String code) =>
      _guard(() => _c.auth.verifyOTP(email: _normEmail(email), token: code.trim(), type: OtpType.signup));

  static Future<void> resendSignUpCode(String email) =>
      _guard(() => _c.auth.resend(email: _normEmail(email), type: OtpType.signup));

  /// Schickt einen Code für ein neues Passwort, siehe [resetPassword].
  static Future<void> requestPasswordReset(String email) =>
      _guard(() => _c.auth.resetPasswordForEmail(_normEmail(email)));

  static Future<void> resetPassword(String email, String code, String newPassword) => _guard(() async {
        await _c.auth.verifyOTP(email: _normEmail(email), token: code.trim(), type: OtpType.recovery);
        await _c.auth.updateUser(UserAttributes(password: newPassword));
      });

  /// Neues Passwort für die gerade angemeldete Sitzung (nach dem Mail-Link).
  static Future<void> updatePassword(String newPassword) =>
      _guard(() => _c.auth.updateUser(UserAttributes(password: newPassword)));

  static Future<void> signOut() async {
    if (_client == null) return;
    await _guard(() => _c.auth.signOut());
  }

  /// DSGVO Art. 17: Konto, Mitgliedschaften und verwaiste Haushalte löschen.
  static Future<void> deleteAccount() => _guard(() async {
        await _c.rpc('delete_my_account');
        // Die Sitzung ist nach dem Löschen ungültig, lokal trotzdem abmelden
        try {
          await _c.auth.signOut(scope: SignOutScope.local);
        } catch (_) {}
      });

  /// Einmal am Tag "aktiv" melden (nur Datum, für die Kontozahl im Cockpit).
  static Future<void> touchLastSeen() async {
    if (!isSignedIn) return;
    try {
      await _c.rpc('touch_last_seen');
    } catch (e) {
      debugPrint('touch_last_seen: $e');
    }
  }

  /// true, wenn der Server eine neuere App verlangt.
  static Future<bool> needsReload() async {
    if (_client == null) return false;
    try {
      final v = await _c.rpc('min_app_version');
      return v is int && v > AppConfig.appSchemaVersion;
    } catch (_) {
      return false; // Server schläft oder offline: nicht blockieren
    }
  }

  static String _normEmail(String email) => email.trim().toLowerCase();

  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on AuthException catch (e) {
      throw AccountException.fromAuth(e);
    } on PostgrestException catch (e) {
      throw AccountException(e.message);
    } on AccountException {
      rethrow;
    } catch (e) {
      throw AccountException.network(e);
    }
  }

  // ── Einstellungen (bleiben vorerst auf dem Gerät) ─────────────────────────

  static Future<UserPreferences> fetchPreferences() async {
    final local = await PreferencesStorage.loadUserPreferences();
    return local != null ? UserPreferences.fromJson(local) : const UserPreferences();
  }

  static Future<void> savePreferences(UserPreferences prefs) =>
      PreferencesStorage.saveUserPreferences(prefs.toJson());
}

/// Fehler beim Konto, mit verständlichem deutschem Text.
class AccountException implements Exception {
  final String message;
  const AccountException(this.message);

  factory AccountException.fromAuth(AuthException e) => AccountException(describeAuthError(e.code, e.message, e.statusCode));

  factory AccountException.network(Object e) {
    debugPrint('Konto: $e');
    return const AccountException('Server nicht erreichbar. Bitte Verbindung prüfen und gleich noch einmal versuchen.');
  }

  @override
  String toString() => message;
}

/// Übersetzt GoTrue-Fehler. Codes laut Supabase-Doku (Auth error codes).
@visibleForTesting
String describeAuthError(String? code, String message, String? status) {
  switch (code) {
    case 'invalid_credentials':
      return 'E-Mail oder Passwort stimmt nicht.';
    case 'email_not_confirmed':
      return 'Bitte zuerst die E-Mail bestätigen (Code aus der Mail).';
    case 'user_already_exists':
    case 'email_exists':
      return 'Mit dieser E-Mail gibt es schon ein Konto. Bitte anmelden.';
    case 'weak_password':
      return 'Das Passwort ist zu schwach. Bitte mindestens 8 Zeichen.';
    case 'otp_expired':
      return 'Der Code ist abgelaufen oder falsch. Bitte einen neuen anfordern.';
    case 'over_email_send_rate_limit':
    case 'over_request_rate_limit':
      return 'Zu viele Versuche. Bitte in ein paar Minuten noch einmal.';
    case 'email_address_invalid':
      return 'Diese E-Mail-Adresse ist ungültig.';
    case 'reauthentication_needed':
    case 'reauthentication_not_valid':
      return 'Zum Ändern bitte über "Passwort vergessen" gehen (Link aus der Mail).';
    case 'same_password':
      return 'Das neue Passwort muss sich vom alten unterscheiden.';
    case 'unexpected_failure':
      // Unser Datenbank-Trigger lehnt Registrierungen ohne Einladung ab
      return 'Registrierung nur mit gültigem Einladungscode oder freigeschalteter Adresse.';
  }
  if (message.contains('Database error saving new user')) {
    return 'Registrierung nur mit gültigem Einladungscode oder freigeschalteter Adresse.';
  }
  if (status == '429') return 'Zu viele Versuche. Bitte in ein paar Minuten noch einmal.';
  return 'Das hat nicht geklappt: $message';
}
