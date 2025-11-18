// lib/features/projects/view/projects_page.dart
//
// ProjectsPage – showcases key work in a simple, modern layout.
// Uses AppScaffold so AppBar + Drawer + Hire Me are centralised.

import 'package:flutter/material.dart';

import '../../shell/app_scaffold.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // You can later load this from Supabase – for now it's static.
    final projects = <_ProjectCardData>[
      _ProjectCardData(
        title: 'Survey Application',
        subtitle: 'Flutter • Supabase • Backend Processing',
        description:
            'End-to-end survey system where responses are stored in Supabase, '
            'processed on the backend, and exported as ZIP files for analysis.',
        tags: const ['Flutter', 'Supabase', 'REST APIs'],
      ),
      _ProjectCardData(
        title: 'Portfolio System',
        subtitle: 'Flutter Web • Supabase',
        description:
            'Portfolio/profile flows for uploading avatars and CV files, '
            'with secure storage and public-facing pages for visitors.',
        tags: const ['Flutter Web', 'Supabase Storage'],
      ),
      _ProjectCardData(
        title: 'Node + MongoDB Services',
        subtitle: 'Node.js • MongoDB • REST APIs',
        description:
            'Small backend services exposing CRUD APIs, connected to mobile UIs '
            'for real-time data-driven features.',
        tags: const ['Node.js', 'MongoDB', 'Backend'],
      ),
    ];

    return AppScaffold(
      title: 'Projects • Gafars Technologies',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Projects',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A few examples of how I combine business thinking with modern mobile and web development.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: projects.map((p) {
                        final width = isWide
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth;
                        return SizedBox(
                          width: width,
                          child: _ProjectCard(data: p),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCardData {
  final String title;
  final String subtitle;
  final String description;
  final List<String> tags;

  const _ProjectCardData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
  });
}

class _ProjectCard extends StatelessWidget {
  final _ProjectCardData data;
  const _ProjectCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.subtitle,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(data.description, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: data.tags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: colorScheme.primary.withOpacity(0.08),
                      ),
                      child: Text(
                        t,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
