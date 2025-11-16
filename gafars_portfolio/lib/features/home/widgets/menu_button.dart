// lib/features/home/widgets/menu_button.dart
//
// Icon-only "Menu" button for the top-left of the AppBar.
// Taps open the Scaffold.drawer (your side bar).

import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use a Builder so we get a context *inside* the Scaffold,
    // otherwise Scaffold.of(...) would fail.
    return Builder(
      builder: (ctx) {
        return IconButton(
          tooltip: 'Menu',
          onPressed: () {
            debugPrint('[MenuButton] Menu tapped');
            Scaffold.of(ctx).openDrawer();
          },
          icon: const Icon(Icons.menu),
          color: colorScheme.onSurface,
        );
      },
    );
  }
}
