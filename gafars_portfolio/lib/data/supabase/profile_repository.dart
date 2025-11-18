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

  /// Insert or update the profile (full row).
  Future<void> upsertProfile(SiteProfile profile) async {
    await _client.from('site_profile').upsert(profile.toMap());
  }

  /// ✅ Partial update: updates ONLY specific fields on the existing row.
  ///
  /// - Reads the existing row to get the REAL `id` from Supabase (UUID).
  /// - If there is no row yet, it inserts a new one with just these fields.
  Future<void> updateFields(Map<String, dynamic> fields) async {
    // First, get whatever row already exists in site_profile.
    final existing = await _client
        .from('site_profile')
        .select('id')
        .maybeSingle();

    if (existing == null) {
      // No row yet → create one with these fields.
      // (Supabase will generate a UUID for `id`.)
      print('[ProfileRepository] No profile row yet – inserting new row.');
      await _client.from('site_profile').insert(fields);
      return;
    }

    final String id = existing['id'] as String;
    print('[ProfileRepository] Updating site_profile row with id=$id');
    print('[ProfileRepository] Fields: $fields');

    await _client.from('site_profile').update(fields).eq('id', id);
  }
}
