// app/lib/features/household/household_screen.dart
//
// Haushalt wählen (Titel der Liste), Gruppe anlegen, Code eingeben,
// verwalten: Mitglieder, Einladen als Mitglied oder Mit-Owner, Rollen,
// Entfernen, Austreten, eigener Name.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/household_service.dart';
import '../../core/services/share/share.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

/// Titel der Einkaufsliste: mit Haushalt darunter, antippen zum Wechseln.
class HouseholdTitle extends ConsumerWidget {
  final String title;
  const HouseholdTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(householdProvider);
    final current = state.current;
    // Ohne Konto keine Haushalte. Angemeldet ohne Haushalt: trotzdem antippbar
    if (!ref.read(householdApiProvider).available || (current == null && state.loading)) return Text(title);
    final subtitle = current?.name ?? 'Kein Haushalt';
    return InkWell(
      key: const Key('household_title'),
      borderRadius: AppRadius.small,
      onTap: () => showHouseholdSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(child: Text(subtitle, style: AppText.small, overflow: TextOverflow.ellipsis)),
              const Icon(Icons.expand_more, size: 18, color: AppColors.inkMuted),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Auswahl: Haushalte, neue Gruppe, Code eingeben, verwalten.
Future<void> showHouseholdSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _HouseholdSheet(),
    );

class _HouseholdSheet extends ConsumerWidget {
  const _HouseholdSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(householdProvider);
    final ctrl = ref.read(householdProvider.notifier);
    final current = state.current;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppSpace.l),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.s),
            child: Text('Liste von', style: AppText.section),
          ),
          for (final h in state.households)
            ListTile(
              key: Key('household_${h.id}'),
              leading: Icon(h.id == current?.id ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: h.id == current?.id ? AppColors.primary : AppColors.inkSubtle),
              title: Text(h.name),
              subtitle: h.isOwner ? null : const Text('Mitglied'),
              trailing: IconButton(
                tooltip: 'Verwalten',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HouseholdScreen(householdId: h.id)));
                },
              ),
              onTap: () {
                ctrl.select(h.id);
                Navigator.pop(context);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Neue Gruppe'),
            onTap: () async {
              final name = await askText(context, title: 'Neue Gruppe', label: 'Name', hint: 'z. B. Eltern, WG, Grillabend');
              if (name == null || !context.mounted) return;
              await _guarded(context, () => ctrl.create(name));
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: const Text('Einladungscode eingeben'),
            onTap: () async {
              final code = await askText(context,
                  title: 'Einladungscode', label: 'Code', hint: 'XXXX-XXXX-XXXX-XXXX', caps: true);
              if (code == null || !context.mounted) return;
              await _guarded(context, () async {
                final ok = await ctrl.join(code);
                if (!context.mounted) return;
                if (!ok) {
                  _snack(context, 'Der Code ist ungültig, abgelaufen oder schon benutzt.');
                } else {
                  Navigator.pop(context);
                  _snack(context, 'Beigetreten.');
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class HouseholdScreen extends ConsumerStatefulWidget {
  final String householdId;
  const HouseholdScreen({super.key, required this.householdId});

  @override
  ConsumerState<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends ConsumerState<HouseholdScreen> {
  List<HouseholdMember>? _members;
  String? _myName;
  String? _error;

  HouseholdApi get _api => ref.read(householdApiProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final members = await _api.members(widget.householdId);
      final name = await _api.myName();
      if (mounted) {
        setState(() {
          _members = members;
          _myName = name;
          _error = null;
        });
      }
    } on AccountException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Household? get _household {
    for (final h in ref.watch(householdProvider).households) {
      if (h.id == widget.householdId) return h;
    }
    return null;
  }

  Future<void> _invite(HouseholdRole role) async {
    await _guarded(context, () async {
      final code = await _api.invite(widget.householdId, role);
      if (mounted) await showInviteCode(context, code: code, household: _household?.name ?? '', role: role);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = _household;
    if (h == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Nicht mehr in diesem Haushalt.')));
    }
    final members = _members;
    final ctrl = ref.read(householdProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(h.name), actions: [
        if (h.isOwner)
          IconButton(
            tooltip: 'Umbenennen',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final name = await askText(context, title: 'Umbenennen', label: 'Name', initial: h.name);
              if (name == null || !context.mounted) return;
              await _guarded(context, () async {
                await _api.rename(h.id, name);
                await ctrl.refresh();
              });
            },
          ),
      ]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.l),
          children: [
            if (_error != null) Text(_error!, style: AppText.small.copyWith(color: AppColors.danger)),
            const Text('Mitglieder', style: AppText.section),
            const SizedBox(height: AppSpace.s),
            if (members == null)
              const Padding(padding: EdgeInsets.all(AppSpace.l), child: Center(child: CircularProgressIndicator()))
            else
              Card(
                child: Column(children: [
                  for (final m in members) _memberTile(h, m),
                ]),
              ),
            if (h.isOwner) ...[
              const SizedBox(height: AppSpace.xl),
              const Text('Einladen', style: AppText.section),
              const SizedBox(height: AppSpace.xs),
              const Text(
                'Der Code gilt 7 Tage für eine Person. Neue Leute registrieren sich damit, '
                'wer schon ein Konto hat, gibt ihn unter "Einladungscode eingeben" ein.',
                style: AppText.small,
              ),
              const SizedBox(height: AppSpace.m),
              FilledButton(
                key: const Key('invite_member'),
                onPressed: () => _invite(HouseholdRole.member),
                child: const Text('Als Mitglied einladen'),
              ),
              const SizedBox(height: AppSpace.s),
              OutlinedButton(
                key: const Key('invite_owner'),
                onPressed: () => _invite(HouseholdRole.owner),
                child: const Text('Mit gleichen Rechten einladen'),
              ),
            ],
            const SizedBox(height: AppSpace.xl),
            const Text('Du', style: AppText.section),
            const SizedBox(height: AppSpace.s),
            Card(
              child: Column(children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text((_myName ?? '').isEmpty ? 'Name festlegen' : _myName!),
                  subtitle: const Text('So sehen dich die anderen'),
                  onTap: () async {
                    final name = await askText(context, title: 'Dein Name', label: 'Name', initial: _myName ?? '');
                    if (name == null || !context.mounted) return;
                    await _guarded(context, () async {
                      await _api.setMyName(name);
                      await _load();
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  key: const Key('household_leave'),
                  leading: const Icon(Icons.logout, color: AppColors.danger),
                  title: const Text('Austreten', style: TextStyle(color: AppColors.danger)),
                  subtitle: Text(members != null && members.length == 1
                      ? 'Du bist allein, der Haushalt und seine Liste werden gelöscht'
                      : 'Die Liste bleibt für die anderen'),
                  onTap: () async {
                    final alone = members != null && members.length == 1;
                    final ok = await confirm(context,
                        title: '${h.name} verlassen?',
                        text: alone
                            ? 'Du bist das einzige Mitglied. Der Haushalt und seine Liste werden gelöscht.'
                            : 'Du siehst die Liste danach nicht mehr. Zurück geht es nur mit einem neuen Code.',
                        action: 'Austreten');
                    if (!ok || !context.mounted) return;
                    await _guarded(context, () async {
                      await ctrl.leave(h.id);
                      if (context.mounted) Navigator.pop(context);
                    });
                  },
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberTile(Household h, HouseholdMember m) {
    final label = m.isMe ? 'Du' : (m.name.isEmpty ? 'Ohne Namen' : m.name);
    final canManage = h.isOwner && !m.isMe;
    return ListTile(
      title: Text(m.isMe && m.name.isNotEmpty ? '${m.name} (du)' : label),
      subtitle: Text(m.isOwner ? 'Owner' : 'Mitglied'),
      trailing: canManage
          ? PopupMenuButton<String>(
              tooltip: 'Mehr',
              onSelected: (action) async {
                await _guarded(context, () async {
                  switch (action) {
                    case 'owner':
                      await _api.setRole(h.id, m.userId, HouseholdRole.owner);
                    case 'member':
                      await _api.setRole(h.id, m.userId, HouseholdRole.member);
                    case 'remove':
                      final ok = await confirm(context,
                          title: '$label entfernen?',
                          text: 'Die Person sieht die Liste danach nicht mehr.',
                          action: 'Entfernen');
                      if (!ok) return;
                      await _api.remove(h.id, m.userId);
                  }
                  await _load();
                });
              },
              itemBuilder: (_) => [
                if (m.isOwner)
                  const PopupMenuItem(value: 'member', child: Text('Zum Mitglied machen'))
                else
                  const PopupMenuItem(value: 'owner', child: Text('Gleiche Rechte geben (Owner)')),
                const PopupMenuItem(value: 'remove', child: Text('Entfernen')),
              ],
            )
          : null,
    );
  }
}

/// Zeigt den neuen Code einmal an, mit Teilen und Kopieren.
Future<void> showInviteCode(BuildContext context,
    {required String code, required String household, required HouseholdRole role}) {
  final text = 'Einladung zu "$household" im Einkaufs-Optimierer. '
      'Code: $code (7 Tage gültig). '
      'App: https://magnusevh.github.io/einkaufs-optimierer/ → Profil → Anmelden → Registrieren, '
      'oder mit Konto: Liste → Haushalt → Einladungscode eingeben.';
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Einladungscode'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        SelectableText(code, key: const Key('invite_code'), style: AppText.figure.copyWith(fontSize: 22)),
        const SizedBox(height: AppSpace.m),
        Text(
          role == HouseholdRole.owner
              ? 'Gilt für eine Person, mit gleichen Rechten wie du. Nur jetzt sichtbar.'
              : 'Gilt für eine Person als Mitglied. Nur jetzt sichtbar.',
          style: AppText.small,
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: text));
            if (ctx.mounted) _snack(ctx, 'Kopiert.');
          },
          child: const Text('Kopieren'),
        ),
        FilledButton(
          onPressed: () async {
            final shared = await shareText(text);
            if (!shared) {
              await Clipboard.setData(ClipboardData(text: text));
              if (ctx.mounted) _snack(ctx, 'Kopiert. Jetzt in eine Nachricht einfügen.');
            }
          },
          child: const Text('Teilen'),
        ),
      ],
    ),
  );
}

Future<String?> askText(BuildContext context,
    {required String title, required String label, String? hint, String initial = '', bool caps = false}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        key: const Key('ask_text'),
        controller: controller,
        autofocus: true,
        maxLength: 60,
        textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label, hintText: hint, counterText: ''),
        onSubmitted: (v) => Navigator.pop(ctx, v.trim().isEmpty ? null : v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
        FilledButton(
          key: const Key('ask_ok'),
          onPressed: () => Navigator.pop(ctx, controller.text.trim().isEmpty ? null : controller.text.trim()),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<bool> confirm(BuildContext context, {required String title, required String text, required String action}) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

Future<void> _guarded(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } on AccountException catch (e) {
    if (context.mounted) _snack(context, e.message);
  }
}

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
