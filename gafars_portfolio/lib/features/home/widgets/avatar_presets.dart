class AvatarPresets {
  static const String _diceBearHost = 'https://api.dicebear.com';
  static const String _diceBearVersion = '9.x';
  static const String _style = 'adventurer';

  static String buildDiceBearUrl({
    String? fullName,
    String? email,
    String? seed,
  }) {
    final resolvedSeed = _resolveSeed(
      seed: seed,
      fullName: fullName,
      email: email,
    );

    return '$_diceBearHost/$_diceBearVersion/$_style/svg'
        '?seed=${Uri.encodeComponent(resolvedSeed)}';
  }

  static String _resolveSeed({String? seed, String? fullName, String? email}) {
    for (final candidate in [seed, fullName, email]) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return 'portfolio-admin';
  }
}
