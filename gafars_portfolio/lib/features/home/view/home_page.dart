import 'package:flutter/material.dart';

import '../../../data/api/models/site_profile.dart';
import '../../../data/api/profile_repository.dart';
import '../../contact/view/contact_form_page.dart';
import '../../shell/app_scaffold.dart';
import '../widgets/app_avatar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ProfileRepository();

    return AppScaffold(
      body: FutureBuilder<SiteProfile?>(
        future: repository.fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading profile. Please try again shortly.'),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('No profile found yet.'));
          }

          final displayName = _displayName(profile);
          final title = _valueOr(
            profile.title,
            'Flutter Engineer building modern web and mobile products',
          );
          final tagline = _valueOr(
            profile.tagline,
            'I combine product thinking, clean implementation, and business context so the end result feels credible the moment someone lands on it.',
          );
          final location = _valueOr(
            profile.location,
            'Wolverhampton, United Kingdom',
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;

              return Stack(
                children: [
                  Positioned(
                    top: -80,
                    left: compact ? -100 : -20,
                    child: _GlowOrb(
                      size: compact ? 220 : 320,
                      color: colorScheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  Positioned(
                    right: compact ? -80 : -10,
                    top: compact ? 120 : 40,
                    child: _GlowOrb(
                      size: compact ? 200 : 280,
                      color: colorScheme.secondary.withValues(alpha: 0.16),
                    ),
                  ),
                  Positioned(
                    bottom: -90,
                    left: compact ? 20 : 120,
                    child: _GlowOrb(
                      size: compact ? 180 : 260,
                      color: colorScheme.tertiary.withValues(alpha: 0.12),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 18 : 28,
                      compact ? 26 : 36,
                      compact ? 18 : 28,
                      48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AvailabilityBanner(location: location),
                            const SizedBox(height: 28),
                            Flex(
                              direction: compact
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: compact ? 0 : 7,
                                  child: _HeroCopy(
                                    displayName: displayName,
                                    title: title,
                                    tagline: tagline,
                                    compact: compact,
                                    onDiscussRole: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ContactFormPage(),
                                        ),
                                      );
                                    },
                                    onViewProjects: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/projects');
                                    },
                                    onViewResume: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/resume');
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: compact ? 0 : 32,
                                  height: compact ? 28 : 0,
                                ),
                                Expanded(
                                  flex: compact ? 0 : 5,
                                  child: _ProfileSpotlight(
                                    profile: profile,
                                    displayName: displayName,
                                    title: title,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              spacing: 18,
                              runSpacing: 18,
                              children: const [
                                _ProofCard(
                                  label: 'Best fit',
                                  value:
                                      'Teams that need polished Flutter delivery with product judgment.',
                                ),
                                _ProofCard(
                                  label: 'Working style',
                                  value:
                                      'Fast iteration, clean execution, and clear communication.',
                                ),
                                _ProofCard(
                                  label: 'Stack',
                                  value:
                                      'Flutter, Node.js, MongoDB, product UX, and frontend detail.',
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),
                            _HiringAngleSection(compact: compact),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
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

  static String _displayName(SiteProfile profile) {
    final fullName = profile.fullName.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final values = [
      profile.firstName?.trim(),
      profile.lastName?.trim(),
    ].whereType<String>().where((value) => value.isNotEmpty).toList();

    if (values.isEmpty) {
      return 'Razak Temitayo Gafar';
    }

    return values.join(' ');
  }
}

class _AvailabilityBanner extends StatelessWidget {
  const _AvailabilityBanner({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 14,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Available for hiring conversations',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          Text(
            location,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.displayName,
    required this.title,
    required this.tagline,
    required this.compact,
    required this.onDiscussRole,
    required this.onViewProjects,
    required this.onViewResume,
  });

  final String displayName;
  final String title;
  final String tagline;
  final bool compact;
  final VoidCallback onDiscussRole;
  final VoidCallback onViewProjects;
  final VoidCallback onViewResume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRODUCT-MINDED FLUTTER ENGINEER',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'I build software that feels polished enough to trust at first glance.',
          style: compact
              ? theme.textTheme.displaySmall
              : theme.textTheme.displayLarge,
        ),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$displayName ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text:
                    'is a $title who treats the portfolio itself like a product. $tagline',
              ),
            ],
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            FilledButton.icon(
              onPressed: onDiscussRole,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Discuss a role'),
            ),
            OutlinedButton.icon(
              onPressed: onViewProjects,
              icon: const Icon(Icons.work_outline_rounded),
              label: const Text('View projects'),
            ),
            TextButton.icon(
              onPressed: onViewResume,
              icon: const Icon(Icons.article_outlined),
              label: const Text('View resume'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileSpotlight extends StatelessWidget {
  const _ProfileSpotlight({
    required this.profile,
    required this.displayName,
    required this.title,
  });

  final SiteProfile profile;
  final String displayName;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Hiring-ready',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.north_east_rounded, color: colorScheme.secondary),
            ],
          ),
          const SizedBox(height: 22),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: AppAvatar(
                avatarUrl: profile.avatarUrl,
                fullName: displayName,
                email: profile.email,
                size: 176,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(displayName, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          const _CapabilityLine(
            title: 'What you get',
            value: 'A frontend that looks intentional, not assembled.',
          ),
          const SizedBox(height: 12),
          const _CapabilityLine(
            title: 'What I optimise for',
            value: 'Trust, clarity, and product feel.',
          ),
          const SizedBox(height: 12),
          const _CapabilityLine(
            title: 'Where I add value',
            value: 'Shipping quickly without making the UI feel cheap.',
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              Chip(label: Text('Flutter')),
              Chip(label: Text('MongoDB')),
              Chip(label: Text('Node.js')),
              Chip(label: Text('UX detail')),
              Chip(label: Text('Product thinking')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapabilityLine extends StatelessWidget {
  const _CapabilityLine({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProofCard extends StatelessWidget {
  const _ProofCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 340,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _HiringAngleSection extends StatelessWidget {
  const _HiringAngleSection({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why this feels stronger', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 10),
        Text(
          'Hiring managers should immediately see more than technical ability. The UI should signal judgment, product taste, and credibility before they read the second paragraph.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        Flex(
          direction: compact ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: _AngleCard(
                number: '01',
                title: 'Clear first impression',
                description:
                    'The hero now leads with competence, not generic portfolio language.',
              ),
            ),
            SizedBox(width: 18, height: 18),
            Expanded(
              child: _AngleCard(
                number: '02',
                title: 'Sharper hiring narrative',
                description:
                    'The copy frames you as someone who ships polished software, not just screens.',
              ),
            ),
            SizedBox(width: 18, height: 18),
            Expanded(
              child: _AngleCard(
                number: '03',
                title: 'More visual confidence',
                description:
                    'Typography, palette, and section structure now look chosen on purpose.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AngleCard extends StatelessWidget {
  const _AngleCard({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
