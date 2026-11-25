// Ohne Browser (Tests, native Builds): kein Scan.

const bool isSupported = false;

Future<String?> scanImage(String imageUrl, String kind) async =>
    throw UnsupportedError('Guthaben-Scan gibt es nur in der Web-App');
