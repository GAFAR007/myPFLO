// lib/features/home/view/home_page.dart
//
// Public Home page for your portfolio.
// - Shows a simple hero section
// - Links to Projects, About, Contact
// - Has an "Admin (Dev only)" button to reach the /admin route.

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gafars Technologies'),
        actions: [
          // Small admin button – only you should know about this.
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/admin');
            },
            child: const Text(
              'Admin (Dev)',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _HomeHero(),
                SizedBox(height: 24),
                _HomeNavSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple hero section.
/// Later we can replace static text with data from `site_profile`
/// (name, title, tagline) using ProfileRepository.
class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'Hi, I\'m Gafar',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Mobile Software Engineer • Flutter • Supabase • UI/UX',
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'I build clean, fast and scalable apps using Flutter and modern backend tools, '
          'with a strong foundation in business management and real-world delivery.',
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Quick navigation buttons for key sections.
/// These are simple now but can become cards / tiles later.
class _HomeNavSection extends StatelessWidget {
  const _HomeNavSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed('/projects');
          },
          icon: const Icon(Icons.work_outline),
          label: const Text('View Projects'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed('/about');
          },
          icon: const Icon(Icons.person_outline),
          label: const Text('About Me'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed('/contact');
          },
          icon: const Icon(Icons.mail_outline),
          label: const Text('Contact Me'),
        ),
      ],
    );
  }
}
