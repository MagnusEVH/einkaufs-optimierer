// Text über das Teilen-Menü des Geräts senden (im Browser: Web Share API,
// auf dem iPhone das bekannte Menü mit Nachrichten, WhatsApp, Mail ...).
// Ohne Teilen-Menü (Desktop-Browser, Tests) kopiert der Aufrufer in die
// Zwischenablage.

export 'share_stub.dart' if (dart.library.js_interop) 'share_web.dart';
