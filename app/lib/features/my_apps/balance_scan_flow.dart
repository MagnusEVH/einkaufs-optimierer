// app/lib/features/my_apps/balance_scan_flow.dart
//
// "Stand scannen": Screenshot aus den Fotos wählen, Stand wird erkannt und
// sofort gespeichert. Kein Zwischenschritt, keine Extra-Seite.

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/balance_scanner.dart';
import '../../core/services/loyalty_service.dart';
import '../../core/theme/app_theme.dart';

Future<void> scanBalanceFlow(BuildContext context, LoyaltyProgram program) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!BalanceScanner.isSupported) {
    messenger.showSnackBar(const SnackBar(content: Text('Der Scan geht nur in der Web-App.')));
    return;
  }
  final file = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (file == null || !context.mounted) return;

  // Fortschritt, solange die Texterkennung läuft
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(children: [
        SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
        SizedBox(width: AppSpace.l),
        Expanded(child: Text('Lese den Stand …')),
      ]),
    ),
  );

  BalanceImport? result;
  String? error;
  try {
    result = await BalanceScanner.scan(file.path, program);
    if (result != null) await LoyaltyService.saveBalance(result);
  } catch (e) {
    error = e.toString().replaceAll('Exception: ', '').replaceAll('Error: ', '');
  }
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();

  if (result != null) {
    final value = result.valueCents != null ? '${euro(result.valueCents!)} Guthaben' : '${result.points} Punkte';
    messenger.showSnackBar(SnackBar(content: Text('${program.name}: $value gespeichert')));
  } else {
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 6),
      content: Text(error ?? 'Kein Stand erkannt. Bitte einen Screenshot wählen, auf dem ${program.balanceKind == 'points' ? 'der Punktestand' : 'das Guthaben'} gut lesbar ist.'),
    ));
  }
}
