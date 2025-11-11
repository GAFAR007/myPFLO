// lib/data/supabase/models/site_profile.dart

class SiteProfile {
  final String id;

  // Core
  final String fullName;
  final String title;
  final String email;

  // Optional
  final String? tagline;
  final String? aboutMd;

  // ✅ Prefer E.164 (e.g., +2348012345678)
  final String? phoneE164;

  // Legacy fallback if your table still has `phone`
  final String? phone;

  final String? linkedin;
  final String? cvUrl;
  final String? github;
  final String? twitter;
  final String? website;
  final String? location;
  final String? avatarUrl;

  // New name parts + DOB
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final DateTime? dateOfBirth;

  SiteProfile({
    required this.id,
    required this.fullName,
    required this.title,
    required this.email,
    this.tagline,
    this.aboutMd,
    this.phoneE164,
    this.phone, // legacy
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

  factory SiteProfile.fromMap(Map<String, dynamic> m) {
    final String? dobStr = m['date_of_birth'] as String?;
    return SiteProfile(
      id: (m['id'] ?? '') as String,
      fullName: (m['full_name'] ?? '') as String,
      title: (m['title'] ?? '') as String,
      email: (m['email'] ?? '') as String,
      tagline: m['tagline'] as String?,
      aboutMd: m['about_md'] as String?,

      // Prefer reading phone_e164; fall back to phone
      phoneE164: m['phone_e164'] as String?,
      phone: m['phone'] as String?,

      linkedin: m['linkedin'] as String?,
      cvUrl: m['cv_url'] as String?,
      github: m['github'] as String?,
      twitter: m['twitter'] as String?,
      website: m['website'] as String?,
      location: m['location'] as String?,
      avatarUrl: m['avatar_url'] as String?,

      firstName: m['first_name'] as String?,
      middleName: m['middle_name'] as String?,
      lastName: m['last_name'] as String?,
      dateOfBirth: (dobStr == null || dobStr.isEmpty)
          ? null
          : DateTime.parse(dobStr),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'full_name': fullName,
      'title': title,
      'email': email,
      'tagline': tagline,
      'about_md': aboutMd,

      // Write the preferred E.164 column when present
      'phone_e164': phoneE164,

      // Optional legacy write if you still use `phone` in the DB/UI
      'phone': phone,

      'linkedin': linkedin,
      'cv_url': cvUrl,
      'github': github,
      'twitter': twitter,
      'website': website,
      'location': location,
      'avatar_url': avatarUrl,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth == null
          ? null
          : DateTime(
              dateOfBirth!.year,
              dateOfBirth!.month,
              dateOfBirth!.day,
            ).toIso8601String().split('T').first,
    };

    map.removeWhere((_, v) => v == null);
    return map;
  }
}
