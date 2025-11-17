// lib/features/contact/view/contact_page.dart
//
// Public Contact page.
// - Fetches SiteProfile from Supabase.
// - Shows name, tagline, email and phone.
// - Renders the ContactFormPage below for visitors to send a message.

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';
import 'contact_form_page.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
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
        debugPrint('ContactPage → id: ${profile?.id}');
        debugPrint(
          'ContactPage → name: ${profile?.firstName} ${profile?.lastName}',
        );
      }

      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ContactPage error: $e');
      }
      setState(() {
        _error = 'Unable to load contact details right now.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Me'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
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

    final first = _profile?.firstName ?? '';
    final last = _profile?.lastName ?? '';
    final fullName = (first + ' ' + last).trim().isEmpty
        ? 'Your Name'
        : '$first $last';

    final tagline = _profile?.tagline?.isNotEmpty == true
        ? _profile!.tagline!
        : 'Let’s build something great together.';

    final email = _profile?.email ?? 'your.email@example.com';
    final phone = _profile?.phoneE164 ?? '+44 0000 000000';

    // 🔹 Simple, safe layout: card on top, form below (looks good on all sizes)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProfileCard(context, fullName, tagline, email, phone),
        const SizedBox(height: 24),
        const ContactFormPage(),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    String fullName,
    String tagline,
    String email,
    String phone,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.surfaceVariant, colorScheme.surface],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let’s talk',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(fullName, style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(tagline, style: textTheme.bodyMedium),
            const SizedBox(height: 20),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(phone, style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'I usually reply within 24–48 hours.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
