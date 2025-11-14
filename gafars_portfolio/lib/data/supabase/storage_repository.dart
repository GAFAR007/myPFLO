// lib/data/supabase/storage_repository.dart
//
// Uploads avatar + CV to Supabase Storage and returns public URLs.

import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'supabase_client.dart';

class StorageRepository {
  StorageRepository() {
    // Ensure SUPABASE_URL + SUPABASE_ANON_KEY are set.
    Supa.assertConfigured();
  }

  // ✅ Shared client from Supa – still no Supabase.instance.
  SupabaseClient get _client => Supa.client;

  final _uuid = const Uuid();

  // Name of your public bucket in Supabase Storage
  // 👇 MUST match the bucket_id you see under Storage → Buckets.
  static const String bucketName = 'portfolio'; // <--- changed this

  /// Upload avatar and return public URL.
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) {
    return _uploadFile(
      bytes: bytes,
      fileName: fileName,
      folder: 'avatars',
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
    );
  }

  /// Upload CV and return public URL.
  Future<String> uploadCv({
    required Uint8List bytes,
    required String fileName,
  }) {
    return _uploadFile(
      bytes: bytes,
      fileName: fileName,
      folder: 'cvs',
      allowedExtensions: const ['pdf', 'doc', 'docx'],
    );
  }

  /// Shared internal upload helper.
  Future<String> _uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String folder,
    required List<String> allowedExtensions,
  }) async {
    // Basic extension validation for nicer errors.
    final parts = fileName.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : '';

    if (!allowedExtensions.contains(ext)) {
      throw Exception(
        'Invalid file type ".$ext". Allowed: ${allowedExtensions.join(', ')}',
      );
    }

    // Unique path inside bucket: e.g. "avatars/<uuid>.png"
    final uniqueName = '${_uuid.v4()}.$ext';
    final path = '$folder/$uniqueName';

    try {
      // Upload raw bytes to Supabase Storage
      await _client.storage.from(bucketName).uploadBinary(path, bytes);

      // Build public URL so we can load it on the site later
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(path);

      return publicUrl;
    } on StorageException catch (e) {
      // Supabase-specific errors
      // ignore: avoid_print
      print('[StorageRepository] StorageException: ${e.message}');
      throw Exception('Supabase storage error: ${e.message}');
    } catch (e) {
      // ignore: avoid_print
      print('[StorageRepository] Unknown error: $e');
      throw Exception('Unexpected upload error: $e');
    }
  }
}
