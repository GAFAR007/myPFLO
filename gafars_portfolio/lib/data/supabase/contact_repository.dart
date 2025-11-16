// lib/data/supabase/contact_repository.dart
//
// ContactRepository
// -----------------
// Inserts "Hire Me" messages into Supabase using separate
// firstName + lastName fields.
//
// Make sure your Supabase table (e.g. `contact_messages`) has:
//
//   - id          uuid, primary key, default gen_random_uuid()
//   - first_name  text
//   - last_name   text
//   - email       text
//   - message     text
//   - created_at  timestamptz, default now()
//
// If your table name or column names are different,
// update _tableName and the payload keys below.

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactRepository {
  ContactRepository()
    : _client = SupabaseClient(
        const String.fromEnvironment('SUPABASE_URL'),
        const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

  final SupabaseClient _client;

  // Change this if your table name is different
  static const String _tableName = 'contact_messages';

  Future<void> submitContact({
    required String firstName,
    required String lastName,
    required String email,
    required String message,
  }) async {
    final payload = {
      // 👇 these keys MUST match your Supabase column names
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'message': message,
    };

    debugPrint('------ [ContactRepository.submitContact] ------');
    debugPrint('Table   : $_tableName');
    debugPrint('Payload : $payload');
    debugPrint('------------------------------------------------');

    await _client.from(_tableName).insert(payload);
  }
}
