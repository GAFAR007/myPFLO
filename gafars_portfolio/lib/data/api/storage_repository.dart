import 'dart:typed_data';

import 'api_client.dart';

class StorageRepository {
  final ApiClient _client = ApiClient.instance;

  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final response = await _client.uploadFile(
      '/api/uploads/avatar',
      bytes: bytes,
      fileName: fileName,
    );
    return (response['url'] ?? '').toString();
  }

  Future<String> uploadCv({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final response = await _client.uploadFile(
      '/api/uploads/cv',
      bytes: bytes,
      fileName: fileName,
    );
    return (response['url'] ?? '').toString();
  }
}
