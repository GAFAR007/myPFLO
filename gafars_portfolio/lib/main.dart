// lib/main.dart
//
// App entry –
// - Public users land on HomePage at route '/'
// - Admin setup is at '/admin' and is protected by AuthGate.

import 'package:flutter/material.dart';

import 'data/supabase/supabase_client.dart';
import 'features/auth/widgets/auth_gate.dart';
import 'features/setup/view/setup_page.dart';
import 'features/home/view/home_page.dart';
import 'features/projects/view/projects_page.dart';
import 'features/about/view/about_page.dart';
import 'features/contact/view/contact_page.dart';
import 'features/resume/view/resume_page.dart';

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
      title: 'Gafars Portfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Start on the public home page
      initialRoute: '/',

      // Simple named routes:
      routes: {
        '/': (context) => const HomePage(),
        '/projects': (context) => const ProjectsPage(),
        '/about': (context) => const AboutPage(),
        '/contact': (context) => const ContactPage(),
        '/resume': (context) => const ResumePage(),
        
        // Admin-only setup area behind AuthGate
        '/admin': (context) => const AuthGate(child: SetupPage()),
      },
    );
  }
}
