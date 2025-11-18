// lib/theme/theme_controller.dart
//
// Simple global controller for theme mode (light / dark / system).

import 'package:flutter/material.dart';

class ThemeController {
  // Current mode – starts as system.
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  // Cycle between light and dark (you can add system later if you like).
  static void toggle() {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }
}
