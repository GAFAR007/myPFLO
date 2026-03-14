import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/api/models/site_profile.dart';
import '../../../data/api/profile_repository.dart';
import '../../home/widgets/app_avatar.dart';
import '../../shell/app_scaffold.dart';
import '../../shell/public_page_frame.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();

    return AppScaffold(
      title: 'Profile • Gafars Technologies',
      body: PublicPageFrame(
        badge: 'Profile',
        title: 'A clearer picture of who I am and how I work.',
        description:
            'This page is meant to make due diligence easy: core identity, contact routes, social links, and the profile details behind the public portfolio.',
        maxWidth: 1080,
        child: FutureBuilder<SiteProfile?>(
          future: repo.fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const SurfacePanel(
                child: Text('Could not load profile right now.'),
              );
            }

            final profile = snapshot.data;
            if (profile == null) {
              return const SurfacePanel(child: Text('No profile found yet.'));
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 920;

                return Flex(
                  direction: stacked ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: stacked ? 0 : 4,
                      child: _ProfileHero(profile: profile),
                    ),
                    SizedBox(width: stacked ? 0 : 20, height: stacked ? 20 : 0),
                    Expanded(
                      flex: stacked ? 0 : 6,
                      child: Column(
                        children: [
                          _ProfileSection(
                            title: 'Basic information',
                            rows: [
                              _InfoData('Full name', _fullName(profile)),
                              _InfoData('Title', _safe(profile.title)),
                              _InfoData('Location', _safe(profile.location)),
                              _InfoData(
                                'Date of birth',
                                _formatDob(profile.dateOfBirth),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _ProfileSection(
                            title: 'Contact and social',
                            rows: [
                              _InfoData(
                                'Email',
                                _safe(profile.email),
                                url: profile.email.trim().isEmpty
                                    ? null
                                    : 'mailto:${profile.email.trim()}',
                              ),
                              _InfoData('Phone', _primaryPhone(profile)),
                              _InfoData(
                                'Website',
                                _safe(profile.website),
                                url: profile.website,
                              ),
                              _InfoData(
                                'LinkedIn',
                                _safe(profile.linkedin),
                                url: profile.linkedin,
                              ),
                              _InfoData(
                                'GitHub',
                                _safe(profile.github),
                                url: profile.github,
                              ),
                              _InfoData(
                                'Twitter / X',
                                _safe(profile.twitter),
                                url: profile.twitter,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SurfacePanel(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    profile.cvUrl?.trim().isNotEmpty == true
                                        ? 'CV is available and linked here.'
                                        : 'CV has not been uploaded yet.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (profile.cvUrl?.trim().isNotEmpty == true)
                                  FilledButton.icon(
                                    onPressed: () =>
                                        _openUrl(context, profile.cvUrl),
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('View CV'),
                                  ),
                              ],
                            ),
                          ),
                        ],
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

  static Future<void> _openUrl(BuildContext context, String? rawUrl) async {
    final url = rawUrl?.trim() ?? '';
    if (url.isEmpty) {
      return;
    }

    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final SiteProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppAvatar(
              avatarUrl: profile.avatarUrl,
              fullName: _fullName(profile),
              email: profile.email,
              size: 168,
            ),
          ),
          const SizedBox(height: 22),
          Text(_fullName(profile), style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            _headerSubtitle(profile),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (profile.title.trim().isNotEmpty)
                Chip(label: Text(profile.title.trim())),
              if ((profile.location ?? '').trim().isNotEmpty)
                Chip(label: Text(profile.location!.trim())),
              if ((profile.phoneE164 ?? profile.phone ?? '').trim().isNotEmpty)
                Chip(label: Text('Available to contact')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.rows});

  final String title;
  final List<_InfoData> rows;

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          ...rows.map((row) => _InfoRow(data: row)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.data});

  final _InfoData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = data.value?.trim().isNotEmpty == true
        ? data.value!.trim()
        : 'Not set yet';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          if (data.url != null && value != 'Not set yet')
            TextButton(
              onPressed: () => ProfilePage._openUrl(context, data.url),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _InfoData {
  const _InfoData(this.label, this.value, {this.url});

  final String label;
  final String? value;
  final String? url;
}

String _safe(String? value) {
  final v = value?.trim() ?? '';
  return v.isEmpty ? 'Not set yet' : v;
}

String _fullName(SiteProfile profile) {
  final parts = <String>[
    profile.firstName ?? '',
    profile.middleName ?? '',
    profile.lastName ?? '',
  ].map((value) => value.trim()).where((value) => value.isNotEmpty).toList();

  if (parts.isNotEmpty) {
    return parts.join(' ');
  }

  final fullName = profile.fullName.trim();
  return fullName.isEmpty ? 'Name not set yet' : fullName;
}

String _headerSubtitle(SiteProfile profile) {
  final tagline = profile.tagline?.trim() ?? '';
  if (tagline.isNotEmpty) {
    return tagline;
  }

  final title = profile.title.trim();
  if (title.isNotEmpty) {
    return title;
  }

  return 'Profile summary';
}

String? _formatDob(DateTime? dob) {
  if (dob == null) {
    return null;
  }

  final year = dob.year.toString().padLeft(4, '0');
  final month = dob.month.toString().padLeft(2, '0');
  final day = dob.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String? _primaryPhone(SiteProfile profile) {
  final e164 = profile.phoneE164?.trim() ?? '';
  if (e164.isNotEmpty) {
    return e164;
  }

  final phone = profile.phone?.trim() ?? '';
  if (phone.isNotEmpty) {
    return phone;
  }

  return null;
}
