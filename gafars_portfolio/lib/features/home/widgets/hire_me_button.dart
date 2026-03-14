import 'package:flutter/material.dart';

class HireMeButton extends StatelessWidget {
  const HireMeButton({super.key, this.onPressed, this.compact = false});

  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.north_east_rounded, size: 18),
      label: Text(compact ? 'Hire' : 'Hire me'),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 16,
          vertical: compact ? 12 : 12,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
