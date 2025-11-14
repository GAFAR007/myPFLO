// lib/features/about/view/about_page.dart
//
// Placeholder About page. Later this will read from `site_profile`.

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Me')),
      body: const Center(
        child: Text(
          'About page coming soon.\n'
          'We will pull your bio, skills, and experience from Supabase.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
