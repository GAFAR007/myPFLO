// lib/features/projects/view/projects_page.dart
//
// Placeholder Projects page. Later this will show your real apps/projects.

import 'package:flutter/material.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: const Center(
        child: Text(
          'Projects page coming soon.\n'
          'Here we will list your Flutter, React, and other work.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
