// lib/features/setup/view/setup_page.dart
//
// Admin-only Setup screen to seed / edit your public profile
// in the `site_profile` table. This page is protected by AuthGate,
// so only a logged-in admin user can see it.

import 'package:flutter/material.dart';

// --- Data layer (Supabase repositories + models) ---
import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';
import '../../../data/supabase/supabase_client.dart';

// --- Widgets (small reusable UI building blocks) ---
import '../widgets/connection_banner.dart';
import '../widgets/labeled_field.dart';
import '../widgets/name_fields_row.dart';
import '../widgets/dob_field.dart';
import '../widgets/phone_country_field.dart';
import '../widgets/avatar_upload_field.dart';
import '../widgets/cv_upload_field.dart';

// --- Validators (simple pure functions) ---
import '../validators/validators.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  /// Global key for the form – lets us call `validate()` etc.
  final _formKey = GlobalKey<FormState>();

  /// Repository that talks to Supabase for the `site_profile` table.
  final _repo = ProfileRepository();

  // --------------------------------------------------
  // Controllers & state fields
  // --------------------------------------------------

  // Supabase row id for site_profile (uuid in your DB)
  String? _profileId;

  // Name parts
  final _first = TextEditingController();
  final _middle = TextEditingController();
  final _last = TextEditingController();

  // Date of birth (not a TextEditingController)
  DateTime? _dob;

  // Core fields
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
  bool _loading = true; // page-level loading (health + prefill)
  bool _saving = false; // saving state for the submit button
  String? _status; // text under the form (success / error)

  // Connection banner + health check
  bool _checkingConn = true;
  bool _healthOk = false;
  String? _healthErr;

  @override
  void initState() {
    super.initState();
    // When the widget mounts, run a health check and prefill the form.
    _init();
  }

  /// High-level init: check Supabase connection and prefill existing profile.
  Future<void> _init() async {
    await _checkConnection();
    await _prefill();
  }

  /// Quick health check – pings Supabase using `fetchProfile`.
  ///
  /// This is mainly for developer feedback: if something is wrong with the
  /// connection or RLS, we show it at the top of the screen.
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
      if (mounted) {
        setState(() => _checkingConn = false);
      }
    }
  }

  /// Prefill the form if a profile already exists in Supabase.
  ///
  /// This lets you revisit the page later and edit, instead of always
  /// starting from an empty form.
  Future<void> _prefill() async {
    try {
      final p = await _repo.fetchProfile();
      if (p != null) {
        // Save the REAL Supabase id for this row (uuid)
        _profileId = p.id;
        print('[SetupPrefill] Loaded site_profile row with id=$_profileId');

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
        _cvUrl.text = p.cvUrl ?? ''; // prefill CV URL
        _github.text = p.github ?? '';
        _twitter.text = p.twitter ?? '';
        _website.text = p.website ?? '';
        _location.text = p.location ?? '';
        _avatarUrl.text = p.avatarUrl ?? ''; // prefill Avatar URL
      } else {
        print('[SetupPrefill] No site_profile row yet – form is empty.');
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('[SetupPrefill] failed: $e\n$st');
      _status = 'Failed to load existing profile. You can still submit.';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// Helper: turns empty strings into `null` so we don’t store "" in the DB.
  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  /// Build a SiteProfile from the current form controllers.
  ///
  /// Used by the big "Save profile (upsert)" button.
  SiteProfile _buildProfileFromForm() {
    // Build full name from parts (no extra spaces between empties).
    final fullName = [
      _first.text.trim(),
      _middle.text.trim(),
      _last.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    return SiteProfile(
      // ✅ Use the REAL Supabase id if we have one.
      // If this is the very first time, id may be null – toMap() does not
      // include id, so Supabase will generate a new uuid.
      id: _profileId ?? '',
      fullName: fullName,
      title: _title.text.trim(),
      email: _email.text.trim(),
      tagline: _emptyToNull(_tagline.text),
      aboutMd: _emptyToNull(_aboutMd.text),
      phoneE164: _emptyToNull(_phoneE164.text),
      linkedin: _emptyToNull(_linkedin.text),
      cvUrl: _emptyToNull(_cvUrl.text),
      github: _emptyToNull(_github.text),
      twitter: _emptyToNull(_twitter.text),
      website: _emptyToNull(_website.text),
      location: _emptyToNull(_location.text),
      avatarUrl: _emptyToNull(_avatarUrl.text),
      firstName: _emptyToNull(_first.text),
      middleName: _emptyToNull(_middle.text),
      lastName: _emptyToNull(_last.text),
      dateOfBirth: _dob,
    );
  }

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

  /// Full save (used by the big button at the bottom).
  Future<void> _save() async {
    // Validate all form fields first.
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _status = null;
    });

    try {
      final p = _buildProfileFromForm();
      await _repo.upsertProfile(p);

      setState(
        () => _status = '✅ Saved! Profile is now ready for the public site.',
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('[SetupSave] upsert failed: $e\n$st');
      setState(
        () => _status =
            '❌ Save failed. Check Supabase policies / connection and try again.',
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  /// Partial update – updates ONLY the fields you pass in.
  Future<void> _saveSection(Map<String, dynamic> fields, String label) async {
    // ---------- DEBUG LOG #1 ----------
    print('--------------------------------------------------');
    print('[DEBUG] Update section pressed: "$label"');
    print('[DEBUG] Fields being sent to Supabase:');
    fields.forEach((k, v) => print('   $k: $v'));

    setState(() {
      _saving = true;
      _status = null;
    });

    try {
      await _repo.updateFields(fields);

      // ---------- DEBUG LOG #2 ----------
      print('[DEBUG] Supabase updateFields() completed successfully.');
      print('[DEBUG] Section "$label" updated with: $fields');
      print('--------------------------------------------------');

      setState(() {
        _status = '✅ $label updated.';
      });
    } catch (e, st) {
      // ---------- DEBUG LOG #3 ----------
      print('[ERROR] Failed to update "$label"');
      print('[ERROR] Exception: $e');
      print('[ERROR] Stacktrace: $st');
      print('--------------------------------------------------');

      setState(() {
        _status = '❌ Failed to update $label.';
      });
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

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup (Dev Only)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              // 1) Sign out from Supabase (clears the session)
              await Supa.client.auth.signOut();

              // 2) Navigate back to the public home page ('/')
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/', // route name for HomePage
                (route) => false, // clear previous navigation stack
              );
            },
          ),
        ],
      ),
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
                      // ----------------------------------------------
                      // Connection / health banner
                      // ----------------------------------------------
                      ConnectionBanner(
                        checking: _checkingConn,
                        ok: _healthOk,
                        devHint: _healthErr,
                        onRetry: _checkConnection,
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Seed your public profile (stored in site_profile).',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Main card – matches ProfilePage vibe
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ------------------------------------------
                              // BASIC INFORMATION
                              // ------------------------------------------
                              Text(
                                'Basic information',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),

                              NameFieldsRow(
                                first: _first,
                                middle: _middle,
                                last: _last,
                              ),
                              const SizedBox(height: 8),
                              DobField(
                                initial: _dob,
                                onChanged: (d) => _dob = d,
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _saveSection({
                                          'first_name': _first.text.trim(),
                                          'middle_name': _middle.text.trim(),
                                          'last_name': _last.text.trim(),
                                          'date_of_birth': _dob == null
                                              ? null
                                              : _dob!
                                                    .toIso8601String()
                                                    .split('T')
                                                    .first,
                                        }, 'Basic information'),
                                  icon: const Icon(
                                    Icons.save_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Update section'),
                                ),
                              ),

                              const Divider(height: 24),

                              // ------------------------------------------
                              // CORE FIELDS (Title + Email)
                              // ------------------------------------------
                              Text(
                                'Core profile',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),

                              LabeledField(
                                label: 'Title *',
                                controller: _title,
                                validator: (v) =>
                                    requiredValidator(v, label: 'Title'),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _saveSection({
                                          'title': _title.text.trim(),
                                        }, 'Title'),
                                  icon: const Icon(
                                    Icons.save_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Update title'),
                                ),
                              ),

                              LabeledField(
                                label: 'Email *',
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                    emailValidator(v, required: true),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _saveSection({
                                          'email': _email.text.trim(),
                                        }, 'Email'),
                                  icon: const Icon(
                                    Icons.save_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Update email'),
                                ),
                              ),

                              const Divider(height: 24),

                              // ------------------------------------------
                              // ABOUT / TAGLINE
                              // ------------------------------------------
                              Text(
                                'About & tagline',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),

                              LabeledField(
                                label: 'Tagline',
                                controller: _tagline,
                              ),
                              LabeledField(
                                label: 'About (Markdown)',
                                controller: _aboutMd,
                                maxLines: 6,
                                hint: 'Write your bio in **Markdown**',
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _saveSection({
                                          'tagline': _emptyToNull(
                                            _tagline.text,
                                          ),
                                          'about_md': _emptyToNull(
                                            _aboutMd.text,
                                          ),
                                        }, 'About & tagline'),
                                  icon: const Icon(
                                    Icons.save_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Update section'),
                                ),
                              ),

                              const Divider(height: 24),

                              // ------------------------------------------
                              // CONTACT
                              // ------------------------------------------
                              Text(
                                'Contact',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),

                              PhoneCountryField(controller: _phoneE164),

                              LabeledField(
                                label: 'Website URL',
                                controller: _website,
                                validator: urlValidator,
                              ),
                              LabeledField(
                                label: 'Location',
                                controller: _location,
                                hint: 'e.g., Wolverhampton, United Kingdom',
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _saveSection({
                                          'phone_e164': _emptyToNull(
                                            _phoneE164.text,
                                          ),
                                          'website': _emptyToNull(
                                            _website.text,
                                          ),
                                          'location': _emptyToNull(
                                            _location.text,
                                          ),
                                        }, 'Contact'),
                                  icon: const Icon(
                                    Icons.save_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Update section'),
                                ),
                              ),

                              const Divider(height: 24),

                              // ------------------------------------------
                              // SOCIAL
                              // ------------------------------------------
                              Text(
                                'Social links',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),

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

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _saveSection({
                                          'linkedin': _emptyToNull(
                                            _linkedin.text,
                                          ),
                                          'github': _emptyToNull(_github.text),
                                          'twitter': _emptyToNull(
                                            _twitter.text,
                                          ),
                                        }, 'Social links'),
                                  icon: const Icon(
                                    Icons.save_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Update section'),
                                ),
                              ),

                              const Divider(height: 24),

                              // ------------------------------------------
                              // MEDIA (Avatar + CV)
                              // ------------------------------------------
                              Text(
                                'Profile media',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Avatar uploader (writes URL into _avatarUrl)
                              AvatarUploadField(controller: _avatarUrl),
                              const SizedBox(height: 12),

                              // CV uploader (writes URL into _cvUrl)
                              CvUploadField(controller: _cvUrl),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _saveSection({
                                          'avatar_url': _emptyToNull(
                                            _avatarUrl.text,
                                          ),
                                          'cv_url': _emptyToNull(_cvUrl.text),
                                        }, 'Profile media'),
                                  icon: const Icon(
                                    Icons.save_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Update section'),
                                ),
                              ),

                              const SizedBox(height: 16),

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

                              // Save button (full upsert)
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
                                  _saving
                                      ? 'Saving...'
                                      : 'Save profile (upsert)',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),

                      const Text(
                        'Dev note: This page is for admin use only. '
                        'Public visitors will read from site_profile via the '
                        'Home / About / Projects pages.',
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
