import 'package:flutter/material.dart';

import '../../theme/theme_toggle_button.dart';
import '../contact/view/contact_form_page.dart';
import '../home/widgets/hire_me_button.dart';
import '../home/widgets/home_drawer.dart';
import '../home/widgets/menu_button.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.body, this.title});

  final Widget body;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final tight = width < 460;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const HomeDrawer(),
      appBar: AppBar(
        toolbarHeight: tight
            ? 72
            : compact
            ? 80
            : 88,
        leadingWidth: 78,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: MenuButton(),
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gafars Technologies',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (tight
                          ? theme.textTheme.titleSmall
                          : theme.textTheme.titleMedium)
                      ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (!compact && !tight && title != null)
              Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          const ThemeToggleButton(),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: HireMeButton(
              compact: tight,
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
