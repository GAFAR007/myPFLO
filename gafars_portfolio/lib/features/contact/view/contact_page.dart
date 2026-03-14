import 'package:flutter/material.dart';

import '../../../data/api/models/site_profile.dart';
import '../../../data/api/profile_repository.dart';
import '../../shell/app_scaffold.dart';
import '../../shell/public_page_frame.dart';
import 'contact_form_page.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();

    return AppScaffold(
      title: 'Contact • Gafars Technologies',
      body: PublicPageFrame(
        badge: 'Contact',
        title: 'If the work fits, let’s talk.',
        description:
            'The best outreach is simple: what you are hiring for, what problem needs solving, and what kind of timeline you are working with.',
        maxWidth: 1080,
        child: FutureBuilder<SiteProfile?>(
          future: repo.fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = snapshot.data;

            return LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 900;

                return Flex(
                  direction: stacked ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: stacked ? 0 : 4,
                      child: _ContactInfoPanel(profile: profile),
                    ),
                    SizedBox(width: stacked ? 0 : 20, height: stacked ? 20 : 0),
                    Expanded(
                      flex: stacked ? 0 : 6,
                      child: const SurfacePanel(
                        child: ContactFormPage(
                          embedded: true,
                          showBackButton: false,
                        ),
                      ),
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
}

class _ContactInfoPanel extends StatelessWidget {
  const _ContactInfoPanel({required this.profile});

  final SiteProfile? profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final email = _valueOr(profile?.email, 'razakgafar98@outlook.com');
    final phone = _valueOr(
      profile?.phoneE164 ?? profile?.phone,
      'Not published',
    );
    final location = _valueOr(profile?.location, 'United Kingdom');

    return SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact details', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            'You can use the form, or reach out directly if you already know the role or project scope.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _InfoLine(icon: Icons.email_outlined, label: 'Email', value: email),
          const SizedBox(height: 14),
          _InfoLine(icon: Icons.phone_outlined, label: 'Phone', value: phone),
          const SizedBox(height: 14),
          _InfoLine(
            icon: Icons.place_outlined,
            label: 'Location',
            value: location,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.42),
            ),
            child: Text(
              'I usually reply within 24 to 48 hours when the message clearly explains the opportunity.',
              style: textTheme.bodyMedium,
            ),
          ),
        ],
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
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
