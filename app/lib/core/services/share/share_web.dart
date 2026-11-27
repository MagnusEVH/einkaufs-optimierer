import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// true, wenn das Teilen-Menü geöffnet wurde (auch wenn abgebrochen).
Future<bool> shareText(String text) async {
  final data = web.ShareData(text: text);
  try {
    if (!web.window.navigator.canShare(data)) return false;
    await web.window.navigator.share(data).toDart;
    return true;
  } catch (e) {
    // AbortError = abgebrochen: Menü war da, nichts weiter tun
    return e.toString().contains('AbortError');
  }
}
