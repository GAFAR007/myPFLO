// lib/app.dart
// Minimal app shell that opens the DEV-ONLY Setup page.
import 'package:flutter/material.dart';
import 'features/setup/view/setup_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio Setup (Dev)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SetupPage(), // ← dev-only entry
    );
  }
}
