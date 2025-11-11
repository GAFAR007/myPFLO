// lib/data/supabase/supabase_client.dart
// Single shared Supabase client for the whole app.
//
// 🔐 SECURITY NOTE
// - Use ONLY the PUBLIC "anon" key in Flutter apps.
// - We do NOT hardcode secrets; we read them from --dart-define at runtime.

import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  // Read values passed from the Flutter command line (see "How to use" below).
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anon = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Lazily-created global client you can import anywhere.
  static final SupabaseClient client = SupabaseClient(url, anon);

  // Optional: quick sanity check to help during local dev.
  static void assertConfigured() {
    if (url.isEmpty || anon.isEmpty) {
      throw StateError(
        'Supabase is not configured. '
        'Run the app with --dart-define SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
  }
}
