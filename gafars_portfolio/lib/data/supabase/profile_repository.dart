// lib/data/supabase/profile_repository.dart
// Thin data layer that talks to Supabase for the `site_profile` table.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';
import 'models/site_profile.dart';

class ProfileRepository {
  static const _table = 'site_profile';
  final SupabaseClient _db = Supa.client;

  // Insert or update the single profile row, then return it.
  Future<SiteProfile> upsertProfile(SiteProfile p) async {
    // Force the expected type so the analyzer is happy.
    final List<Map<String, dynamic>> rows = await _db
        .from(_table)
        .upsert(p.toMap())
        .select();

    if (rows.isEmpty) {
      throw Exception('Upsert failed: no row returned.');
    }
    return SiteProfile.fromMap(rows.first);
  }

  // Read the first (only) profile row; returns null if none.
  Future<SiteProfile?> fetchProfile() async {
    final List<Map<String, dynamic>> rows = await _db
        .from(_table)
        .select()
        .limit(1);

    if (rows.isEmpty) return null;
    return SiteProfile.fromMap(rows.first);
  }
}
