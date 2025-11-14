// lib/features/setup/widgets/phone_country_field.dart
//
// Combines a country picker + national number input and writes a full
// E.164 phone string into the provided controller, e.g. "+447881169965".

import 'package:flutter/material.dart';

import '../validators/validators.dart';

class PhoneCountryField extends StatefulWidget {
  const PhoneCountryField({super.key, required this.controller});

  /// Controller that will hold the full E.164 phone string, e.g. "+447881169965".
  final TextEditingController controller;

  @override
  State<PhoneCountryField> createState() => _PhoneCountryFieldState();
}

/// Simple model for a supported country / dial code.
class _Country {
  const _Country({
    required this.flag,
    required this.name,
    required this.dialCode,
  });

  final String flag; // e.g. "🇬🇧"
  final String name; // e.g. "United Kingdom"
  final String dialCode; // e.g. "44"
}

// Limited list for now – you can always extend this later.
const List<_Country> _countries = [
  _Country(flag: '🇬🇧', name: 'United Kingdom', dialCode: '44'),
  _Country(flag: '🇳🇬', name: 'Nigeria', dialCode: '234'),
];

class _PhoneCountryFieldState extends State<PhoneCountryField> {
  late _Country _selectedCountry;
  late TextEditingController _nationalController;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.first; // default to first in list (UK)
    _nationalController = TextEditingController();

    // If there's already an E.164 value in the controller, try to parse it.
    final existing = widget.controller.text.trim();
    if (existing.startsWith('+')) {
      _tryParseExistingE164(existing);
    } else if (existing.isNotEmpty) {
      // If someone saved without +, at least keep the digits.
      _nationalController.text = existing;
    }
  }

  /// Try to split an existing E.164 string into country + national number.
  void _tryParseExistingE164(String e164) {
    final cleaned = cleanE164(e164);
    if (!cleaned.startsWith('+')) return;

    // Remove leading +
    final digits = cleaned.substring(1);

    // Try to find a matching country dial code prefix.
    for (final c in _countries) {
      if (digits.startsWith(c.dialCode)) {
        _selectedCountry = c;
        _nationalController.text = digits.substring(c.dialCode.length);
        return;
      }
    }

    // Fallback: keep as national number if no country matched.
    _nationalController.text = digits;
  }

  /// Build and store the E.164 string into the external controller.
  void _updateE164() {
    final national = _nationalController.text.trim();
    if (national.isEmpty) {
      widget.controller.text = '';
      return;
    }
    final e164 = '+${_selectedCountry.dialCode}$national';
    widget.controller.text = e164;
  }

  @override
  void dispose() {
    _nationalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Country / dial code dropdown
            DropdownButton<_Country>(
              value: _selectedCountry,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCountry = value;
                });
                _updateE164();
              },
              items: _countries
                  .map(
                    (c) => DropdownMenuItem<_Country>(
                      value: c,
                      child: Row(
                        children: [
                          Text(c.flag),
                          const SizedBox(width: 8),
                          Text('${c.name} +${c.dialCode}'),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(width: 8),

            // National number input
            Expanded(
              child: TextFormField(
                controller: _nationalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Phone (national)',
                  hintText: 'national number (digits only)',
                ),
                validator: nationalNumberValidator,
                onChanged: (_) => _updateE164(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Helper text showing how it will be stored.
        Text(
          widget.controller.text.isEmpty
              ? 'Will save as +<country_code><number>...'
              : 'Will save as ${widget.controller.text}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
