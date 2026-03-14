import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/api/models/project.dart';
import '../../../data/api/projects_repository.dart';
import '../../shell/app_scaffold.dart';
import '../../shell/public_page_frame.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ProjectsRepository();
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Projects • Gafars Technologies',
      body: PublicPageFrame(
        badge: 'Selected Work',
        title: 'Projects that show how I think, not just what I code.',
        description:
            'Each project here reflects a different type of product problem: public-facing platforms, operational systems, and education workflows. The goal is consistent execution and a finish that feels credible.',
        child: FutureBuilder<List<PortfolioProject>>(
          future: repository.fetchProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return SurfacePanel(
                child: Text(
                  'Could not load projects right now.',
                  style: textTheme.bodyMedium,
                ),
              );
            }

            final projects = snapshot.data ?? const <PortfolioProject>[];
            if (projects.isEmpty) {
              return SurfacePanel(
                child: Text(
                  'No projects have been published yet.',
                  style: textTheme.bodyMedium,
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= 900;
                final spacing = 20.0;
                final width = useTwoColumns
                    ? (constraints.maxWidth - spacing) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: projects
                      .map(
                        (project) => SizedBox(
                          width: width,
                          child: ProjectCard(project: project),
                        ),
                      )
                      .toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final PortfolioProject project;

  Future<void> _openUrl(BuildContext context) async {
    final rawUrl = project.url?.trim() ?? '';
    if (rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No project link available')),
      );
      return;
    }

    final uri = Uri.parse(rawUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final hasLink = (project.url ?? '').trim().isNotEmpty;

    return SurfacePanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title, style: textTheme.headlineMedium),
                    if ((project.subtitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        project.subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasLink)
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: () => _openUrl(context),
                    icon: const Icon(Icons.north_east_rounded),
                    tooltip: 'Open project',
                  ),
                ),
            ],
          ),
          if ((project.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              project.description!,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (project.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: project.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasLink ? 'Live project' : 'Private build',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (hasLink)
                TextButton.icon(
                  onPressed: () => _openUrl(context),
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Open'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
