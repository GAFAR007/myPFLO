// lib/features/home/view/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/displayavarter.dart'; // <-- Import new file

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withOpacity(0.2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: const Text('Gafars Technologies – Avatar Debug'),
      ),
      body: const DisplayAvatar(), // <-- Uses new widget
    );
  }
}
