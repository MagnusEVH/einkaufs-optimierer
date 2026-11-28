// app/lib/features/account/account_screen.dart
//
// Konto: Anmelden, Registrieren (mit Einladungscode), E-Mail bestätigen und
// Passwort zurücksetzen per Code aus der Mail, Abmelden. Die Logik steckt in
// [AuthFlow]; hier nur die Oberfläche. Konto löschen liegt im Profil.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import 'auth_flow.dart';

export 'auth_flow.dart' show AccountApi, AuthStep;

class AccountScreen extends StatefulWidget {
  final AccountApi api;
  final AuthStep start;

  /// Hinweis beim Öffnen, z. B. "Link abgelaufen".
  final String? startMessage;
  const AccountScreen({super.key, this.api = const AccountApi(), this.start = AuthStep.signIn, this.startMessage});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final AuthFlow flow = AuthFlow(api: widget.api, start: widget.start);
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _invite = TextEditingController();
  final _code = TextEditingController();
  bool _showPassword = false;
  String? _doneMessage;
  StreamSubscription<Object?>? _sub;
  Timer? _tick;

  AccountApi get api => widget.api;

  @override
  void initState() {
    super.initState();
    if (widget.startMessage != null) flow.error = widget.startMessage;
    flow.addListener(_onFlow);
    _sub = api.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tick?.cancel();
    flow.removeListener(_onFlow);
    flow.dispose();
    for (final c in [_email, _password, _invite, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onFlow() {
    if (!mounted) return;
    // Zähler "Neuer Code in 0:42" jede Sekunde neu zeichnen
    if (flow.resendIn > 0 && _tick == null) {
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        if (flow.resendIn == 0) {
          _tick?.cancel();
          _tick = null;
        }
      });
    }
    setState(() {});
  }

  void _go(AuthStep step) {
    _code.clear();
    _password.clear();
    flow.goTo(step, email: _email.text.trim().isEmpty ? null : _email.text);
  }

  Future<void> _perform(AuthAction a) async {
    if (a == AuthAction.forgotPassword || a == AuthAction.goSignIn) {
      _password.clear();
      _code.clear();
    }
    await flow.perform(a);
  }

  Future<void> _submit() async {
    var ok = false;
    switch (flow.step) {
      case AuthStep.signIn:
        ok = await flow.signIn(_email.text, _password.text);
        if (ok && api.isSignedIn) unawaited(SupabaseService.touchLastSeen());
      case AuthStep.signUp:
        ok = await flow.signUp(_email.text, _password.text, _invite.text);
      case AuthStep.verifySignup:
        ok = await flow.verifySignup(_code.text);
        if (ok) _doneMessage = 'E-Mail bestätigt. Du bist angemeldet.';
      case AuthStep.forgot:
        ok = await flow.requestReset(_email.text);
        if (ok) _code.clear();
      case AuthStep.resetCode:
        ok = await flow.resetWithCode(_code.text, _password.text);
        if (ok) _doneMessage = 'Neues Passwort gespeichert. Du bist angemeldet.';
      case AuthStep.linkFailed:
        _go(AuthStep.forgot);
        return;
    }
    // Schlüsselbund: E-Mail und Passwort erst nach Erfolg speichern
    if (ok && (flow.step == AuthStep.signUp || flow.step == AuthStep.verifySignup || api.isSignedIn)) {
      TextInput.finishAutofillContext();
    }
    if (ok && flow.step == AuthStep.verifySignup) _code.clear();
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = api.isSignedIn;
    return Scaffold(
      appBar: AppBar(
        title: Text(signedIn ? 'Konto' : _title),
        leading: !signedIn && flow.canGoBack
            ? IconButton(
                key: const Key('account_back'),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Zurück',
                onPressed: flow.busy ? null : flow.back,
              )
            : null,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.l),
          children: signedIn
              ? _signedIn()
              : [AutofillGroup(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _form()))],
        ),
      ),
    );
  }

  String get _title => switch (flow.step) {
        AuthStep.signIn => 'Anmelden',
        AuthStep.signUp => 'Registrieren',
        AuthStep.verifySignup => 'E-Mail bestätigen',
        AuthStep.forgot || AuthStep.resetCode => 'Passwort zurücksetzen',
        AuthStep.linkFailed => 'Link ungültig',
      };

  List<Widget> _signedIn() => [
        if (_doneMessage != null) ...[
          _Note.ok(_doneMessage!),
          const SizedBox(height: AppSpace.l),
        ],
        const Text('Angemeldet als', style: AppText.small),
        const SizedBox(height: AppSpace.xs),
        Text(api.email ?? '', style: AppText.bodyStrong),
        const SizedBox(height: AppSpace.xl),
        if (Navigator.canPop(context)) ...[
          FilledButton(
            key: const Key('account_done'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Fertig'),
          ),
          const SizedBox(height: AppSpace.s),
        ],
        OutlinedButton(
          key: const Key('account_change_password'),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewPasswordScreen(api: api))),
          child: const Text('Passwort ändern'),
        ),
        const SizedBox(height: AppSpace.s),
        OutlinedButton(
          onPressed: () async {
            await api.signOut();
            _doneMessage = null;
            _go(AuthStep.signIn);
          },
          child: const Text('Abmelden'),
        ),
      ];

  List<Widget> _form() {
    final s = flow.step;
    final emailEditable = s == AuthStep.signIn || s == AuthStep.signUp || s == AuthStep.forgot;
    final needsCode = s == AuthStep.verifySignup || s == AuthStep.resetCode;
    final needsPassword = s == AuthStep.signIn || s == AuthStep.signUp || s == AuthStep.resetCode;
    return [
      if (_intro(s) case final intro?) ...[
        Text(intro, style: AppText.small),
        const SizedBox(height: AppSpace.l),
      ],
      if (flow.info != null) ...[
        _Note.info(flow.info!),
        const SizedBox(height: AppSpace.l),
      ],
      if (emailEditable)
        TextField(
          key: const Key('account_email'),
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'E-Mail'),
          onSubmitted: s == AuthStep.forgot ? (_) => _submit() : null,
        )
      else if (s != AuthStep.linkFailed)
        Row(children: [
          Expanded(child: Text(flow.email, style: AppText.bodyStrong)),
          TextButton(
            key: const Key('account_change_email'),
            onPressed: flow.busy ? null : () => _go(s == AuthStep.verifySignup ? AuthStep.signUp : AuthStep.forgot),
            child: const Text('E-Mail ändern'),
          ),
        ]),
      if (needsCode) ...[
        const SizedBox(height: AppSpace.m),
        TextField(
          key: const Key('account_code'),
          controller: _code,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofillHints: const [AutofillHints.oneTimeCode],
          maxLength: 10,
          textInputAction: s == AuthStep.resetCode ? TextInputAction.next : TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Code aus der Mail', counterText: ''),
          onSubmitted: s == AuthStep.verifySignup ? (_) => _submit() : null,
        ),
      ],
      if (needsPassword) ...[
        const SizedBox(height: AppSpace.m),
        TextField(
          key: const Key('account_password'),
          controller: _password,
          obscureText: !_showPassword,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: [s == AuthStep.signIn ? AutofillHints.password : AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: s == AuthStep.signIn ? 'Passwort' : 'Neues Passwort',
            helperText: s == AuthStep.signIn ? null : 'Mindestens 8 Zeichen',
            suffixIcon: IconButton(
              key: const Key('account_show_password'),
              tooltip: _showPassword ? 'Passwort verbergen' : 'Passwort zeigen',
              icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ],
      if (s == AuthStep.signUp) ...[
        const SizedBox(height: AppSpace.m),
        TextField(
          key: const Key('account_invite'),
          controller: _invite,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          decoration:
              const InputDecoration(labelText: 'Einladungscode (falls vorhanden)', hintText: 'XXXX-XXXX-XXXX-XXXX'),
        ),
      ],
      if (flow.error != null) ...[
        const SizedBox(height: AppSpace.l),
        _Note.error(flow.error!),
        for (final a in flow.actions)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.s),
            child: OutlinedButton(
              key: Key('account_action_${a.name}'),
              onPressed: flow.busy || (a == AuthAction.resendCode && !flow.canResend) ? null : () => _perform(a),
              child: Text(_actionLabel(a)),
            ),
          ),
      ],
      const SizedBox(height: AppSpace.xl),
      FilledButton(
        key: const Key('account_submit'),
        onPressed: flow.busy ? null : _submit,
        child: flow.busy
            ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(switch (s) {
                AuthStep.signIn => 'Anmelden',
                AuthStep.signUp => 'Konto anlegen',
                AuthStep.verifySignup => 'Bestätigen',
                AuthStep.forgot => 'Code schicken',
                AuthStep.resetCode => 'Passwort speichern',
                AuthStep.linkFailed => 'Neuen Code anfordern',
              }),
      ),
      const SizedBox(height: AppSpace.m),
      ..._links(s),
    ];
  }

  String? _intro(AuthStep s) => switch (s) {
        AuthStep.signUp => 'Registrieren geht mit einem Einladungscode aus einem bestehenden Haushalt '
            'oder mit einer freigeschalteten Adresse. Danach bekommst du einen Code per Mail.',
        AuthStep.forgot => 'Wir schicken dir einen Code per Mail. Damit setzt du hier in der App ein neues Passwort.',
        AuthStep.linkFailed => 'Kein Problem: Fordere einfach einen Code an und gib ihn hier in der App ein.',
        _ => null,
      };

  String _actionLabel(AuthAction a) => switch (a) {
        AuthAction.forgotPassword => 'Passwort vergessen?',
        AuthAction.goSignIn => 'Zur Anmeldung',
        AuthAction.resendCode => _resendLabel,
        AuthAction.retry => 'Erneut versuchen',
        AuthAction.haveCode => 'Ich habe schon einen Code',
      };

  String get _resendLabel {
    final s = flow.resendIn;
    if (s == 0) return 'Neuen Code schicken';
    return 'Neuen Code schicken (in ${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')})';
  }

  List<Widget> _links(AuthStep s) {
    Widget link(String label, VoidCallback? onTap, {Key? key}) =>
        TextButton(key: key, onPressed: flow.busy ? null : onTap, child: Text(label));
    final resendShown = flow.actions.contains(AuthAction.resendCode);
    return switch (s) {
      AuthStep.signIn => [
          link('Neu hier? Registrieren', () => _go(AuthStep.signUp)),
          link('Passwort vergessen', () => _go(AuthStep.forgot), key: const Key('account_forgot')),
        ],
      AuthStep.signUp => [link('Schon ein Konto? Anmelden', () => _go(AuthStep.signIn))],
      AuthStep.verifySignup || AuthStep.resetCode => [
          if (!resendShown)
            link(_resendLabel, flow.canResend ? flow.resend : null, key: const Key('account_resend')),
          const Text(
            'Keine Mail? Schau im Spam-Ordner nach. Der Code gilt eine Stunde, immer nur der neueste.',
            style: AppText.small,
            textAlign: TextAlign.center,
          ),
          if (s == AuthStep.verifySignup) link('Zur Anmeldung', () => _go(AuthStep.signIn)),
        ],
      AuthStep.forgot => [
          link('Ich habe schon einen Code', () => flow.perform(AuthAction.haveCode),
              key: const Key('account_have_code')),
          link('Zurück zur Anmeldung', () => _go(AuthStep.signIn)),
        ],
      AuthStep.linkFailed => [link('Zur Anmeldung', () => _go(AuthStep.signIn))],
    };
  }
}

/// Neues Passwort, wenn man schon angemeldet ist: über "Passwort ändern" oder
/// nach dem Link aus der Mail. Verlangt der Server zur Sicherheit einen Code,
/// schickt der Bildschirm ihn selbst und fragt ihn hier ab.
class NewPasswordScreen extends StatefulWidget {
  final AccountApi api;
  const NewPasswordScreen({super.key, this.api = const AccountApi()});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _password = TextEditingController();
  final _code = TextEditingController();
  late final _email = TextEditingController(text: widget.api.email ?? '');
  bool _busy = false;
  bool _done = false;
  bool _needsCode = false;
  bool _show = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    for (final c in [_password, _code, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final problem = AuthFlow.checkPassword(_password.text) ?? (_needsCode ? AuthFlow.checkCode(_code.text) : null);
    if (problem != null) return setState(() => _error = problem);
    await _guard(() async {
      if (_needsCode) {
        await widget.api.resetPassword(_email.text, _code.text.trim(), _password.text);
      } else {
        await widget.api.updatePassword(_password.text);
      }
      TextInput.finishAutofillContext(); // Schlüsselbund: unter der E-Mail speichern
      _done = true;
    }, onError: (e) async {
      // Server will einen Nachweis: Code per Mail schicken und hier abfragen
      if (!_needsCode && e.kind == AuthErrorKind.reauthNeeded && _email.text.isNotEmpty) {
        await widget.api.requestPasswordReset(_email.text);
        _needsCode = true;
        _error = null;
        _info = 'Zur Sicherheit brauchen wir einen Code. Er ist an ${_email.text} unterwegs.';
      }
    });
  }

  Future<void> _guard(Future<void> Function() action, {Future<void> Function(AccountException e)? onError}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on AccountException catch (e) {
      _error = e.message;
      try {
        await onError?.call(e);
      } on AccountException catch (e2) {
        _error = e2.message;
      }
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
                  const _Note.ok('Gespeichert. Du kannst dich jetzt überall mit dem neuen Passwort anmelden, '
                      'auch in der App auf dem Home-Bildschirm.'),
                  const SizedBox(height: AppSpace.xl),
                  FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Fertig')),
                ]
              : [
                  if (_info != null) ...[
                    _Note.info(_info!),
                    const SizedBox(height: AppSpace.l),
                  ],
                  AutofillGroup(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      if (_email.text.isNotEmpty) ...[
                        TextField(
                          controller: _email,
                          readOnly: true,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          decoration: const InputDecoration(labelText: 'E-Mail'),
                        ),
                        const SizedBox(height: AppSpace.m),
                      ],
                      if (_needsCode) ...[
                        TextField(
                          key: const Key('new_password_code'),
                          controller: _code,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          autofillHints: const [AutofillHints.oneTimeCode],
                          maxLength: 10,
                          decoration: const InputDecoration(labelText: 'Code aus der Mail', counterText: ''),
                        ),
                        const SizedBox(height: AppSpace.m),
                      ],
                      TextField(
                        key: const Key('new_password'),
                        controller: _password,
                        obscureText: !_show,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          labelText: 'Neues Passwort',
                          helperText: 'Mindestens 8 Zeichen',
                          suffixIcon: IconButton(
                            tooltip: _show ? 'Passwort verbergen' : 'Passwort zeigen',
                            icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setState(() => _show = !_show),
                          ),
                        ),
                        onSubmitted: (_) => _save(),
                      ),
                    ]),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpace.l),
                    _Note.error(_error!),
                  ],
                  const SizedBox(height: AppSpace.xl),
                  FilledButton(
                    key: const Key('new_password_save'),
                    onPressed: _busy ? null : _save,
                    child: const Text('Passwort speichern'),
                  ),
                  const SizedBox(height: AppSpace.m),
                  TextButton(
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    child: const Text('Abbrechen'),
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
  const _Note.info(this.text)
      : color = AppColors.infoSoft,
        ink = AppColors.info;
  const _Note.error(this.text)
      : color = AppColors.dangerSoft,
        ink = AppColors.danger;
  const _Note.ok(this.text)
      : color = AppColors.primaryFaint,
        ink = AppColors.primaryDark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpace.m),
        decoration: BoxDecoration(color: color, borderRadius: AppRadius.medium),
        child: Text(text, style: AppText.small.copyWith(color: ink)),
      );
}
