class AvatarPresetOption {
  const AvatarPresetOption({
    required this.label,
    required this.seed,
    required this.url,
  });

  final String label;
  final String seed;
  final String url;
}

class AvatarPresets {
  static const String _diceBearHost = 'https://api.dicebear.com';
  static const String _diceBearVersion = '9.x';
  static const String _style = 'adventurer';
  static const String _format = 'png';

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

    return '$_diceBearHost/$_diceBearVersion/$_style/$_format'
        '?seed=${Uri.encodeComponent(resolvedSeed)}&size=256';
  }

  static List<AvatarPresetOption> buildDiceBearOptions({
    String? fullName,
    String? email,
    String? seed,
    int count = 6,
  }) {
    final baseSeed = _resolveSeed(seed: seed, fullName: fullName, email: email);

    return List.generate(count, (index) {
      final optionSeed = index == 0 ? baseSeed : '$baseSeed-${index + 1}';
      return AvatarPresetOption(
        label: 'Avatar ${index + 1}',
        seed: optionSeed,
        url: buildDiceBearUrl(seed: optionSeed),
      );
    });
  }

  static bool isDiceBearUrl(String? rawUrl) {
    final url = rawUrl?.trim() ?? '';
    if (url.isEmpty) {
      return false;
    }

    return url.startsWith('$_diceBearHost/$_diceBearVersion/$_style/$_format');
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
