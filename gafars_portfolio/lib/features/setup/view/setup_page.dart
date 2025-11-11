// lib/features/setup/view/setup_page.dart
// DEV-ONLY one-time form to seed the `site_profile` table.
// Adds: connection health check + client banner + dev logs + retry.
//
// Client-facing behavior:
//  - Shows a green "Connected" or red "Can’t reach server" banner with a Retry.
//  - Keeps existing form + "Saving..." overlay.
// Dev-facing behavior:
//  - Prints the real exception + stack to console for diagnosis.
//  - Shows a short technical hint under the banner in small text.

import 'package:flutter/material.dart';
import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = ProfileRepository();

  // Controllers for the fields we care about
  final _fullName = TextEditingController();
  final _title = TextEditingController(text: 'Flutter Developer');
  final _email = TextEditingController();
  final _tagline = TextEditingController();
  final _aboutMd = TextEditingController();
  final _phone = TextEditingController();
  final _linkedin = TextEditingController();
  final _cvUrl = TextEditingController();
  final _github = TextEditingController();
  final _twitter = TextEditingController();
  final _website = TextEditingController();
  final _location = TextEditingController();
  final _avatarUrl = TextEditingController();

  bool _loading = true; // initial read
  bool _saving = false; // upsert in progress
  String? _status; // success / error message (form save)

  // Connection health state
  bool _checkingConn = true;
  bool _healthOk = false;
  String? _healthErr; // dev hint line (short)

  @override
  void initState() {
    super.initState();
    _init(); // health check + load prefill
  }

  Future<void> _init() async {
    await _checkConnection(); // set banners
    await _loadExisting(); // prefill if any
  }

  /// Pings Supabase by performing a small SELECT with a short timeout.
  /// - Client: shows green/red banner.
  /// - Dev: prints full error to console for debugging.
  Future<void> _checkConnection() async {
    setState(() {
      _checkingConn = true;
      _healthOk = false;
      _healthErr = null;
    });

    try {
      // Small, cheap call. If table empty, it's still fine.
      await _repo.fetchProfile().timeout(const Duration(seconds: 8));
      _healthOk = true;
    } catch (e, st) {
      _healthOk = false;
      _healthErr = e.toString();
      // DEV LOGS (won’t show to client)
      // ignore: avoid_print
      print('[SupaHealth] Connection check failed: $e\n$st');
    } finally {
      if (mounted) setState(() => _checkingConn = false);
    }
  }

  Future<void> _loadExisting() async {
    try {
      final existing = await _repo.fetchProfile();
      if (existing != null) {
        _fullName.text = existing.fullName;
        _title.text = existing.title;
        _email.text = existing.email;
        _tagline.text = existing.tagline ?? '';
        _aboutMd.text = existing.aboutMd ?? '';
        _phone.text = existing.phone ?? '';
        _linkedin.text = existing.linkedin ?? '';
        _cvUrl.text = existing.cvUrl ?? '';
        _github.text = existing.github ?? '';
        _twitter.text = existing.twitter ?? '';
        _website.text = existing.website ?? '';
        _location.text = existing.location ?? '';
        _avatarUrl.text = existing.avatarUrl ?? '';
      }
    } catch (e, st) {
      // Dev log but don’t crash the UI
      // ignore: avoid_print
      print('[SetupPrefill] Failed to fetch profile: $e\n$st');
      _status = 'Failed to load existing profile. You can still submit.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _fullName,
      _title,
      _email,
      _tagline,
      _aboutMd,
      _phone,
      _linkedin,
      _cvUrl,
      _github,
      _twitter,
      _website,
      _location,
      _avatarUrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _status = null;
    });

    try {
      final p = SiteProfile(
        id: 'seed', // ignored on insert; DB will generate a real id
        fullName: _fullName.text.trim(),
        title: _title.text.trim(),
        email: _email.text.trim(),
        tagline: _emptyToNull(_tagline.text),
        aboutMd: _emptyToNull(_aboutMd.text),
        phone: _emptyToNull(_phone.text),
        linkedin: _emptyToNull(_linkedin.text),
        cvUrl: _emptyToNull(_cvUrl.text),
        github: _emptyToNull(_github.text),
        twitter: _emptyToNull(_twitter.text),
        website: _emptyToNull(_website.text),
        location: _emptyToNull(_location.text),
        avatarUrl: _emptyToNull(_avatarUrl.text),
      );

      await _repo.upsertProfile(p);
      setState(() => _status = '✅ Saved! One-time seeding complete.');
    } catch (e, st) {
      // If temp write policies were already dropped, this is likely a 401/403.
      // Client message stays generic; dev gets full error in console.
      // ignore: avoid_print
      print('[SetupSave] Upsert failed: $e\n$st');
      setState(
        () => _status =
            '❌ Save failed. If you already dropped TEMP policies, re-enable them, save once, then drop again.',
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  @override
  Widget build(BuildContext context) {
    // Initial load spinner
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Setup (Dev Only)')),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ConnectionBanner(
                        checking: _checkingConn,
                        ok: _healthOk,
                        devHint: _healthErr,
                        onRetry: _checkConnection,
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Seed your public profile (stored in site_profile).',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Required fields
                      _LabeledField(
                        label: 'Full name *',
                        controller: _fullName,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      _LabeledField(
                        label: 'Title *',
                        controller: _title,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      _LabeledField(
                        label: 'Email *',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),

                      // Optional fields
                      _LabeledField(label: 'Tagline', controller: _tagline),
                      _LabeledField(
                        label: 'About (Markdown)',
                        controller: _aboutMd,
                        maxLines: 6,
                        hint: 'Write your bio in **Markdown**',
                      ),
                      _LabeledField(label: 'Phone', controller: _phone),
                      _LabeledField(
                        label: 'LinkedIn URL',
                        controller: _linkedin,
                      ),
                      _LabeledField(label: 'GitHub URL', controller: _github),
                      _LabeledField(
                        label: 'Twitter/X URL',
                        controller: _twitter,
                      ),
                      _LabeledField(label: 'Website URL', controller: _website),
                      _LabeledField(
                        label: 'Location',
                        controller: _location,
                        hint: 'e.g., Lagos, Nigeria',
                      ),
                      _LabeledField(
                        label: 'Avatar URL',
                        controller: _avatarUrl,
                      ),
                      _LabeledField(label: 'CV URL', controller: _cvUrl),

                      const SizedBox(height: 12),
                      if (_status != null)
                        Text(
                          _status!,
                          style: TextStyle(
                            color: _status!.startsWith('✅')
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _saving ? 'Saving...' : 'Save profile (upsert)',
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Dev tip: After you save once, remove TEMP write policies in Supabase (SQL):\n'
                        'drop policy if exists "allow_upsert_profile_from_anon_temp" on public.site_profile;\n'
                        'drop policy if exists "allow_update_profile_from_anon_temp" on public.site_profile;',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Saving overlay (dim screen a bit while saving)
          if (_saving)
            Container(
              color: Colors.black.withOpacity(0.04),
              alignment: Alignment.center,
            ),
        ],
      ),
    );
  }
}

// ---- UI Bits ----

class _ConnectionBanner extends StatelessWidget {
  final bool checking;
  final bool ok;
  final String? devHint;
  final VoidCallback onRetry;

  const _ConnectionBanner({
    required this.checking,
    required this.ok,
    required this.devHint,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    String msg;

    if (checking) {
      bg = Colors.blue.shade50;
      msg = 'Checking Supabase connection…';
    } else if (ok) {
      bg = Colors.green.shade50;
      msg = 'Connected to Supabase';
    } else {
      bg = Colors.red.shade50;
      msg = 'Can’t reach Supabase. Please check your internet or try again.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(msg)),
              const SizedBox(width: 12),
              TextButton(
                onPressed: checking ? null : onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
          if (!checking && !ok && devHint != null && devHint!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Dev hint: $devHint',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

// Small labeled text field widget to keep the page tidy.
class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
