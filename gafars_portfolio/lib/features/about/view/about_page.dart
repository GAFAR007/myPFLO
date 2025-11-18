// lib/features/about/view/about_page.dart
//
// AboutPage – short story of who you are and how you work.
// Uses AppScaffold for consistent layout.

import 'package:flutter/material.dart';

import '../../shell/app_scaffold.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'About • Gafars Technologies',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, I’m Gafar Temitayo Razak',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mobile & Web Engineer • Backend Integration • MSc Business Management',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'I work at the intersection of business and technology – building mobile and web experiences that are not just “nice UIs”, '
                  'but actually solve problems for users and organisations.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'With an MSc in Business Management and hands-on experience in Flutter, Supabase, and Node.js/MongoDB backends, '
                  'I’m comfortable moving from understanding goals and constraints to designing APIs, modelling data, and shipping features.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'What I enjoy working on',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _BulletLine(
                  text:
                      'Mobile apps in Flutter that feel smooth, responsive, and clean on both phones and the web.',
                ),
                _BulletLine(
                  text:
                      'Connecting frontends to real backends – Supabase, REST APIs, Node.js, MongoDB – with clear data flows.',
                ),
                _BulletLine(
                  text:
                      'Turning messy, manual processes into digital workflows that save time and reduce errors.',
                ),
                const SizedBox(height: 24),
                Text(
                  'How I work',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _BulletLine(
                  text:
                      'I like to start simple: understand the outcome, design a small usable version, then iterate.',
                ),
                _BulletLine(
                  text:
                      'I document decisions so future changes are easier for both myself and other developers.',
                ),
                _BulletLine(
                  text:
                      'I care about communication – whether it’s with clients, non-technical stakeholders, or teammates.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
