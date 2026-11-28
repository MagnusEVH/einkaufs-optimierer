import 'package:flutter_test/flutter_test.dart';
import 'package:einkaufs_optimierer/core/services/supabase_service.dart';

void main() {
  test('Reset-Link wird an der Adresse erkannt', () {
    expect(SupabaseService.isRecoveryLink(Uri.parse('https://x.io/app/#access_token=a&type=recovery')), isTrue);
    expect(SupabaseService.isRecoveryLink(Uri.parse('https://x.io/app/?type=recovery')), isTrue);
    expect(SupabaseService.isRecoveryLink(Uri.parse('https://x.io/app/#access_token=a&type=signup')), isFalse);
    expect(SupabaseService.isRecoveryLink(Uri.parse('https://x.io/app/')), isFalse);
  });
}
