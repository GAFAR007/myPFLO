// Reusable avatar widget used across the app.
// - Uses the uploaded profile image when present.
// - Falls back to a curated DiceBear avatar when no profile image exists.
// - Falls back to a generic person icon only if both network paths fail.

import 'package:flutter/material.dart';

import 'avatar_presets.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.avatarUrl,
    this.fullName,
    this.email,
    this.seed,
    this.size = 120,
  });

  final String? avatarUrl;
  final String? fullName;
  final String? email;
  final String? seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final uploadedUrl = avatarUrl?.trim() ?? '';
    final displayUrl = uploadedUrl.isNotEmpty
        ? uploadedUrl
        : AvatarPresets.buildDiceBearUrl(
            fullName: fullName,
            email: email,
            seed: seed,
          );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          displayUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackAvatar(size: size),
        ),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        size: size * 0.45,
      ),
    );
  }
}
