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
        return Material(
          color: colorScheme.primaryContainer.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Scaffold.of(ctx).openDrawer();
            },
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.menu_rounded,
                color: colorScheme.onSurface,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}
