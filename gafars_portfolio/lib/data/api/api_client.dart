import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'client_factory.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _client = createHttpClient();

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _client.get(_uri(path), headers: _jsonHeaders);
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.post(
      _uri(path),
      headers: _jsonHeaders,
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.put(
      _uri(path),
      headers: _jsonHeaders,
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required Uint8List bytes,
    required String fileName,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path))
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _decodeMap(response);
  }

  Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$normalizedPath');
  }

  Map<String, String> get _jsonHeaders => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> _decodeMap(http.Response response) {
    final body = _decodeBody(response);
    if (body is Map<String, dynamic>) {
      return body;
    }

    throw ApiException(
      'Unexpected response payload from the backend.',
      statusCode: response.statusCode,
    );
  }

  dynamic _decodeBody(http.Response response) {
    final hasBody = response.bodyBytes.isNotEmpty;
    final decoded = hasBody ? jsonDecode(utf8.decode(response.bodyBytes)) : {};

    if (response.statusCode >= 400) {
      throw ApiException(
        _extractErrorMessage(decoded, fallback: response.reasonPhrase),
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  String _extractErrorMessage(dynamic decoded, {String? fallback}) {
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'] ?? decoded['message'];
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }
    }

    return fallback?.trim().isNotEmpty == true
        ? fallback!.trim()
        : 'Request failed.';
  }
}
