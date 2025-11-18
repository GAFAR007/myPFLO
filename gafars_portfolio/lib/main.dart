// lib/main.dart
//
// App entry –
// - Public users land on HomePage at route '/'
// - Admin setup is at '/admin' and is protected by AuthGate.

import 'package:flutter/material.dart';
import 'package:gafars_portfolio/features/profile/view/profile_page.dart';

import 'data/supabase/supabase_client.dart';
import 'features/auth/widgets/auth_gate.dart';
import 'features/setup/view/setup_page.dart';
import 'features/home/view/home_page.dart';
import 'features/projects/view/projects_page.dart';
import 'features/about/view/about_page.dart';
import 'features/contact/view/contact_page.dart';
import 'features/resume/view/resume_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
  // Fail early if env vars are missing
  Supa.assertConfigured();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Gafars Portfolio',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode, // 👈 controlled by the toggle
          // your routes/initialRoute stay the same
          initialRoute: '/',
          routes: {
            '/': (context) => const HomePage(),
            '/projects': (context) => const ProjectsPage(),
            '/about': (context) => const AboutPage(),
            '/contact': (context) => const ContactPage(),
            '/resume': (context) => const ResumePage(),
            '/profile': (context) => const ProfilePage(),
            '/admin': (context) => const AuthGate(child: SetupPage()),
          },
        );
      },
    );
  }
}
