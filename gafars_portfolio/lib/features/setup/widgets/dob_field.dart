// lib/features/setup/widgets/dob_field.dart
//
// DobField
// - A small widget that shows a button-like input and opens a date picker.
// - Emits the picked DateTime back to the parent via onChanged.
// - Stores local state so the chosen date shows immediately.
//
// Notes:
// - Uses showDatePicker; on web it renders a dialog.
// - Serializing to DB is handled by the model (to YYYY-MM-DD).

import 'package:flutter/material.dart';

class DobField extends StatefulWidget {
  final DateTime? initial; // starting value (nullable)
  final ValueChanged<DateTime?> onChanged;

  const DobField({super.key, this.initial, required this.onChanged});

  @override
  State<DobField> createState() => _DobFieldState();
}

class _DobFieldState extends State<DobField> {
  DateTime? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final text = _value == null
        ? 'Select date'
        : '${_value!.year}-${_value!.month.toString().padLeft(2, '0')}-${_value!.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date of birth', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        OutlinedButton(
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  _value ?? DateTime(now.year - 18, now.month, now.day),
              firstDate: DateTime(1900, 1, 1),
              lastDate: now,
            );
            if (picked != null) {
              setState(() => _value = picked);
              widget.onChanged(picked);
            }
          },
          child: Align(alignment: Alignment.centerLeft, child: Text(text)),
        ),
      ],
    );
  }
}
