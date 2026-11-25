// Brücke zu web/konto/scan.js (window.eoScanBalance).

import 'dart:js_interop';

@JS('eoScanBalance')
external JSPromise<JSString?> _eoScanBalance(JSString imageUrl, JSString kind);

const bool isSupported = true;

Future<String?> scanImage(String imageUrl, String kind) async {
  final result = await _eoScanBalance(imageUrl.toJS, kind.toJS).toDart;
  return result?.toDart;
}
