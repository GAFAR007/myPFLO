class SiteProfile {
  const SiteProfile({
    required this.id,
    required this.fullName,
    required this.title,
    required this.email,
    this.tagline,
    this.aboutMd,
    this.phoneE164,
    this.phone,
    this.linkedin,
    this.cvUrl,
    this.github,
    this.twitter,
    this.website,
    this.location,
    this.avatarUrl,
    this.firstName,
    this.middleName,
    this.lastName,
    this.dateOfBirth,
  });

  final String id;
  final String fullName;
  final String title;
  final String email;
  final String? tagline;
  final String? aboutMd;
  final String? phoneE164;
  final String? phone;
  final String? linkedin;
  final String? cvUrl;
  final String? github;
  final String? twitter;
  final String? website;
  final String? location;
  final String? avatarUrl;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final DateTime? dateOfBirth;

  factory SiteProfile.fromMap(Map<String, dynamic> map) {
    final dobValue = map['dateOfBirth'] ?? map['date_of_birth'];

    return SiteProfile(
      id: (map['id'] ?? '').toString(),
      fullName: (map['fullName'] ?? map['full_name'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      tagline: _toNullableString(map['tagline']),
      aboutMd: _toNullableString(map['aboutMd'] ?? map['about_md']),
      phoneE164: _toNullableString(map['phoneE164'] ?? map['phone_e164']),
      phone: _toNullableString(map['phone']),
      linkedin: _toNullableString(map['linkedin']),
      cvUrl: _toNullableString(map['cvUrl'] ?? map['cv_url']),
      github: _toNullableString(map['github']),
      twitter: _toNullableString(map['twitter']),
      website: _toNullableString(map['website']),
      location: _toNullableString(map['location']),
      avatarUrl: _toNullableString(map['avatarUrl'] ?? map['avatar_url']),
      firstName: _toNullableString(map['firstName'] ?? map['first_name']),
      middleName: _toNullableString(map['middleName'] ?? map['middle_name']),
      lastName: _toNullableString(map['lastName'] ?? map['last_name']),
      dateOfBirth: _parseDate(dobValue),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'title': title,
      'email': email,
      'tagline': tagline,
      'aboutMd': aboutMd,
      'phoneE164': phoneE164,
      'phone': phone,
      'linkedin': linkedin,
      'cvUrl': cvUrl,
      'github': github,
      'twitter': twitter,
      'website': website,
      'location': location,
      'avatarUrl': avatarUrl,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    }..removeWhere((_, value) => value == null);
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}
