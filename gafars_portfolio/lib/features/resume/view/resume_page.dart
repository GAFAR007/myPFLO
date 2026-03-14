import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/api/models/site_profile.dart';
import '../../../data/api/profile_repository.dart';
import '../../shell/app_scaffold.dart';
import '../../shell/public_page_frame.dart';

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
        debugPrint('ResumePage -> id: ${profile?.id}');
        debugPrint('ResumePage -> cvUrl: ${profile?.cvUrl}');
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong while loading the CV.';
        _loading = false;
      });
    }
  }

  Future<void> _openUrl(String? rawUrl, {bool download = false}) async {
    final cvUrl = rawUrl?.trim() ?? '';
    if (cvUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CV not available yet.')));
      return;
    }

    final uri = Uri.parse(
      download ? '$cvUrl?download=Gafar_Razak_CV.pdf' : cvUrl,
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open CV link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCv = _profile?.cvUrl?.trim().isNotEmpty == true;

    return AppScaffold(
      title: 'CV / Resume',
      body: PublicPageFrame(
        badge: 'Resume',
        title: 'A concise view of skills, projects, and professional range.',
        description:
            'If you want a faster scan than the full portfolio, this section is meant to give you the core signal quickly: what I build, how I work, and where I can add value.',
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? SurfacePanel(child: Text(_error!))
            : LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 900;

                  return Flex(
                    direction: stacked ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: stacked ? 0 : 5,
                        child: SurfacePanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What the CV covers',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'A snapshot across software engineering, product delivery, and management experience, with enough detail to make a hiring conversation concrete.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 20),
                              const Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  Chip(label: Text('Flutter')),
                                  Chip(label: Text('Node.js')),
                                  Chip(label: Text('MongoDB')),
                                  Chip(label: Text('Product UX')),
                                  Chip(label: Text('Leadership')),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const _ResumeBullet(
                                text:
                                    'Real project work across web and mobile product delivery.',
                              ),
                              const _ResumeBullet(
                                text:
                                    'Experience turning operational needs into practical software systems.',
                              ),
                              const _ResumeBullet(
                                text:
                                    'A mix of business context and engineering execution.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: stacked ? 0 : 20,
                        height: stacked ? 20 : 0,
                      ),
                      Expanded(
                        flex: stacked ? 0 : 4,
                        child: SurfacePanel(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 72,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gafar Temitayo Razak – CV',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                hasCv
                                    ? 'PDF hosted and ready to open.'
                                    : 'CV not uploaded yet.',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 22),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  FilledButton.icon(
                                    onPressed: hasCv
                                        ? () => _openUrl(_profile?.cvUrl)
                                        : null,
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('View CV'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: hasCv
                                        ? () => _openUrl(
                                            _profile?.cvUrl,
                                            download: true,
                                          )
                                        : null,
                                    icon: const Icon(Icons.download_rounded),
                                    label: const Text('Download PDF'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _ResumeBullet extends StatelessWidget {
  const _ResumeBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
