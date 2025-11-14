// lib/data/supabase/supabase_client.dart
//
// Single shared Supabase client for the whole app.
// Uses anon key only (safe for client-side apps).

import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  // Values passed from the Flutter command line at runtime:
  //
  // flutter run -d chrome \
  //   --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  //   --dart-define=SUPABASE_ANON_KEY="YOUR_PUBLIC_ANON_KEY"
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anon = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Lazily-created client we can import anywhere.
  // NOTE: this does NOT use Supabase.instance at all.
  static final SupabaseClient client = SupabaseClient(url, anon);

  // Helpful dev check so we get a clear error if env vars are missing.
  static void assertConfigured() {
    if (url.isEmpty || anon.isEmpty) {
      throw StateError(
        'Supabase is not configured.\n'
        'Run the app with --dart-define SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
  }
}
