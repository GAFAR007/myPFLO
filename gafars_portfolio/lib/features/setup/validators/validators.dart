// lib/features/setup/validators/validators.dart
// Small, reusable validators + helpers for the Setup form.

/// Basic "required" validator – trims whitespace.
String? requiredValidator(String? v, {String label = 'This field'}) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return '$label is required';
  return null;
}

/// Email validator with optional required flag.
String? emailValidator(String? v, {bool required = false}) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return required ? 'Email is required' : null;

  // Light email check: text@text(.text)
  final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!re.hasMatch(t)) return 'Enter a valid email';
  return null;
}

/// URL validator with optional required flag.
String? urlValidator(String? v, {bool required = false}) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return required ? 'URL is required' : null;

  final uri = Uri.tryParse(t);
  if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
    return 'Enter a valid URL (https://...)';
  }
  return null;
}

/// Keep leading + and digits only; used to clean pasted phone strings
/// into a proper E.164 candidate string.
String cleanE164(String input) {
  final buf = StringBuffer();
  for (final ch in input.runes.map(String.fromCharCode)) {
    if (ch == '+' && buf.isEmpty) {
      // allow a single leading +
      buf.write('+');
    } else if (RegExp(r'\d').hasMatch(ch)) {
      // keep digits only
      buf.write(ch);
    }
  }
  return buf.toString();
}

/// Validate full E.164 string (+ then 8–15 digits).
/// Example: +447881169965
String? phoneE164Validator(String? v, {bool required = false}) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return required ? 'Phone is required' : null;

  final re = RegExp(r'^\+[0-9]{8,15}$');
  if (!re.hasMatch(t)) {
    return 'Use E.164 format, e.g. +2348012345678';
  }
  return null;
}

/// Validate the *national* part of the phone number (without country code).
/// - No spaces or symbols
/// - 9–10 digits (works for UK mobile pattern you're using)
String? nationalNumberValidator(String? v) {
  final t = v?.trim() ?? '';

  if (t.isEmpty) return 'Enter phone number';
  if (t.length < 9 || t.length > 10) return 'Enter 9–10 digits';

  if (!RegExp(r'^[0-9]+$').hasMatch(t)) {
    return 'Digits only';
  }

  return null; // valid
}
