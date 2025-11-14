// lib/features/contact/view/contact_page.dart
//
// Placeholder Contact page. Later this will submit to Supabase contact_messages.

import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Me')),
      body: const Center(
        child: Text(
          'Contact page coming soon.\n'
          'This will contain a form that saves messages to Supabase.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
