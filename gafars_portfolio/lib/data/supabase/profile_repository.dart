// lib/data/supabase/profile_repository.dart
//
// Handles reading/writing the `site_profile` table.

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';
import 'models/site_profile.dart';

class ProfileRepository {
  ProfileRepository() {
    // Make sure env vars exist – fails early in dev instead of random errors.
    Supa.assertConfigured();
  }

  // ✅ Use our shared Supa.client (no Supabase.instance here).
  SupabaseClient get _client => Supa.client;

  /// Fetch the profile row (or null if none exists yet).
  Future<SiteProfile?> fetchProfile() async {
    final res = await _client.from('site_profile').select().maybeSingle();

    if (res == null) return null;
    return SiteProfile.fromMap(res);
  }

  /// Insert or update the profile.
  Future<void> upsertProfile(SiteProfile profile) async {
    await _client.from('site_profile').upsert(profile.toMap());
  }
}
