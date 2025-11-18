// lib/features/contact/view/contact_page.dart
//
// ContactPage
// -----------
// - Uses AppScaffold so AppBar / Drawer / theme are centralised.
// - Fetches SiteProfile from Supabase (name, email, phoneE164).
// - While data is loading → shows a full-page CircularProgressIndicator.
// - Once loaded:
//     • Builds a “Contact details” card using values from SiteProfile.
//     • If any of name/email/phone can't be derived, shows a small
//       "Loading contact details..." indicator inside that card instead.
// - Below the info card, shows the ContactFormPage in a themed card.

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
              // 🔹 Load a single profile row from Supabase
              future: repo.fetchProfile(),
              builder: (context, snapshot) {
                final theme = Theme.of(context);
                final textTheme = theme.textTheme;
                final colorScheme = theme.colorScheme;

                // 🔍 Debug log for connection state + high-level status
                debugPrint(
                  '[ContactPage] state=${snapshot.connectionState} '
                  'hasError=${snapshot.hasError} hasData=${snapshot.hasData}',
                );

                // ⏳ While the Future is still running, show a full-page loader
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                // ❌ If the Future completed with an error, log it.
                //     We still try to render the page below using null profile.
                if (snapshot.hasError) {
                  debugPrint('ContactPage error: ${snapshot.error}');
                }

                final profile = snapshot.data;

                if (profile == null) {
                  // No row found – card will use the "loading contact details"
                  // variant instead of hard-coded name/email/phone.
                  debugPrint(
                    '[ContactPage] profile is NULL – contact details will show loading indicator',
                  );
                } else {
                  // 🧾 Log core fields we care about for debugging.
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

                // Helper for safe values when profile != null.
                // If the DB string is null/empty, we return a placeholder
                // "loading" string, which will later trigger the loading state
                // inside the contact info card if any field is unusable.
                String valueOr(String? raw, String fallback) {
                  final v = raw?.trim();
                  if (v == null || v.isEmpty) return fallback;
                  return v;
                }

                // These remain null when profile == null; we use that
                // to decide whether to show the loading variant of the card.
                String? displayName;
                String? email;
                String? phone;

                if (profile != null) {
                  // 1) Name logic: prefer fullName if non-empty,
                  //    otherwise build "firstName lastName".
                  final fullName = profile.fullName.trim();
                  final firstName = valueOr(profile.firstName, 'loading');
                  final lastName = valueOr(profile.lastName, 'loading');

                  displayName = fullName.isNotEmpty
                      ? fullName
                      : '$firstName $lastName';

                  // 2) Email: trim the stored value; if empty, use "loading"
                  //    so we detect that it isn't ready for display yet.
                  final emailRaw = profile.email.trim();
                  email = emailRaw.isEmpty ? 'loading' : emailRaw;

                  // 3) Phone: use phoneE164 only.
                  //    If it's empty, we store "loading" to signal
                  //    that the value is not ready for display.
                  final phoneRaw = profile.phoneE164?.trim() ?? '';
                  phone = phoneRaw.isEmpty ? 'loading' : phoneRaw;
                }

                // 🧾 Log final values that will be passed into the card.
                //     If any of these is null, the card will show a small
                //     progress indicator instead of real contact info.
                debugPrint(
                  '========== [ContactPage display values] ==========',
                );
                debugPrint('displayName : ${displayName ?? '(null)'}');
                debugPrint('email       : ${email ?? '(null)'}');
                debugPrint('phone       : ${phone ?? '(null)'}');
                debugPrint('=================================================');

                // Decide what to show in the contact details card:
                // - If any of the three values is null → use the .loading()
                //   constructor, which shows a small spinner + "Loading contact details..."
                // - Otherwise → render the normal card with icons + text.
                Widget contactDetailsCard;
                if (displayName == null || email == null || phone == null) {
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

                // Final page layout:
                //  - Title + explanatory subtitle
                //  - Contact details card (name/email/phone/response time)
                //  - Contact form card ("Send a message")
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

                    // ⭐ Your info as a themed card (or a small loading row)
                    contactDetailsCard,

                    const SizedBox(height: 24),

                    // Message form card
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

/// Contact info card
/// -----------------
/// Has two modes:
///  - loading: shows a small spinner + "Loading contact details..."
///  - normal : shows name, email, phone + response time text.
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
            // 🔄 Loading variant: small spinner + "Loading contact details..."
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
            // ✅ Normal variant: actual contact info + response time
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

/// Single row with an icon + text, used inside the contact info card.
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
