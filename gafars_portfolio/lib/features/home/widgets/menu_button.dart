// lib/features/home/widgets/menu_button.dart
//
// Simple "Menu" button for the top-left of the AppBar.
// Right now it just prints to the console when tapped.
// Later you can hook this into a Drawer, overlay, or navigation.

import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextButton.icon(
      onPressed: () {
        // TODO: open nav / drawer later.
        debugPrint('[MenuButton] Menu tapped');
      },
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      icon: const Icon(Icons.menu, size: 20),
      label: Text(
        'Menu',
        style: textTheme.labelLarge?.copyWith(letterSpacing: 1.0),
      ),
    );
  }
}
