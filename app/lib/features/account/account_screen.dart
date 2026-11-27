// app/lib/features/account/account_screen.dart
//
// Konto: Anmelden, Registrieren (mit Einladungscode), E-Mail bestätigen und
// Passwort vergessen per Link oder 6-stelligem Code aus der Mail, Abmelden.
// Den Code enthalten die Mails erst mit eigenem SMTP, bis dahin der Link.
// Konto löschen liegt im Profil unter Datenschutz.

import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

/// Was der Bildschirm vom Server braucht. Austauschbar für Tests.
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

enum _Mode { signIn, signUp, confirm, forgot, reset }

class AccountScreen extends StatefulWidget {
  final AccountApi api;
  const AccountScreen({super.key, this.api = const AccountApi()});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _invite = TextEditingController();
  final _code = TextEditingController();
  _Mode _mode = _Mode.signIn;
  bool _busy = false;
  String? _error;
  String? _info;
  StreamSubscription<Object?>? _sub;

  AccountApi get api => widget.api;

  @override
  void initState() {
    super.initState();
    _sub = api.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    for (final c in [_email, _password, _invite, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  void _go(_Mode mode, {String? info}) => setState(() {
        _mode = mode;
        _error = null;
        _info = info;
        _code.clear();
        _password.clear();
      });

  Future<void> _run(Future<void> Function() action, {_Mode? next, String? info}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      if (next != null) _go(next, info: info);
    } on AccountException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _check({bool password = false, bool code = false}) {
    final email = _email.text.trim();
    if (!email.contains('@') || !email.contains('.')) return 'Bitte eine gültige E-Mail-Adresse eingeben.';
    if (password && _password.text.length < 8) return 'Das Passwort braucht mindestens 8 Zeichen.';
    if (code && !RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) return 'Bitte den 6-stelligen Code aus der Mail eingeben.';
    return null;
  }

  void _submit() {
    final email = _email.text;
    switch (_mode) {
      case _Mode.signIn:
        final problem = _check();
        if (problem != null || _password.text.isEmpty) {
          setState(() => _error = problem ?? 'Bitte das Passwort eingeben.');
          return;
        }
        _run(() async {
          await api.signIn(email, _password.text);
          unawaited(SupabaseService.touchLastSeen());
        });
      case _Mode.signUp:
        final problem = _check(password: true);
        if (problem != null) return setState(() => _error = problem);
        _run(() => api.signUp(email, _password.text, _invite.text),
            next: _Mode.confirm,
            info: 'Wir haben dir eine Mail an ${email.trim()} geschickt. Tippe auf den Link darin '
                'und melde dich danach hier an. Steht ein Code in der Mail, gib ihn hier ein.');
      case _Mode.confirm:
        if (_code.text.trim().isEmpty) {
          return _go(_Mode.signIn, info: 'Nach dem Bestätigen hier mit E-Mail und Passwort anmelden.');
        }
        final problem = _check(code: true);
        if (problem != null) return setState(() => _error = problem);
        _run(() => api.confirmSignUp(email, _code.text));
      case _Mode.forgot:
        final problem = _check();
        if (problem != null) return setState(() => _error = problem);
        _run(() => api.requestPasswordReset(email),
            next: _Mode.reset,
            info: 'Falls es ein Konto gibt, kommt gleich eine Mail an ${email.trim()}. Tippe auf den Link, '
                'setze dort ein neues Passwort und melde dich danach hier an. '
                'Steht ein Code in der Mail, gib ihn hier ein.');
      case _Mode.reset:
        if (_code.text.trim().isEmpty) {
          return setState(() => _error = 'Ohne Code: bitte den Link in der Mail antippen.');
        }
        final problem = _check(password: true, code: true);
        if (problem != null) return setState(() => _error = problem);
        _run(() => api.resetPassword(email, _code.text, _password.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(api.isSignedIn ? 'Konto' : _title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.l),
          children: api.isSignedIn ? _signedIn() : _form(),
        ),
      ),
    );
  }

  String get _title => switch (_mode) {
        _Mode.signIn => 'Anmelden',
        _Mode.signUp => 'Registrieren',
        _Mode.confirm => 'E-Mail bestätigen',
        _Mode.forgot || _Mode.reset => 'Neues Passwort',
      };

  List<Widget> _signedIn() => [
        const Text('Angemeldet als', style: AppText.small),
        const SizedBox(height: AppSpace.xs),
        Text(api.email ?? '', style: AppText.bodyStrong),
        const SizedBox(height: AppSpace.l),
        const Text(
          'Liste, Märkte und Bonpreise liegen vorerst weiter auf diesem Gerät. '
          'Gemeinsame Listen im Haushalt folgen.',
          style: AppText.small,
        ),
        const SizedBox(height: AppSpace.xl),
        OutlinedButton(
          onPressed: _busy ? null : () => _run(api.signOut, next: _Mode.signIn),
          child: const Text('Abmelden'),
        ),
      ];

  List<Widget> _form() {
    final m = _mode;
    final needsPassword = m == _Mode.signIn || m == _Mode.signUp || m == _Mode.reset;
    final needsCode = m == _Mode.confirm || m == _Mode.reset;
    return [
      if (_info != null) ...[
        _Note(text: _info!, color: AppColors.infoSoft, ink: AppColors.info),
        const SizedBox(height: AppSpace.l),
      ],
      if (m == _Mode.signUp) ...[
        const Text(
          'Registrieren geht mit einem Einladungscode aus einem bestehenden Haushalt '
          'oder mit einer freigeschalteten Adresse.',
          style: AppText.small,
        ),
        const SizedBox(height: AppSpace.l),
      ],
      TextField(
        key: const Key('account_email'),
        controller: _email,
        enabled: m == _Mode.signIn || m == _Mode.signUp || m == _Mode.forgot,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        autocorrect: false,
        decoration: const InputDecoration(labelText: 'E-Mail'),
      ),
      if (needsCode) ...[
        const SizedBox(height: AppSpace.m),
        TextField(
          key: const Key('account_code'),
          controller: _code,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'Code aus der Mail (falls vorhanden)', counterText: ''),
        ),
      ],
      if (needsPassword) ...[
        const SizedBox(height: AppSpace.m),
        TextField(
          key: const Key('account_password'),
          controller: _password,
          obscureText: true,
          autofillHints: [m == _Mode.signIn ? AutofillHints.password : AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: m == _Mode.signIn ? 'Passwort' : 'Neues Passwort',
            helperText: m == _Mode.signIn ? null : 'Mindestens 8 Zeichen',
          ),
          onSubmitted: (_) => _submit(),
        ),
      ],
      if (m == _Mode.signUp) ...[
        const SizedBox(height: AppSpace.m),
        TextField(
          key: const Key('account_invite'),
          controller: _invite,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          decoration: const InputDecoration(labelText: 'Einladungscode (falls vorhanden)', hintText: 'XXXX-XXXX-XXXX-XXXX'),
        ),
      ],
      if (_error != null) ...[
        const SizedBox(height: AppSpace.l),
        _Note(text: _error!, color: AppColors.dangerSoft, ink: AppColors.danger),
      ],
      const SizedBox(height: AppSpace.xl),
      FilledButton(
        key: const Key('account_submit'),
        onPressed: _busy ? null : _submit,
        child: _busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(switch (m) {
                _Mode.signIn => 'Anmelden',
                _Mode.signUp => 'Konto anlegen',
                _Mode.confirm => 'Weiter',
                _Mode.forgot => 'Code schicken',
                _Mode.reset => 'Passwort speichern',
              }),
      ),
      const SizedBox(height: AppSpace.m),
      ..._links(m),
    ];
  }

  List<Widget> _links(_Mode m) {
    Widget link(String label, VoidCallback onTap) =>
        TextButton(onPressed: _busy ? null : onTap, child: Text(label));
    return switch (m) {
      _Mode.signIn => [
          link('Neu hier? Registrieren', () => _go(_Mode.signUp)),
          link('Passwort vergessen', () => _go(_Mode.forgot)),
        ],
      _Mode.signUp => [link('Schon ein Konto? Anmelden', () => _go(_Mode.signIn))],
      _Mode.confirm => [
          link('Code erneut schicken', () => _run(() => api.resendSignUpCode(_email.text),
              next: _Mode.confirm, info: 'Neuer Code ist unterwegs.')),
          link('Zurück zur Anmeldung', () => _go(_Mode.signIn)),
        ],
      _Mode.forgot || _Mode.reset => [link('Zurück zur Anmeldung', () => _go(_Mode.signIn))],
    };
  }
}

/// Nach dem Link "Passwort zurücksetzen": Die App ist mit einer
/// Wiederherstellungs-Sitzung offen und fragt nur das neue Passwort ab.
class NewPasswordScreen extends StatefulWidget {
  final AccountApi api;
  const NewPasswordScreen({super.key, this.api = const AccountApi()});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _password = TextEditingController();
  bool _busy = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_password.text.length < 8) {
      setState(() => _error = 'Das Passwort braucht mindestens 8 Zeichen.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.updatePassword(_password.text);
      if (mounted) setState(() => _done = true);
    } on AccountException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Passwort')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.l),
          children: _done
              ? [
                  const _Note(
                    text: 'Gespeichert. Du kannst dich jetzt überall mit dem neuen Passwort anmelden, '
                        'auch in der App auf dem Home-Bildschirm.',
                    color: AppColors.primaryFaint,
                    ink: AppColors.primaryDark,
                  ),
                  const SizedBox(height: AppSpace.xl),
                  FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Fertig')),
                ]
              : [
                  TextField(
                    key: const Key('new_password'),
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(labelText: 'Neues Passwort', helperText: 'Mindestens 8 Zeichen'),
                    onSubmitted: (_) => _save(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpace.l),
                    _Note(text: _error!, color: AppColors.dangerSoft, ink: AppColors.danger),
                  ],
                  const SizedBox(height: AppSpace.xl),
                  FilledButton(
                    key: const Key('new_password_save'),
                    onPressed: _busy ? null : _save,
                    child: const Text('Passwort speichern'),
                  ),
                ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;
  final Color color;
  final Color ink;
  const _Note({required this.text, required this.color, required this.ink});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpace.m),
        decoration: BoxDecoration(color: color, borderRadius: AppRadius.medium),
        child: Text(text, style: AppText.small.copyWith(color: ink)),
      );
}
