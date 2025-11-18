// lib/features/about/view/about_page.dart
//
// AboutPage
// ---------
// - Uses AppScaffold so the AppBar, drawer, and theme are centralised.
// - Fetches SiteProfile from Supabase.
// - IMPORTANT (your rule):
//     • No hard-coded personal fallback values (name/email/etc).
//     • If there is no profile row → show a loading-style card,
//       not fake data.
// - When profile exists, we render:
//     • Name / title / location
//     • Tagline (or "loading" if fields are empty)
//     • Optional aboutMd text
//     • "What I enjoy working on" + "How I work" sections.

import 'package:flutter/material.dart';

import '../../shell/app_scaffold.dart';
import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();

    return AppScaffold(
      title: 'About • Gafars Technologies',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: FutureBuilder<SiteProfile?>(
              // 🔹 Fetch the single SiteProfile row
              future: repo.fetchProfile(),
              builder: (context, snapshot) {
                final theme = Theme.of(context);
                final textTheme = theme.textTheme;
                final colorScheme = theme.colorScheme;

                // 🔍 Basic debug log for state
                debugPrint(
                  '[AboutPage] state=${snapshot.connectionState} '
                  'hasError=${snapshot.hasError} hasData=${snapshot.hasData}',
                );

                // ⏳ While loading: show a small centered spinner
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                // ❌ Log any error
                if (snapshot.hasError) {
                  debugPrint('AboutPage error: ${snapshot.error}');
                }

                final profile = snapshot.data;

                // If there is NO profile row at all, we do NOT fall back
                // to hard-coded personal data. Instead we show a simple
                // “loading / setup” style card so it's obvious something
                // is missing in the backend.
                if (profile == null) {
                  debugPrint(
                    '[AboutPage] profile is NULL – showing loading-style About card (no hard-coded name/title)',
                  );
                  return _AboutLoadingCard(
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  );
                }

                // Helper: trim and fallback to "loading" when empty.
                // This makes it obvious in the UI that something is not yet
                // populated in the DB, instead of silently faking content.
                String valueOrLoading(String? raw) {
                  final v = raw?.trim();
                  if (v == null || v.isEmpty) return 'loading';
                  return v;
                }

                // Build display fields from Supabase only
                final fullName = profile.fullName.trim();
                final firstName = valueOrLoading(profile.firstName);
                final lastName = valueOrLoading(profile.lastName);

                final displayName = fullName.isNotEmpty
                    ? fullName
                    : '$firstName $lastName';

                final title = valueOrLoading(profile.title);
                final location = valueOrLoading(profile.location);
                final tagline = valueOrLoading(profile.tagline);

                final aboutMd = profile.aboutMd?.trim();

                // 🧾 Debug final values coming from Supabase (or "loading")
                debugPrint('========== [AboutPage display values] ==========');
                debugPrint('displayName : $displayName');
                debugPrint('title       : $title');
                debugPrint('location    : $location');
                debugPrint('tagline     : $tagline');
                debugPrint('aboutMd     : ${aboutMd ?? '(null/empty)'}');
                debugPrint('===============================================');

                return Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: colorScheme.surface,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: name + title + location (all from DB or "loading")
                        Text(
                          'Hi, I’m $displayName',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(title, style: textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          location,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Short summary/tagline
                        Text(tagline, style: textTheme.bodyLarge),

                        const SizedBox(height: 20),

                        // Optional About text from Supabase (aboutMd)
                        if (aboutMd != null && aboutMd.isNotEmpty) ...[
                          Text(
                            'About me',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(aboutMd, style: textTheme.bodyMedium),
                          const SizedBox(height: 24),
                        ],

                        // Default structured sections (generic, not personal data)
                        Text(
                          'What I enjoy working on',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _BulletLine(
                          text:
                              'Mobile apps in Flutter that feel smooth, responsive, and clean on both phones and the web.',
                        ),
                        const _BulletLine(
                          text:
                              'Connecting frontends to real backends – Supabase, REST APIs, Node.js, MongoDB – with clear data flows.',
                        ),
                        const _BulletLine(
                          text:
                              'Turning manual or messy processes into simple digital workflows that save time and reduce errors.',
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'How I work',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _BulletLine(
                          text:
                              'Start from the outcome: understand the goal, then design a small, usable version before scaling up.',
                        ),
                        const _BulletLine(
                          text:
                              'Keep things understandable: clear structure, simple naming, and basic documentation for future changes.',
                        ),
                        const _BulletLine(
                          text:
                              'Communicate well with both technical and non-technical people – especially around trade-offs and timelines.',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Card shown when there is NO profile row at all.
/// This avoids faking your identity and makes it clear
/// that Supabase still needs to be configured.
class _AboutLoadingCard extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _AboutLoadingCard({required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colorScheme.surface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text('Loading about details...', style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
