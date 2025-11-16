// lib/features/home/widgets/profile.dart
//
// ProfileWidget (Temitayo debug version)
//
// - Uses the real SiteProfile model you sent
// - Fetches the single profile row from Supabase via ProfileRepository
// - Shows all fields from SiteProfile in a simple debug layout
// - Easy to extend later for a proper About page

import 'package:flutter/material.dart';

import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();

    return FutureBuilder<SiteProfile?>(
      future: repo.fetchProfile(),
      builder: (context, snapshot) {
        // ⏳ Loading…
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        // ❌ Error from Supabase / network
        if (snapshot.hasError) {
          // ignore: avoid_print
          print('[ProfileWidget] ❌ fetchProfile error: ${snapshot.error}');
          return Center(
            child: Text(
              'Error fetching profile – check console logs.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          // ignore: avoid_print
          print('[ProfileWidget] ⚠️ No profile row found.');
          return const Center(
            child: Text('No profile row found in site_profile table.'),
          );
        }

        // Optional log of the full object
        // ignore: avoid_print
        print('[ProfileWidget] ✅ Profile fetched: $profile');

        final textTheme = Theme.of(context).textTheme;

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Site Profile (debug)', style: textTheme.titleLarge),
                const SizedBox(height: 12),

                // 🔐 Required fields
                _field('id', profile.id),
                _field('fullName', profile.fullName),
                _field('title', profile.title),
                _field('email', profile.email),

                const SizedBox(height: 8),

                // 📝 Optional text / bio
                _field('tagline', profile.tagline),
                _field('aboutMd', profile.aboutMd),

                const SizedBox(height: 8),

                // 📞 Phone fields
                _field('phoneE164', profile.phoneE164),
                _field('phone (legacy)', profile.phone),

                const SizedBox(height: 8),

                // 🌐 Links / online presence
                _field('linkedin', profile.linkedin),
                _field('github', profile.github),
                _field('twitter', profile.twitter),
                _field('website', profile.website),
                _field('cvUrl', profile.cvUrl),

                const SizedBox(height: 8),

                // 📍 Location + avatar
                _field('location', profile.location),
                _field('avatarUrl', profile.avatarUrl),

                const SizedBox(height: 8),

                // 👤 Name parts + DOB
                _field('firstName', profile.firstName),
                _field('middleName', profile.middleName),
                _field('lastName', profile.lastName),
                _field('dateOfBirth', profile.dateOfBirth?.toIso8601String()),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Helper widget for "label: value" rows.
  ///
  /// Keeps the layout neat and code DRY.
  Widget _field(String label, Object? value) {
    final display = (value == null || value.toString().isEmpty)
        ? '<null>'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (fixed width column)
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          // Value (selectable so you can copy it)
          Expanded(child: SelectableText(display)),
        ],
      ),
    );
  }
}
