// lib/features/contact/view/contact_page.dart
//
// Public ContactPage – uses AppScaffold and embeds ContactFormPage.
// This keeps the layout consistent with Home, Resume, etc.

import 'package:flutter/material.dart';

import '../../shell/app_scaffold.dart';
import 'contact_form_page.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Contact • Gafars Technologies',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
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
                const SizedBox(height: 12),
                // 👇 NEW: your professional contact details + response time
                Text(
                  'You can also reach me directly at:\n'
                  'Gafar Temitayo Razak\n'
                  'Email: razakgafar98@outlook.com\n'
                  'Phone: +44 7881 169 965\n\n'
                  'I usually respond within 24–48 hours.',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ContactFormPage(), // 👈 your existing reusable form
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
