import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/api/models/project.dart';
import '../../../data/api/projects_repository.dart';
import '../../shell/app_scaffold.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final repository = ProjectsRepository();

    return AppScaffold(
      title: 'Projects • Gafars Technologies',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: FutureBuilder<List<PortfolioProject>>(
              future: repository.fetchProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text(
                    'Could not load projects right now.',
                    style: textTheme.bodyMedium,
                  );
                }

                final projects = snapshot.data ?? const <PortfolioProject>[];

                return Column(
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
                    if (projects.isEmpty)
                      Text(
                        'No projects have been published yet.',
                        style: textTheme.bodyMedium,
                      )
                    else
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
                                child: ProjectCard(project: project),
                              );
                            }).toList(),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openUrl(context),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if ((project.subtitle ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  project.subtitle!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
              if ((project.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(project.description!, style: textTheme.bodyMedium),
              ],
              if (project.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: project.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: colorScheme.primary.withValues(alpha: 0.08),
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
              ],
              if ((project.url ?? '').isNotEmpty) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _openUrl(context),
                  child: Text(
                    project.url!,
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
