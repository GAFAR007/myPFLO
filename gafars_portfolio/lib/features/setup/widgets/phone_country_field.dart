// lib/features/setup/widgets/phone_country_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Minimal in-file metadata for 3 countries; extend as needed.
class _DialMeta {
  final String flag;
  final String name;
  final String dial; // "+234"
  final int minLen;
  final int maxLen;
  const _DialMeta(this.flag, this.name, this.dial, this.minLen, this.maxLen);
}

const _kCountries = <_DialMeta>[
  _DialMeta('🇳🇬', 'Nigeria', '+234', 8, 11),
  _DialMeta('🇬🇧', 'United Kingdom', '+44', 9, 10),
  _DialMeta('🇺🇸', 'United States', '+1', 10, 10),
];

class PhoneCountryField extends StatefulWidget {
  final TextEditingController controller; // receives final E.164
  final bool required;

  const PhoneCountryField({
    super.key,
    required this.controller,
    this.required = false,
  });

  @override
  State<PhoneCountryField> createState() => _PhoneCountryFieldState();
}

class _PhoneCountryFieldState extends State<PhoneCountryField> {
  _DialMeta _selected = _kCountries.first;
  final _national = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If controller already has +code, try to split it
    final e164 = widget.controller.text.trim();
    if (e164.startsWith('+')) {
      for (final c in _kCountries) {
        if (e164.startsWith(c.dial)) {
          _selected = c;
          _national.text = e164.replaceFirst(c.dial, '');
          break;
        }
      }
    }
    _rebuildE164();
  }

  @override
  void dispose() {
    _national.dispose();
    super.dispose();
  }

  void _rebuildE164() {
    final digits = _national.text.replaceAll(RegExp(r'\D'), '');
    final e164 = digits.isEmpty ? '' : '${_selected.dial}$digits';
    widget.controller.text = e164;
  }

  String? _validateNational(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (widget.required && digits.isEmpty) {
      return 'Required';
    }
    if (digits.isNotEmpty &&
        (digits.length < _selected.minLen ||
            digits.length > _selected.maxLen)) {
      return 'Enter ${_selected.minLen}–${_selected.maxLen} digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phone (E.164)'),
        const SizedBox(height: 6),

        // 👉 Responsive layout: Row on wide, Column on narrow
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 420;

            final countryPicker = DropdownButtonFormField<_DialMeta>(
              value: _selected,
              isExpanded: true, // prevent overflow by letting it use full width
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              items: _kCountries
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      // Ellipsize long labels instead of overflowing
                      child: Text(
                        '${c.flag} ${c.name}  ${c.dial}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (c) {
                if (c == null) return;
                setState(() => _selected = c);
                _rebuildE164();
              },
            );

            final nationalNumber = TextFormField(
              controller: _national,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'national number (digits only)',
                border: OutlineInputBorder(),
              ),
              validator: _validateNational,
              onChanged: (_) => _rebuildE164(),
            );

            if (narrow) {
              // Stack vertically on small screens to avoid overflow
              return Column(
                children: [
                  countryPicker,
                  const SizedBox(height: 8),
                  nationalNumber,
                ],
              );
            }

            // Side-by-side on wider screens
            return Row(
              children: [
                Expanded(flex: 3, child: countryPicker),
                const SizedBox(width: 12),
                Expanded(flex: 7, child: nationalNumber),
              ],
            );
          },
        ),

        // Subtle helper line showing what will be saved
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            widget.controller.text.isEmpty
                ? 'Will save as ${_selected.dial}…'
                : 'Will save as ${widget.controller.text}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
