// lib/features/setup/widgets/labeled_field.dart
//
// LabeledField (extended)
// - Reusable text field with label, hint, validation, and extras:
//   onChanged, readOnly, suffixIcon, inputFormatters, initialValue,
//   textInputAction, and obscureText (for passwords if ever needed).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledField extends StatelessWidget {
  /// The visible label for the input (InputDecoration.labelText).
  final String label;

  /// Text controller owned by the parent (create & dispose in parent State).
  final TextEditingController controller;

  /// Optional gray placeholder.
  final String? hint;

  /// Single or multi-line input.
  final int maxLines;

  /// Form validator (return error text or null when valid).
  final String? Function(String?)? validator;

  /// Keyboard type (email, number, phone, etc.).
  final TextInputType? keyboardType;

  /// Called whenever the text changes.
  final ValueChanged<String>? onChanged;

  /// If true, field is non-editable (still selectable).
  final bool readOnly;

  /// Optional icon at the right (e.g., clear, calendar, visibility toggle).
  final Widget? suffixIcon;

  /// Optional input formatters (e.g., FilteringTextInputFormatter.digitsOnly).
  final List<TextInputFormatter>? inputFormatters;

  /// Initial text if you don’t want to mutate controller before build.
  /// (If provided, it sets controller.text if empty.)
  final String? initialValue;

  /// Allows controlling the action button on the keyboard (next/done/search…).
  final TextInputAction? textInputAction;

  /// Obscure text (handy if you reuse this widget for secrets later).
  final bool obscureText;

  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.readOnly = false,
    this.suffixIcon,
    this.inputFormatters,
    this.initialValue,
    this.textInputAction,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    // Set controller text once if caller provided initialValue and controller is empty.
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue!;
      // Move cursor to end so it feels natural.
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }

    return Padding(
      // Vertical rhythm so stacked fields don’t collide.
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: obscureText
            ? 1
            : maxLines, // Obscured fields should stay single-line.
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        readOnly: readOnly,
        textInputAction: textInputAction,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
