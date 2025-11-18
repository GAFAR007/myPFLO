// lib/features/resume/view/resume_page.dart
//
// Public ResumePage for your portfolio visitors.
// - Fetches your SiteProfile from Supabase.
// - Shows a modern techy layout with:
//     • CV intro + highlights
//     • "View CV" + "Download CV" buttons
// - Layout adapts nicely to both big and small screens.
// - Uses AppScaffold so AppBar + Drawer + Hire Me are centralised.

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

import '../../shell/app_scaffold.dart';
import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';

class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  final _repo = ProfileRepository();

  SiteProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repo.fetchProfile();

      if (kDebugMode) {
        debugPrint('ResumePage → id: ${profile?.id}');
        debugPrint('ResumePage → cvUrl: ${profile?.cvUrl}');
      }

      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResumePage error: $e');
      }
      setState(() {
        _error = 'Something went wrong while loading the CV.';
        _loading = false;
      });
    }
  }

  void _openCv() {
    final cvUrl = _profile?.cvUrl;
    if (cvUrl == null || cvUrl.isEmpty) {
      _showSnack('CV not available yet.');
      return;
    }

    if (kIsWeb) {
      web.window.open(cvUrl, '_blank'); // full-page view in new tab
    } else {
      _showSnack('Open CV:\n$cvUrl');
    }
  }

  void _downloadCv() {
    final cvUrl = _profile?.cvUrl;
    if (cvUrl == null || cvUrl.isEmpty) {
      _showSnack('CV not available yet.');
      return;
    }

    if (kIsWeb) {
      // Supabase public URLs support ?download=FILENAME to trigger download.
      final downloadUrl = '$cvUrl?download=Gafar_Razak_CV.pdf';
      web.window.open(downloadUrl, '_blank');
    } else {
      _showSnack('Download CV from:\n$cvUrl');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'CV / Resume',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Text(
        _error!,
        style: textTheme.bodyMedium,
        textAlign: TextAlign.center,
      );
    }

    final hasCv = _profile?.cvUrl != null && _profile!.cvUrl!.isNotEmpty;

    if (!hasCv) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CV coming soon',
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'I’m currently updating my CV.\n'
            'Please check back again shortly.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // 🔹 Responsive card: row on big screens, column on small
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        final compact = constraints.maxWidth < 600; // phones / small tablets

        final content = isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildIntroPanel(textTheme, compact: compact),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 4,
                    child: _buildCvPanel(textTheme, compact: compact),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildIntroPanel(textTheme, compact: compact),
                  const SizedBox(height: 24),
                  _buildCvPanel(textTheme, compact: compact),
                ],
              );

        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surfaceVariant,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            padding: EdgeInsets.all(compact ? 16 : 24),
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildIntroPanel(TextTheme textTheme, {required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Curriculum Vitae',
          style: compact ? textTheme.headlineSmall : textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          // 🔧 Updated text so it’s not just "care"
          'A snapshot of my journey across business management, software engineering, and real-world product delivery.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        // Small techy chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _InfoChip(label: 'MSc Business Management'),
            _InfoChip(label: 'Mobile Software Engineer'),
            _InfoChip(label: 'Flutter • React • Node'),
            _InfoChip(label: 'Care & Support Experience'),
          ],
        ),

        const SizedBox(height: 24),
        Text('What you’ll find inside', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          '• Key projects in Flutter, React, and Node.js\n'
          '• Management and leadership experience\n'
          '• Education, certifications, and core skills',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCvPanel(TextTheme textTheme, {required bool compact}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.picture_as_pdf, size: 64),
          const SizedBox(height: 12),
          Text(
            'Gafar Temitayo Razak – CV',
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'PDF • 1 file • Supabase storage',
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 🔹 Responsive buttons: wrap instead of overflow
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 160,
                child: FilledButton.icon(
                  onPressed: _openCv,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View CV'),
                ),
              ),
              SizedBox(
                width: 160,
                child: OutlinedButton.icon(
                  onPressed: _downloadCv,
                  icon: const Icon(Icons.download),
                  label: const Text('Download PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.primary.withOpacity(0.08),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
