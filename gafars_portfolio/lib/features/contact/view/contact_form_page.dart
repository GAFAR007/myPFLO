// lib/features/contact/view/contact_form_page.dart
//
// ContactFormPage
// - Reusable form widget used on the public Contact page.
// - Collects name, email, subject (optional), and message.
// - Sends messages to Supabase via ContactRepository (contact_messages table).

import 'package:flutter/material.dart';

import '../../../data/supabase/contact_repository.dart';

class ContactFormPage extends StatefulWidget {
  const ContactFormPage({super.key});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  final _contactRepo = ContactRepository(); // 👈 talks to Supabase

  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final rawName = _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final subject = _subjectCtrl.text.trim();
      final messageBody = _messageCtrl.text.trim();

      // 🔹 Always split into firstName + lastName
      String firstName = '';
      String lastName = '';

      final parts = rawName.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }

      // Fallback in case somebody only types one name
      if (firstName.isEmpty) {
        firstName = 'Visitor';
      }

      // Your table only has one `message` column,
      // so we embed the subject at the top if present.
      final fullMessage = subject.isNotEmpty
          ? 'Subject: $subject\n\n$messageBody'
          : messageBody;

      // 🔻 Save into Supabase via ContactRepository
      await _contactRepo.submitContact(
        firstName: firstName,
        lastName: lastName,
        email: email,
        message: fullMessage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully.')),
      );

      _formKey.currentState!.reset();
      _nameCtrl.clear();
      _emailCtrl.clear();
      _subjectCtrl.clear();
      _messageCtrl.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send a message', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Use the form below to get in touch about roles, projects, or collaborations.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),

              // Name (will be split into firstName + lastName)
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Please enter your email';
                  if (!v.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Subject (optional)
              TextFormField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(
                  labelText: 'Subject (optional)',
                  prefixIcon: Icon(Icons.topic_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // Message
              TextFormField(
                controller: _messageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.message_outlined),
                ),
                minLines: 4,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_submitting ? 'Sending…' : 'Send message'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
