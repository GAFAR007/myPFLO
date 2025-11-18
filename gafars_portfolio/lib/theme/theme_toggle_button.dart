// lib/theme/theme_toggle_button.dart
//
// Small icon button for the AppBar that toggles between light and dark mode.

import 'package:flutter/material.dart';
import 'theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDarkBySystem = platformBrightness == Brightness.dark;
        final isDark =
            mode == ThemeMode.dark ||
            (mode == ThemeMode.system && isDarkBySystem);

        return IconButton(
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: ThemeController.toggle,
          icon: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
          ),
        );
      },
    );
  }
}
