// lib/features/shell/app_scaffold.dart
//
// Reusable page shell used by Home, Contact, Resume, Projects, About, etc.
// Centralises:
//  - AppBar
//  - Drawer
//  - Hire Me button
//  - Theme toggle

import 'package:flutter/material.dart';

import '../home/widgets/home_drawer.dart';
import '../home/widgets/menu_button.dart';
import '../home/widgets/hire_me_button.dart';
import '../contact/view/contact_form_page.dart';
import '../../theme/theme_toggle_button.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.body, this.title});

  final Widget body;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Softer background instead of that harsh grey.
      backgroundColor: colorScheme.background,
      drawer: const HomeDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leadingWidth: 90,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: MenuButton(),
        ),
        title: Text(title ?? 'Razak Temitayo Gafar | Portfolio'),
        centerTitle: true,
        actions: [
          const ThemeToggleButton(), // 🌗 new toggle
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: HireMeButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContactFormPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: body,
    );
  }
}
