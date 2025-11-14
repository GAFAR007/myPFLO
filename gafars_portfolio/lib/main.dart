// lib/main.dart
//
// App entry. We rely on Supa.client instead of Supabase.initialize.

import 'package:flutter/material.dart';

import 'features/setup/view/setup_page.dart';
import 'data/supabase/supabase_client.dart';

void main() {
  // Fail early if env vars are missing
  Supa.assertConfigured();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio Setup (Dev)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SetupPage(),
    );
  }
}
