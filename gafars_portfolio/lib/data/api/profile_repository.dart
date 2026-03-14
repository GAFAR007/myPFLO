import 'models/site_profile.dart';
import 'api_client.dart';

class ProfileRepository {
  final ApiClient _client = ApiClient.instance;

  Future<SiteProfile?> fetchProfile() async {
    final response = await _client.getJson('/api/profile');
    final rawProfile = response['profile'];
    if (rawProfile == null) {
      return null;
    }
    return SiteProfile.fromMap(rawProfile as Map<String, dynamic>);
  }

  Future<void> upsertProfile(SiteProfile profile) async {
    await _client.putJson('/api/profile', body: profile.toMap());
  }

  Future<void> updateFields(Map<String, dynamic> fields) async {
    await _client.putJson('/api/profile', body: _normalizePatch(fields));
  }

  Map<String, dynamic> _normalizePatch(Map<String, dynamic> fields) {
    final normalized = <String, dynamic>{};

    fields.forEach((key, value) {
      normalized[_fieldMap[key] ?? key] = value;
    });

    return normalized;
  }

  static const Map<String, String> _fieldMap = {
    'full_name': 'fullName',
    'about_md': 'aboutMd',
    'phone_e164': 'phoneE164',
    'cv_url': 'cvUrl',
    'avatar_url': 'avatarUrl',
    'first_name': 'firstName',
    'middle_name': 'middleName',
    'last_name': 'lastName',
    'date_of_birth': 'dateOfBirth',
  };
}
