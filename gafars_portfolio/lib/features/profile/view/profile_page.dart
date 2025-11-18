// lib/features/profile/view/profile_page.dart
//
// Public ProfilePage (VIEW ONLY)
//
// - Fetches your SiteProfile from Supabase (read-only).
// - Shows a modern card with:
//     • Avatar + full name + tagline/title
//     • Basic info (name, title, location, DOB)
//     • Contact info (email, phone, website)
//     • Social links + CV link (if available)
// - Works on mobile + larger screens.
// - Uses neutral fallbacks like "Not set yet" instead of hardcoded values.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<SiteProfile?>(
              future: repo.fetchProfile(),
              builder: (context, snapshot) {
                // ⏳ Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ❌ Error
                if (snapshot.hasError) {
                  return _ProfileError(
                    message: 'Could not load profile.',
                    error: snapshot.error.toString(),
                    onRetry: () {
                      (context as Element).markNeedsBuild();
                    },
                  );
                }

                final profile = snapshot.data;

                // No row yet
                if (profile == null) {
                  return const _ProfileEmpty();
                }

                // helper to build link tap
                VoidCallback? openUrl(String? rawUrl) =>
                    _buildOpenUrl(context, rawUrl);

                // ✅ Normal success UI
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Header: avatar + name + tagline/title ─────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _ProfileAvatar(avatarUrl: profile.avatarUrl),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _ProfileHeaderText(profile: profile),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(),

                          // ── Basic info ─────────────────────────────────────
                          _SectionTitle('Basic information'),
                          _ProfileInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Full name',
                            value: _safe(profile.fullName),
                          ),
                          _ProfileInfoRow(
                            icon: Icons.work_outline,
                            label: 'Title',
                            value: _safe(profile.title),
                          ),
                          _ProfileInfoRow(
                            icon: Icons.place_outlined,
                            label: 'Location',
                            value: _safe(profile.location),
                          ),
                          _ProfileInfoRow(
                            icon: Icons.cake_outlined,
                            label: 'Date of birth',
                            value: _formatDob(profile.dateOfBirth),
                          ),

                          const SizedBox(height: 16),
                          const Divider(),

                          // ── Contact ────────────────────────────────────────
                          _SectionTitle('Contact'),
                          _ProfileInfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: _safe(profile.email),
                          ),
                          _ProfileInfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: _primaryPhone(profile),
                          ),
                          _ProfileInfoRow(
                            icon: Icons.public_outlined,
                            label: 'Website',
                            value: _safe(profile.website),
                            onTap: openUrl(profile.website), // 👈 clickable
                          ),

                          const SizedBox(height: 16),
                          const Divider(),

                          // ── Socials ────────────────────────────────────────
                          _SectionTitle('Social'),
                          _ProfileInfoRow(
                            icon: Icons.linked_camera_outlined,
                            label: 'LinkedIn',
                            value: _safe(profile.linkedin),
                            onTap: openUrl(profile.linkedin), // 👈 clickable
                          ),
                          _ProfileInfoRow(
                            icon: Icons.code_outlined,
                            label: 'GitHub',
                            value: _safe(profile.github),
                            onTap: openUrl(profile.github), // 👈 clickable
                          ),
                          _ProfileInfoRow(
                            icon: Icons.message_outlined,
                            label: 'Twitter / X',
                            value: _safe(profile.twitter),
                            onTap: openUrl(profile.twitter), // 👈 clickable
                          ),

                          const SizedBox(height: 16),
                          const Divider(),

                          // ── CV section ─────────────────────────────────────
                          _SectionTitle('CV'),
                          const SizedBox(height: 8),
                          if (profile.cvUrl != null &&
                              profile.cvUrl!.trim().isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('View CV'),
                                onPressed: () {
                                  final url = profile.cvUrl!.trim();
                                  if (kIsWeb) {
                                    web.window.open(url, '_blank');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'CV opening is only wired for web right now.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          else
                            const _ProfileInfoRow(
                              icon: Icons.description_outlined,
                              label: 'CV',
                              value: 'Not uploaded yet',
                            ),
                        ],
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Header bits
// ─────────────────────────────────────────────────────────────────────────────

/// Small avatar widget that gracefully handles missing avatarUrl.
class _ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;

  const _ProfileAvatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (avatarUrl == null || avatarUrl!.trim().isEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.person,
          size: 32,
          color: colorScheme.onPrimaryContainer,
        ),
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundColor: colorScheme.surfaceVariant,
      foregroundImage: NetworkImage(avatarUrl!.trim()),
      child: Icon(Icons.person, size: 32, color: colorScheme.onSurfaceVariant),
    );
  }
}

/// Name + tagline / title at the top of the card.
class _ProfileHeaderText extends StatelessWidget {
  final SiteProfile profile;

  const _ProfileHeaderText({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final fullName = _buildFullName(profile);
    final subtitle = _headerSubtitle(profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable row + titles
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Generic row used for all label/value items (name, DOB, phone, etc.).
class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap; // 👈 NEW

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final displayValue = (value != null && value!.trim().isNotEmpty)
        ? value!.trim()
        : 'Not set yet';

    final isClickable = onTap != null && displayValue != 'Not set yet';

    Widget valueWidget = Text(displayValue, style: textTheme.bodyMedium);

    if (isClickable) {
      valueWidget = TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          displayValue,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                valueWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edge states
// ─────────────────────────────────────────────────────────────────────────────

/// Error UI for when the FutureBuilder throws.
class _ProfileError extends StatelessWidget {
  final String message;
  final String error;
  final VoidCallback onRetry;

  const _ProfileError({
    required this.message,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

/// UI when there is no profile row in the database yet.
class _ProfileEmpty extends StatelessWidget {
  const _ProfileEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline, size: 40, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          'No profile found yet',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ask the admin (Setup page) to complete your profile.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper functions (pure-ish)
// ─────────────────────────────────────────────────────────────────────────────

String _safe(String? value) {
  final v = value?.trim() ?? '';
  return v.isEmpty ? 'Not set yet' : v;
}

String _buildFullName(SiteProfile profile) {
  // Prefer split fields if present, else fall back to fullName from DB.
  final parts = <String>[
    profile.firstName ?? '',
    profile.middleName ?? '',
    profile.lastName ?? '',
  ].map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  if (parts.isNotEmpty) return parts.join(' ');

  final fromFull = profile.fullName.trim();
  if (fromFull.isNotEmpty) return fromFull;

  return 'Name not set yet';
}

String _headerSubtitle(SiteProfile profile) {
  final tagline = profile.tagline?.trim() ?? '';
  final title = profile.title.trim();

  if (tagline.isNotEmpty) return tagline;
  if (title.isNotEmpty) return title;
  return 'Profile summary';
}

String? _formatDob(DateTime? dob) {
  if (dob == null) return null;

  final y = dob.year.toString().padLeft(4, '0');
  final m = dob.month.toString().padLeft(2, '0');
  final d = dob.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String? _primaryPhone(SiteProfile profile) {
  // Prefer E.164, else legacy `phone`.
  final e164 = profile.phoneE164?.trim() ?? '';
  final legacy = profile.phone?.trim() ?? '';

  if (e164.isNotEmpty) return e164;
  if (legacy.isNotEmpty) return legacy;
  return null;
}

// opens links on web, shows a SnackBar on other platforms
VoidCallback? _buildOpenUrl(BuildContext context, String? rawUrl) {
  final url = rawUrl?.trim() ?? '';
  if (url.isEmpty) return null;

  return () {
    if (kIsWeb) {
      web.window.open(url, '_blank');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening links is only wired for web right now.'),
        ),
      );
    }
  };
}
