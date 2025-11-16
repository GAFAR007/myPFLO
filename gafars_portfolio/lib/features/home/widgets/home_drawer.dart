// lib/features/home/widgets/home_drawer.dart
//
// Simple Lyft-style side drawer.
// - Fetches SiteProfile from Supabase (only firstName, lastName, avatarUrl).
// - Shows your real avatar + name in the header.
// - Below that: a list of nav items that navigate with named routes.

import 'package:flutter/material.dart';

import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';
import '../../home/widgets/app_avatar.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final repo = ProfileRepository();

    return Drawer(
      child: Container(
        color: const Color(0xFF141821), // dark background like Lyft
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header – fetch profile then show avatar + name
              Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<SiteProfile?>(
                  future: repo.fetchProfile(),
                  builder: (context, snapshot) {
                    // Loading → small spinner where header would be
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        height: 72,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    }

                    // Error → fallback "Guest" header
                    if (snapshot.hasError) {
                      debugPrint(
                        '[HomeDrawer] ❌ fetchProfile error: ${snapshot.error}',
                      );
                      return _fallbackHeader(textTheme);
                    }

                    final profile = snapshot.data;

                    if (profile == null) {
                      debugPrint('[HomeDrawer] ⚠️ No profile row found.');
                      return _fallbackHeader(textTheme);
                    }

                    // Helper: trim or fallback
                    String valueOr(String? raw, String fallback) {
                      final v = raw?.trim();
                      if (v == null || v.isEmpty) return fallback;
                      return v;
                    }

                    final firstName = valueOr(profile.firstName, 'Razak');
                    final lastName = valueOr(profile.lastName, 'Gafar');
                    final fullName = '$firstName $lastName';
                    final avatarUrl = profile.avatarUrl?.trim() ?? '';

                    debugPrint('[HomeDrawer] name     : $fullName');
                    debugPrint('[HomeDrawer] avatarUrl: $avatarUrl');

                    return Row(
                      children: [
                        AppAvatar(avatarUrl: avatarUrl, size: 56),

                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  debugPrint('[Drawer] View profile tapped');
                                  // TODO: navigate to About/Profile page
                                },
                                child: Text(
                                  'View profile',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // 🔹 Navigation items
              _drawerItem(
                context,
                icon: Icons.dashboard_outlined,
                label: 'Overview',
                routeName: '/',
              ),
              _drawerItem(
                context,
                icon: Icons.work_outline,
                label: 'Projects',
                routeName: '/projects',
              ),
              _drawerItem(
                context,
                icon: Icons.person_outline,
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
                routeName: '/resume', // 👈 now navigates to ResumePage
              ),

              const Divider(color: Colors.white10, height: 24),
              _drawerItem(
                context,
                icon: Icons.settings_outlined,
                label: 'Settings',
                routeName:
                    '/admin', // 👈 Admin area (AuthGate → Login → SetupPage)
              ),
              _drawerItem(
                context,
                icon: Icons.help_outline,
                label: 'Help',
                // Later: routeName: '/help',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fallback header when profile fails to load
  Widget _fallbackHeader(TextTheme textTheme) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white10,
          child: Icon(Icons.person, color: Colors.white70),
        ),
        const SizedBox(width: 12),
        Text(
          'Guest',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ✅ Single merged version: supports navigation via routeName
  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? routeName,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      onTap: () {
        debugPrint('[Drawer] $label tapped');
        Navigator.of(context).pop(); // close drawer first

        if (routeName != null) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }
}
