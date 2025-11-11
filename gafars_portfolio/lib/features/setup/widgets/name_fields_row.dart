// lib/features/setup/widgets/name_fields_row.dart
//
// NameFieldsRow
// - A single row containing First*, Middle, Last* name inputs.
// - Uses LabeledField for consistent look/validation.
//
// Why separate?
// - Keeps SetupPage short.
// - Easy to reuse for other admin pages later.

import 'package:flutter/material.dart';
import 'labeled_field.dart';

class NameFieldsRow extends StatelessWidget {
  final TextEditingController first;
  final TextEditingController middle;
  final TextEditingController last;

  const NameFieldsRow({
    super.key,
    required this.first,
    required this.middle,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LabeledField(
            label: 'First name *',
            controller: first,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LabeledField(label: 'Middle name', controller: middle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LabeledField(
            label: 'Last name *',
            controller: last,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}
