// lib/features/home/view/home_page.dart
//
// HomePage – responsive hero (desktop + mobile)
// Uses AppScaffold so AppBar + Drawer + Hire Me button are centralised.

import 'package:flutter/material.dart';

import '../../shell/app_scaffold.dart';

import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';
import '../widgets/displayavarter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();

    return AppScaffold(
      body: FutureBuilder<SiteProfile?>(
        future: repo.fetchProfile(),
        builder: (context, snapshot) {
          // ⏳ Loading state
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          // ❌ Error from Supabase / network
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile – please check Supabase / network.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final profile = snapshot.data;

          // ⚠️ No profile row at all
          if (profile == null) {
            return const Center(
              child: Text('No profile found in site_profile table.'),
            );
          }

          // ⭐ Helper: safely get trimmed value or fallback
          String valueOr(String? raw, String fallback) {
            final v = raw?.trim();
            if (v == null || v.isEmpty) return fallback;
            return v;
          }

          // ✅ Pull ONLY what we need for this hero
          final firstName = valueOr(profile.firstName, 'Razak');
          final lastName = valueOr(profile.lastName, 'Temitayo');

          final fullName = profile.fullName.trim();

          final displayName = fullName.isNotEmpty
              ? fullName
              : '$firstName $lastName';

          // 🔧 Updated so it’s not just Flutter/Supabase
          final title = valueOr(
            profile.title,
            'Mobile & Web Engineer | Flutter · Supabase · Node.js · UI/UX',
          );

          final tagline = valueOr(
            profile.tagline,
            'Blending business management with modern mobile & web experiences.',
          );

          final location = valueOr(
            profile.location,
            'Wolverhampton, United Kingdom',
          );

          // 🧾 LOG EVERYTHING WE USE ON THIS PAGE
          debugPrint('================ [HomePage hero data] ================');
          debugPrint('id         : ${profile.id}');
          debugPrint('firstName  : $firstName');
          debugPrint('lastName   : $lastName');
          debugPrint('fullName   : $fullName');
          debugPrint('displayName: $displayName');
          debugPrint('title      : $title');
          debugPrint('tagline    : $tagline');
          debugPrint('location   : $location');
          debugPrint('======================================================');

          return LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;

              // Center content and keep it from stretching too wide on big screens
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        // ✅ Use themed surface (nice in light & dark)
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          // Only add big drop shadow in light mode
                          if (theme.brightness == Brightness.light)
                            BoxShadow(
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                              color: Colors.black.withOpacity(0.06),
                            ),
                        ],
                      ),
                      child: isNarrow
                          // 📱 MOBILE: avatar on top, text centered
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const DisplayAvatar(),
                                const SizedBox(height: 24),
                                _HeroTextBlock(
                                  displayName: displayName,
                                  firstName: firstName,
                                  title: title,
                                  tagline: tagline,
                                  location: location,
                                  isNarrow: true,
                                ),
                              ],
                            )
                          // 🖥 DESKTOP/TABLET: text left, avatar right
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _HeroTextBlock(
                                    displayName: displayName,
                                    firstName: firstName,
                                    title: title,
                                    tagline: tagline,
                                    location: location,
                                    isNarrow: false,
                                  ),
                                ),
                                const SizedBox(width: 48),
                                const Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: DisplayAvatar(),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Hero text block used for both mobile & desktop.
class _HeroTextBlock extends StatelessWidget {
  const _HeroTextBlock({
    required this.displayName,
    required this.firstName,
    required this.title,
    required this.tagline,
    required this.location,
    required this.isNarrow,
  });

  final String displayName;
  final String firstName;
  final String title;
  final String tagline;
  final String location;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Column(
      crossAxisAlignment: isNarrow
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small pill with role / title (adds a bit of life)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            title,
            style: textTheme.labelMedium?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // "Hi, my name is ..."
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Hi, my name is '),
              TextSpan(
                text: displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: isNarrow ? TextAlign.center : TextAlign.left,
          style: (isNarrow ? textTheme.headlineMedium : textTheme.displaySmall)
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),

        // Tagline
        Text(
          tagline,
          textAlign: isNarrow ? TextAlign.center : TextAlign.left,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),

        // Location line
        Text(
          location,
          textAlign: isNarrow ? TextAlign.center : TextAlign.left,
          style: textTheme.bodyMedium?.copyWith(
            // ✅ Use themed subtle colour
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
