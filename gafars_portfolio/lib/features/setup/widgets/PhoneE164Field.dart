// lib/features/setup/widgets/phone_e164_field.dart
//
// PhoneE164Field
// - Reusable input that enforces E.164 (+ then digits, no spaces/dashes/letters)
// - Cleans pasted input live
// - Validates with a strict regex: ^\+[1-9]\d{7,14}$

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'labeled_field.dart';

class PhoneE164Field extends StatelessWidget {
  final TextEditingController controller;
  final bool required;

  const PhoneE164Field({
    super.key,
    required this.controller,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: required ? 'Phone (+ country code) *' : 'Phone (+ country code)',
      controller: controller,
      hint: 'e.g., +2348012345678',
      keyboardType: TextInputType.phone,
      // 1) Block everything except + and digits
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\+]+'))],
      // 2) Live-clean spaces/dashes/parentheses from paste or typing
      onChanged: (s) {
        final clean = s.replaceAll(RegExp(r'[ \-()]'), '');
        if (clean != s) {
          controller.value = controller.value.copyWith(
            text: clean,
            selection: TextSelection.collapsed(offset: clean.length),
          );
        }
      },
      // 3) Validate strict E.164 if provided (or required)
      validator: (v) {
        final s = (v ?? '').trim();
        if (s.isEmpty) {
          return required ? 'Required' : null;
        }
        final ok = RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(s);
        return ok ? null : 'Use E.164 (e.g., +2348012345678)';
      },
    );
  }
}
