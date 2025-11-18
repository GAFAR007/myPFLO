// lib/features/home/widgets/hire_me_button.dart
//
// Small "Hire me" pill button used in the AppBar.
// - Uses theme colours (primaryContainer / onPrimaryContainer)
//   so it looks good in both light and dark mode.
// - Uses an emoji icon to keep it friendly and compact.

import 'package:flutter/material.dart';

class HireMeButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const HireMeButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextButton.icon(
      onPressed: onPressed,
      icon: const Text(
        '💼', // you can change to 💼 or ✉️ if you prefer
        style: TextStyle(fontSize: 14),
      ),
      label: const Text('Hire me'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero, // let it shrink to content
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: colorScheme.primaryContainer.withOpacity(
          theme.brightness == Brightness.dark ? 0.8 : 1.0,
        ),
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
