// lib/features/contact/view/contact_page.dart
//
// Public ContactPage – uses AppScaffold and embeds ContactFormPage.
// - Fetches SiteProfile from Supabase for name/email/phone.
// - Shows your real contact details in a themed card + response time,
//   then the contact form in another card.

import 'package:flutter/material.dart';

import '../../shell/app_scaffold.dart';
import 'contact_form_page.dart';
import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();

    return AppScaffold(
      title: 'Contact • Gafars Technologies',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: FutureBuilder<SiteProfile?>(
              future: repo.fetchProfile(),
              builder: (context, snapshot) {
                final theme = Theme.of(context);
                final textTheme = theme.textTheme;
                final colorScheme = theme.colorScheme;

                // 🔍 General state log
                debugPrint(
                  '[ContactPage] state=${snapshot.connectionState} '
                  'hasError=${snapshot.hasError} hasData=${snapshot.hasData}',
                );

                // ⏳ While the future is still running, show page-level loader
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                // ❌ Error – log it but still render page
                if (snapshot.hasError) {
                  debugPrint('ContactPage error: ${snapshot.error}');
                }

                final profile = snapshot.data;

                if (profile == null) {
                  debugPrint(
                    '[ContactPage] profile is NULL – contact details will show loading indicator',
                  );
                } else {
                  // 🧾 Log what we got from Supabase
                  debugPrint(
                    '========== [ContactPage Supabase profile] ==========',
                  );
                  debugPrint('id        : ${profile.id}');
                  debugPrint('fullName  : ${profile.fullName}');
                  debugPrint('firstName : ${profile.firstName}');
                  debugPrint('lastName  : ${profile.lastName}');
                  debugPrint('email     : ${profile.email}');
                  debugPrint('phoneE164 : ${profile.phoneE164}');
                  debugPrint('phone     : ${profile.phone}');
                  debugPrint(
                    '====================================================',
                  );
                }

                // Helper for safe values (only used when profile != null)
                String valueOr(String? raw, String fallback) {
                  final v = raw?.trim();
                  if (v == null || v.isEmpty) return fallback;
                  return v;
                }

                // These will stay null if profile is null
                String? displayName;
                String? email;
                String? phone;

                if (profile != null) {
                  final fullName = profile.fullName.trim();
                  final firstName = valueOr(profile.firstName, 'Gafar');
                  final lastName = valueOr(profile.lastName, 'Razak');

                  displayName = fullName.isNotEmpty
                      ? fullName
                      : '$firstName $lastName';

                  final emailRaw = profile.email.trim();
                  email = emailRaw.isEmpty
                      ? 'razakgafar98@outlook.com'
                      : emailRaw;

                  // Prefer E.164, then legacy phone, then fallback
                  final phoneRaw =
                      (profile.phoneE164 ?? profile.phone)?.trim() ?? '';
                  phone = phoneRaw.isEmpty ? '+44 7881 169 965' : phoneRaw;
                }

                // 🧾 Log final values (can be null if profile null)
                debugPrint(
                  '========== [ContactPage display values] ==========',
                );
                debugPrint('displayName : ${displayName ?? '(null)'}');
                debugPrint('email       : ${email ?? '(null)'}');
                debugPrint('phone       : ${phone ?? '(null)'}');
                debugPrint('=================================================');

                // Decide what to show in the contact details card
                Widget contactDetailsCard;
                if (displayName == null || email == null || phone == null) {
                  // ❗Profile missing → show a small loading row in the card
                  contactDetailsCard = _ContactInfoCard.loading(
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  );
                } else {
                  contactDetailsCard = _ContactInfoCard(
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                    name: displayName,
                    email: email,
                    phone: phone,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Let’s build something together',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share a bit about your project, role, or idea and I’ll get back to you.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // ⭐ NEW: your info as a themed card
                    contactDetailsCard,

                    const SizedBox(height: 24),

                    // Existing message form card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: colorScheme.surfaceVariant.withOpacity(
                            theme.brightness == Brightness.dark ? 0.9 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const ContactFormPage(),
                      ),
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

class _ContactInfoCard extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final String? name;
  final String? email;
  final String? phone;
  final bool isLoading;

  const _ContactInfoCard({
    required this.textTheme,
    required this.colorScheme,
    this.name,
    this.email,
    this.phone,
  }) : isLoading = false;

  const _ContactInfoCard.loading({
    required this.textTheme,
    required this.colorScheme,
  }) : name = null,
       email = null,
       phone = null,
       isLoading = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colorScheme.surfaceVariant.withOpacity(
            theme.brightness == Brightness.dark ? 0.9 : 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading contact details...',
                    style: textTheme.bodySmall,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact details',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: name ?? '',
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: email ?? '',
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: phone ?? '',
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'I usually respond within 24–48 hours.',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextTheme textTheme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: textTheme.bodySmall)),
      ],
    );
  }
}
