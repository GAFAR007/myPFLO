import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shell/app_scaffold.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    /// TEMP STATIC DATA (matches what you showed)
    final projects = <ProjectCardData>[
      ProjectCardData(
        title: 'Farm Research Platform',
        subtitle: 'Flutter Web • Research',
        description:
            'A web-based research and data collection platform built with Flutter and Supabase.',
        tags: const ['flutter', 'research', 'web'],
        url: 'https://farmresearch.gafarstechnologies.com',
      ),
      ProjectCardData(
        title: 'Gafars Technologies Portfolio',
        subtitle: 'Flutter Web • Supabase',
        description:
            'Admin-managed portfolio system with Supabase backend and Flutter Web frontend.',
        tags: const ['flutter', 'portfolio', 'supabase', 'web'],
        url: 'https://gafarstechnologies.com',
      ),
    ];

    /// 🔎 DEBUG: log projects once page builds
    debugPrint('========== PROJECTS DEBUG ==========');
    for (final p in projects) {
      debugPrint('Project: ${p.title}');
      debugPrint('URL: ${p.url}');
    }
    debugPrint('===================================');

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
                      children: projects.map((project) {
                        final width = isWide
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth;

                        return SizedBox(
                          width: width,
                          child: ProjectCard(data: project),
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

/// ---------------------------------------------------------------------------
/// DATA MODEL
/// ---------------------------------------------------------------------------
class ProjectCardData {
  final String title;
  final String subtitle;
  final String description;
  final List<String> tags;
  final String? url;

  const ProjectCardData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
    this.url,
  });
}

/// ---------------------------------------------------------------------------
/// PROJECT CARD (CLICKABLE + URL DISPLAY)
/// ---------------------------------------------------------------------------
class ProjectCard extends StatelessWidget {
  final ProjectCardData data;

  const ProjectCard({super.key, required this.data});

  Future<void> _openUrl(BuildContext context) async {
    if (data.url == null || data.url!.isEmpty) {
      debugPrint('[PROJECT CLICK] No URL for ${data.title}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No project link available')),
      );
      return;
    }

    final uri = Uri.parse(data.url!);

    debugPrint('[PROJECT CLICK]');
    debugPrint('Title: ${data.title}');
    debugPrint('Opening URL: $uri');

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint('[ERROR] Failed to open $uri');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openUrl(context),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Text(
                data.title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),

              /// SUBTITLE
              Text(
                data.subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              /// DESCRIPTION
              Text(data.description, style: textTheme.bodyMedium),
              const SizedBox(height: 12),

              /// TAGS
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: data.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: colorScheme.primary.withOpacity(0.08),
                        ),
                        child: Text(
                          tag,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              /// URL DISPLAY
              if (data.url != null && data.url!.isNotEmpty) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _openUrl(context),
                  child: Text(
                    data.url!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
