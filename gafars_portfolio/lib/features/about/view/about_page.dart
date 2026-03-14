import 'package:flutter/material.dart';

import '../../../data/api/models/site_profile.dart';
import '../../../data/api/profile_repository.dart';
import '../../shell/app_scaffold.dart';
import '../../shell/public_page_frame.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();

    return AppScaffold(
      title: 'About • Gafars Technologies',
      body: PublicPageFrame(
        badge: 'About',
        title: 'Business context, software delivery, and product judgment.',
        description:
            'I do my best work where technical execution and real-world clarity need to meet. The point is not just shipping features, but making the result understandable, useful, and trustworthy.',
        maxWidth: 1040,
        child: FutureBuilder<SiteProfile?>(
          future: repo.fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const SurfacePanel(
                child: Text('Could not load about details right now.'),
              );
            }

            final profile = snapshot.data;
            final displayName = _displayName(profile);
            final title = _valueOr(
              profile?.title,
              'Product-minded software engineer',
            );
            final location = _valueOr(profile?.location, 'United Kingdom');
            final tagline = _valueOr(
              profile?.tagline,
              'I build clean digital products that make sense to both technical and non-technical people.',
            );
            final about = profile?.aboutMd?.trim();

            return LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 880;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SurfacePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$title • $location',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tagline,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (about != null && about.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Text(
                              about,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Flex(
                      direction: stacked ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(
                          child: _AboutSection(
                            title: 'What I enjoy working on',
                            items: [
                              'Flutter products that feel refined on both mobile and web.',
                              'Systems that turn messy manual workflows into clearer digital operations.',
                              'Interfaces that make a strong first impression without sacrificing usability.',
                            ],
                          ),
                        ),
                        SizedBox(width: 20, height: 20),
                        Expanded(
                          child: _AboutSection(
                            title: 'How I work',
                            items: [
                              'Start from the outcome and remove unnecessary complexity early.',
                              'Prefer clear architecture, readable naming, and maintainable changes.',
                              'Balance delivery speed with enough design polish that the product feels credible.',
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  static String _valueOr(String? raw, String fallback) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }

  static String _displayName(SiteProfile? profile) {
    if (profile == null) {
      return 'Razak Temitayo Gafar';
    }

    final fullName = profile.fullName.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final parts = [
      profile.firstName?.trim(),
      profile.lastName?.trim(),
    ].whereType<String>().where((value) => value.isNotEmpty).toList();

    return parts.isEmpty ? 'Razak Temitayo Gafar' : parts.join(' ');
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
