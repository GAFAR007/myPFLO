// lib/features/home/view/home_page.dart
//
// HomePage – responsive hero (desktop + mobile)

import 'package:flutter/material.dart';
import 'package:gafars_portfolio/features/home/widgets/contact_form_page.dart';

import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';
import '../widgets/displayavarter.dart';
import '../widgets/menu_button.dart';
import '../widgets/hire_me_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withOpacity(0.2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        // 👇 give the MENU text enough width so it doesn’t look broken
        leadingWidth: 90,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: MenuButton(),
        ),
        title: const Text('Gafars Technologies'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: HireMeButton(
              // 👇 HIRE ME → navigate to form page
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContactFormPage()),
                );
              },
            ),
          ),
        ],
      ),
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
          String _valueOr(String? raw, String fallback) {
            final v = raw?.trim();
            if (v == null || v.isEmpty) return fallback;
            return v;
          }

          // ✅ Pull ONLY what we need for this hero
          final firstName = _valueOr(profile.firstName, 'Razak');
          final lastName = _valueOr(profile.lastName, 'Temitayo');

          // fullName can be null in DB, so handle it safely
          final fullNameRaw = profile.fullName;
          final fullName = fullNameRaw.trim();

          final displayName = fullName.isNotEmpty
              ? fullName
              : '$firstName $lastName';

          final title = _valueOr(
            profile.title,
            'Mobile Software Engineer | Flutter · Supabase · UI/UX',
          );

          final tagline = _valueOr(
            profile.tagline,
            'Blending business management with modern mobile & web experiences.',
          );

          final location = _valueOr(
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
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
    final primary = Theme.of(context).colorScheme.primary;

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
          'Based in $location',
          textAlign: isNarrow ? TextAlign.center : TextAlign.left,
          style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}
