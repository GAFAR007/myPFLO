// lib/features/setup/validators/validators.dart
// Small, reusable validators + helpers for the Setup form.

String? requiredValidator(String? v, {String label = 'This field'}) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return '$label is required';
  return null;
}

String? emailValidator(String? v, {bool required = false}) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return required ? 'Email is required' : null;
  // light email check: text@text(.text)
  final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!re.hasMatch(t)) return 'Enter a valid email';
  return null;
}

String? urlValidator(String? v, {bool required = false}) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return required ? 'URL is required' : null;
  final uri = Uri.tryParse(t);
  if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
    return 'Enter a valid URL (https://...)';
  }
  return null;
}

/// Keep leading + and digits only; used to clean pasted phone strings.
String cleanE164(String input) {
  final buf = StringBuffer();
  for (final ch in input.runes.map(String.fromCharCode)) {
    if (ch == '+' && buf.isEmpty) {
      buf.write('+');
    } else if (RegExp(r'\d').hasMatch(ch)) {
      buf.write(ch);
    }
  }
  return buf.toString();
}

/// Validate E.164 string (+ then 8–15 digits).
String? phoneE164Validator(String? v, {bool required = false}) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return required ? 'Phone is required' : null;
  final re = RegExp(r'^\+[0-9]{8,15}$');
  if (!re.hasMatch(t)) return 'Use E.164 format, e.g. +2348012345678';
  return null;
}
