import 'package:flutter/material.dart';

class PublicPageFrame extends StatelessWidget {
  const PublicPageFrame({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.badge,
    this.maxWidth = 1120,
  });

  final String title;
  final String description;
  final String? badge;
  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Stack(
      children: [
        Positioned(
          top: -50,
          left: compact ? -70 : 20,
          child: _AmbientGlow(
            size: compact ? 180 : 260,
            color: colorScheme.primary.withValues(alpha: 0.14),
          ),
        ),
        Positioned(
          right: compact ? -60 : 0,
          top: compact ? 60 : 20,
          child: _AmbientGlow(
            size: compact ? 160 : 240,
            color: colorScheme.secondary.withValues(alpha: 0.12),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 24,
              compact ? 22 : 30,
              compact ? 16 : 24,
              48,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(compact ? 20 : 28),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(
                                alpha: 0.55,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        Text(
                          title,
                          style: compact
                              ? theme.textTheme.headlineLarge
                              : theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Text(
                            description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
