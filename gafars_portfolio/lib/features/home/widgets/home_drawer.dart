import 'package:flutter/material.dart';

import '../../../data/api/models/site_profile.dart';
import '../../../data/api/profile_repository.dart';
import 'app_avatar.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final repo = ProfileRepository();

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.35),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: FutureBuilder<SiteProfile?>(
                  future: repo.fetchProfile(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        height: 92,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final profile = snapshot.data;
                    if (snapshot.hasError || profile == null) {
                      return _fallbackHeader(textTheme, colorScheme);
                    }

                    final firstName = _valueOr(profile.firstName, 'Razak');
                    final lastName = _valueOr(profile.lastName, 'Gafar');
                    final avatarUrl = profile.avatarUrl?.trim();
                    final fullName = profile.fullName.trim().isNotEmpty
                        ? profile.fullName.trim()
                        : '$firstName $lastName';

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                      ),
                      child: Row(
                        children: [
                          AppAvatar(
                            avatarUrl: avatarUrl,
                            fullName: fullName,
                            email: profile.email,
                            size: 60,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Open for product-focused roles',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimary.withValues(
                                      alpha: 0.82,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushNamed('/profile');
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'View profile',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.north_east_rounded,
                                        size: 16,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'Navigate',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  children: [
                    _drawerItem(
                      context,
                      icon: Icons.space_dashboard_outlined,
                      label: 'Overview',
                      routeName: '/',
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.person_outline,
                      label: 'Profile',
                      routeName: '/profile',
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.work_outline,
                      label: 'Projects',
                      routeName: '/projects',
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.psychology_alt_outlined,
                      label: 'About me',
                      routeName: '/about',
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.mail_outline,
                      label: 'Contact',
                      routeName: '/contact',
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.article_outlined,
                      label: 'CV / Resume',
                      routeName: '/resume',
                    ),
                    const SizedBox(height: 14),
                    Divider(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.settings_outlined,
                      label: 'Admin',
                      routeName: '/admin',
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.help_outline,
                      label: 'Help',
                      routeName: '/help',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _valueOr(String? raw, String fallback) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }

  Widget _fallbackHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.person, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('Portfolio navigation', style: textTheme.titleMedium),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? routeName,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      leading: Icon(icon, color: colorScheme.onSurface),
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () {
        Navigator.of(context).pop();
        if (routeName != null) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }
}
