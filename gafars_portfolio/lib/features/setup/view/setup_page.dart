// lib/features/setup/view/setup_page.dart
import 'package:flutter/material.dart';

// data
import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';

// widgets
import '../widgets/connection_banner.dart';
import '../widgets/labeled_field.dart';
import '../widgets/name_fields_row.dart';
import '../widgets/dob_field.dart';
import '../widgets/phone_country_field.dart';
import '../widgets/avatar_upload_field.dart';
import '../widgets/cv_upload_field.dart';

// validators
import '../validators/validators.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  /// Global key for the form – lets us call `validate()` and `save()`.
  final _formKey = GlobalKey<FormState>();

  /// Repository that talks to Supabase for the `site_profile` table.
  final _repo = ProfileRepository();

  // ----------------------------
  // Controllers & state fields
  // ----------------------------

  // Name parts
  final _first = TextEditingController();
  final _middle = TextEditingController();
  final _last = TextEditingController();

  // Date of birth (not a TextEditingController)
  DateTime? _dob;

  // Core fields (we removed _fullName – it’s computed from parts)
  final _title = TextEditingController(text: 'Flutter Developer');
  final _email = TextEditingController();

  // Optional text fields
  final _tagline = TextEditingController();
  final _aboutMd = TextEditingController();
  final _phoneE164 = TextEditingController(); // stored in E.164 format only
  final _linkedin = TextEditingController();
  final _cvUrl = TextEditingController();
  final _github = TextEditingController();
  final _twitter = TextEditingController();
  final _website = TextEditingController();
  final _location = TextEditingController();
  final _avatarUrl = TextEditingController();

  // Loading / saving + status message
  bool _loading = true;
  bool _saving = false;
  String? _status;

  // Connection banner + health check
  bool _checkingConn = true;
  bool _healthOk = false;
  String? _healthErr;

  @override
  void initState() {
    super.initState();
    _init(); // kick off connection check + prefill once widget mounts
  }

  /// High-level init: check Supabase connection and prefill existing profile.
  Future<void> _init() async {
    await _checkConnection();
    await _prefill();
  }

  /// Quick health check – pings Supabase using `fetchProfile`.
  Future<void> _checkConnection() async {
    setState(() {
      _checkingConn = true;
      _healthOk = false;
      _healthErr = null;
    });
    try {
      await _repo.fetchProfile().timeout(const Duration(seconds: 8));
      _healthOk = true;
    } catch (e, st) {
      _healthOk = false;
      _healthErr = e.toString();
      // ignore: avoid_print
      print('[SupaHealth] check failed: $e\n$st');
    } finally {
      if (mounted) setState(() => _checkingConn = false);
    }
  }

  /// Prefill the form if a profile already exists in Supabase.
  Future<void> _prefill() async {
    try {
      final p = await _repo.fetchProfile();
      if (p != null) {
        // Name parts
        _first.text = p.firstName ?? '';
        _middle.text = p.middleName ?? '';
        _last.text = p.lastName ?? '';
        _dob = p.dateOfBirth;

        // Core
        _title.text = p.title;
        _email.text = p.email;

        // Optional
        _tagline.text = p.tagline ?? '';
        _aboutMd.text = p.aboutMd ?? '';
        _phoneE164.text = p.phoneE164 ?? '';
        _linkedin.text = p.linkedin ?? '';
        _cvUrl.text = p.cvUrl ?? ''; // 👈 prefill CV URL
        _github.text = p.github ?? '';
        _twitter.text = p.twitter ?? '';
        _website.text = p.website ?? '';
        _location.text = p.location ?? '';
        _avatarUrl.text = p.avatarUrl ?? ''; // 👈 prefill Avatar URL
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('[SetupPrefill] failed: $e\n$st');
      _status = 'Failed to load existing profile. You can still submit.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Helper: turns empty strings into `null` so we don’t store empty text.
  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  @override
  void dispose() {
    // Dispose all controllers to avoid memory leaks.
    for (final c in [
      _first,
      _middle,
      _last,
      _title,
      _email,
      _tagline,
      _aboutMd,
      _phoneE164,
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

  /// Builds a `SiteProfile` object and upserts it to Supabase.
  Future<void> _save() async {
    // Validate all form fields first.
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _status = null;
    });

    try {
      // Build full name from parts (no extra spaces between empties).
      final fullName = [
        _first.text.trim(),
        _middle.text.trim(),
        _last.text.trim(),
      ].where((s) => s.isNotEmpty).join(' ');

      // Create the SiteProfile model expected by ProfileRepository.
      final p = SiteProfile(
        id: 'seed', // ignored on insert – repository should handle real IDs
        fullName: fullName,
        title: _title.text.trim(),
        email: _email.text.trim(),
        tagline: _emptyToNull(_tagline.text),
        aboutMd: _emptyToNull(_aboutMd.text),
        phoneE164: _emptyToNull(_phoneE164.text),
        linkedin: _emptyToNull(_linkedin.text),
        cvUrl: _emptyToNull(_cvUrl.text), // 👈 CV URL from upload field
        github: _emptyToNull(_github.text),
        twitter: _emptyToNull(_twitter.text),
        website: _emptyToNull(_website.text),
        location: _emptyToNull(_location.text),
        avatarUrl: _emptyToNull(
          _avatarUrl.text,
        ), // 👈 Avatar URL from upload field
        firstName: _emptyToNull(_first.text),
        middleName: _emptyToNull(_middle.text),
        lastName: _emptyToNull(_last.text),
        dateOfBirth: _dob,
      );

      // Persist to Supabase.
      await _repo.upsertProfile(p);
      setState(() => _status = '✅ Saved! One-time seeding complete.');
    } catch (e, st) {
      // ignore: avoid_print
      print('[SetupSave] upsert failed: $e\n$st');
      setState(
        () => _status =
            '❌ Save failed. If you already dropped TEMP policies, re-enable them, save once, then drop again.',
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // While loading (health check + prefill), show a simple spinner.
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
                      // ----------------------------
                      // Connection / health banner
                      // ----------------------------
                      ConnectionBanner(
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

                      // ----------------------------
                      // Names + DOB
                      // ----------------------------
                      NameFieldsRow(
                        first: _first,
                        middle: _middle,
                        last: _last,
                      ),
                      const SizedBox(height: 8),
                      DobField(initial: _dob, onChanged: (d) => _dob = d),

                      // ----------------------------
                      // Required core fields
                      // ----------------------------
                      LabeledField(
                        label: 'Title *',
                        controller: _title,
                        validator: (v) => requiredValidator(v, label: 'Title'),
                      ),
                      LabeledField(
                        label: 'Email *',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => emailValidator(v, required: true),
                      ),

                      // ----------------------------
                      // Optional fields
                      // ----------------------------
                      LabeledField(label: 'Tagline', controller: _tagline),
                      LabeledField(
                        label: 'About (Markdown)',
                        controller: _aboutMd,
                        maxLines: 6,
                        hint: 'Write your bio in **Markdown**',
                      ),

                      // Phone (single input UX for E.164)
                      PhoneCountryField(controller: _phoneE164),

                      // Social + links
                      LabeledField(
                        label: 'LinkedIn URL',
                        controller: _linkedin,
                        validator: urlValidator,
                      ),
                      LabeledField(
                        label: 'GitHub URL',
                        controller: _github,
                        validator: urlValidator,
                      ),
                      LabeledField(
                        label: 'Twitter/X URL',
                        controller: _twitter,
                        validator: urlValidator,
                      ),
                      LabeledField(
                        label: 'Website URL',
                        controller: _website,
                        validator: urlValidator,
                      ),

                      // ----------------------------
                      // Profile media (Avatar + CV)
                      // ----------------------------
                      const SizedBox(height: 12),
                      const Text(
                        'Profile Media',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      /// Custom widget that handles picking/uploading an avatar
                      /// and writing the final public URL into `_avatarUrl`.
                      AvatarUploadField(controller: _avatarUrl),
                      const SizedBox(height: 12),

                      /// Custom widget that handles picking/uploading a CV
                      /// and writing the final public URL into `_cvUrl`.
                      CvUploadField(controller: _cvUrl),

                      // Location
                      const SizedBox(height: 12),
                      LabeledField(
                        label: 'Location',
                        controller: _location,
                        hint: 'e.g., Lagos, Nigeria',
                      ),

                      const SizedBox(height: 12),

                      // Status message (success or error)
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

                      // Save button
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

                      // Dev-only reminder about TEMP Supabase policies.
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

          // Light overlay while saving – prevents double taps.
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
