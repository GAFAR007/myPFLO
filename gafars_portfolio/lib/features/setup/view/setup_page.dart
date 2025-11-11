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

// validators
import '../validators/validators.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  // form + repo
  final _formKey = GlobalKey<FormState>();
  final _repo = ProfileRepository();

  // name parts
  final _first = TextEditingController();
  final _middle = TextEditingController();
  final _last = TextEditingController();

  // dob
  DateTime? _dob;

  // core (NOTE: removed _fullName)
  final _title = TextEditingController(text: 'Flutter Developer');
  final _email = TextEditingController();

  // optional
  final _tagline = TextEditingController();
  final _aboutMd = TextEditingController();
  final _phoneE164 = TextEditingController(); // E.164 only
  final _linkedin = TextEditingController();
  final _cvUrl = TextEditingController();
  final _github = TextEditingController();
  final _twitter = TextEditingController();
  final _website = TextEditingController();
  final _location = TextEditingController();
  final _avatarUrl = TextEditingController();

  // state
  bool _loading = true;
  bool _saving = false;
  String? _status;

  // connection banner
  bool _checkingConn = true;
  bool _healthOk = false;
  String? _healthErr;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkConnection();
    await _prefill();
  }

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

  Future<void> _prefill() async {
    try {
      final p = await _repo.fetchProfile();
      if (p != null) {
        _first.text = p.firstName ?? '';
        _middle.text = p.middleName ?? '';
        _last.text = p.lastName ?? '';
        _dob = p.dateOfBirth;

        _title.text = p.title;
        _email.text = p.email;

        _tagline.text = p.tagline ?? '';
        _aboutMd.text = p.aboutMd ?? '';
        _phoneE164.text = p.phoneE164 ?? '';
        _linkedin.text = p.linkedin ?? '';
        _cvUrl.text = p.cvUrl ?? '';
        _github.text = p.github ?? '';
        _twitter.text = p.twitter ?? '';
        _website.text = p.website ?? '';
        _location.text = p.location ?? '';
        _avatarUrl.text = p.avatarUrl ?? '';
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('[SetupPrefill] failed: $e\n$st');
      _status = 'Failed to load existing profile. You can still submit.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  @override
  void dispose() {
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _status = null;
    });

    try {
      // Build full name from parts (no extra spaces)
      final fullName = [
        _first.text.trim(),
        _middle.text.trim(),
        _last.text.trim(),
      ].where((s) => s.isNotEmpty).join(' ');

      final p = SiteProfile(
        id: 'seed', // ignored on insert
        fullName: fullName, // 👈 computed here
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

                      // Names + DOB
                      NameFieldsRow(
                        first: _first,
                        middle: _middle,
                        last: _last,
                      ),
                      const SizedBox(height: 8),
                      DobField(initial: _dob, onChanged: (d) => _dob = d),

                      // Required (no full-name field anymore)
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

                      // Optional
                      LabeledField(label: 'Tagline', controller: _tagline),
                      LabeledField(
                        label: 'About (Markdown)',
                        controller: _aboutMd,
                        maxLines: 6,
                        hint: 'Write your bio in **Markdown**',
                      ),

                      // Phone (single input UX)
                      PhoneCountryField(controller: _phoneE164),

                      // URLs
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
                      LabeledField(
                        label: 'Avatar URL',
                        controller: _avatarUrl,
                        validator: urlValidator,
                      ),
                      LabeledField(
                        label: 'CV URL',
                        controller: _cvUrl,
                        validator: urlValidator,
                      ),
                      LabeledField(
                        label: 'Location',
                        controller: _location,
                        hint: 'e.g., Lagos, Nigeria',
                      ),

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
