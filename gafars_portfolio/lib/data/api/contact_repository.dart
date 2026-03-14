import 'api_client.dart';

class ContactRepository {
  final ApiClient _client = ApiClient.instance;

  Future<void> submitContact({
    required String firstName,
    required String lastName,
    required String email,
    required String message,
    String? subject,
  }) async {
    await _client.postJson(
      '/api/contact',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'message': message,
        'subject': subject,
      }..removeWhere((_, value) => value == null),
    );
  }
}
