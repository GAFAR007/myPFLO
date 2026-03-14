import 'api_client.dart';

class AdminSession {
  const AdminSession({required this.id, required this.email});

  final String id;
  final String email;

  factory AdminSession.fromMap(Map<String, dynamic> map) {
    return AdminSession(
      id: (map['id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
    );
  }
}

class AuthRepository {
  final ApiClient _client = ApiClient.instance;

  Future<AdminSession?> fetchCurrentAdmin() async {
    try {
      final response = await _client.getJson('/api/auth/me');
      final rawAdmin = response['admin'];
      if (rawAdmin is! Map<String, dynamic>) {
        return null;
      }
      return AdminSession.fromMap(rawAdmin);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    await _client.postJson(
      '/api/auth/login',
      body: {'email': email.trim(), 'password': password},
    );
  }

  Future<void> logout() async {
    await _client.postJson('/api/auth/logout');
  }
}
