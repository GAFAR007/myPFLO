class AvatarPresetOption {
  const AvatarPresetOption({required this.label, required this.url});

  final String label;
  final String url;
}

class AvatarPresets {
  static const String _diceBearHost = 'https://api.dicebear.com';
  static const String _diceBearVersion = '9.x';
  static const String _style = 'avataaars';
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

    return _buildStyledUrl(
      seed: resolvedSeed,
      top: 'dreads02',
      accessories: 'prescription02',
      clothing: 'hoodie',
      mouth: 'smile',
      eyes: 'default',
      eyebrows: 'defaultNatural',
      skinColor: '614335',
      hairColor: '2c1b18',
      clothesColor: '262e33',
      backgroundColor: 'd1d4f9',
    );
  }

  static List<AvatarPresetOption> buildProfileFitOptions({
    String? fullName,
    String? email,
    String? seed,
  }) {
    final resolvedSeed = _resolveSeed(
      seed: seed,
      fullName: fullName,
      email: email,
    );

    return [
      AvatarPresetOption(
        label: 'Dreads + Glasses',
        url: _buildStyledUrl(
          seed: '$resolvedSeed-tech-glasses',
          top: 'dreads02',
          accessories: 'round',
          clothing: 'hoodie',
          mouth: 'smile',
          eyes: 'default',
          eyebrows: 'defaultNatural',
          skinColor: '614335',
          hairColor: '2c1b18',
          clothesColor: '262e33',
          backgroundColor: 'c0aede',
        ),
      ),
      AvatarPresetOption(
        label: 'Dreads + Hoodie',
        url: _buildStyledUrl(
          seed: '$resolvedSeed-hoodie',
          top: 'dreads01',
          accessories: 'blank',
          clothing: 'hoodie',
          mouth: 'smile',
          eyes: 'happy',
          eyebrows: 'raisedExcited',
          skinColor: '8d5524',
          hairColor: '2c1b18',
          clothesColor: '25557c',
          backgroundColor: 'b6e3f4',
        ),
      ),
      AvatarPresetOption(
        label: 'Dreads + Beard',
        url: _buildStyledUrl(
          seed: '$resolvedSeed-beard',
          top: 'dreads',
          accessories: 'blank',
          facialHair: 'beardMedium',
          clothing: 'shirtCrewNeck',
          mouth: 'serious',
          eyes: 'default',
          eyebrows: 'default',
          skinColor: '614335',
          hairColor: '4a312c',
          facialHairColor: '4a312c',
          clothesColor: '262e33',
          backgroundColor: 'ffd5dc',
        ),
      ),
      AvatarPresetOption(
        label: 'Tech Lead',
        url: _buildStyledUrl(
          seed: '$resolvedSeed-tech-lead',
          top: 'dreads02',
          accessories: 'prescription02',
          clothing: 'blazerAndSweater',
          mouth: 'default',
          eyes: 'default',
          eyebrows: 'defaultNatural',
          skinColor: '8d5524',
          hairColor: '2c1b18',
          clothesColor: '262e33',
          backgroundColor: 'd1d4f9',
        ),
      ),
      AvatarPresetOption(
        label: 'Casual Builder',
        url: _buildStyledUrl(
          seed: '$resolvedSeed-casual',
          top: 'dreads01',
          accessories: 'blank',
          clothing: 'shirtCrewNeck',
          mouth: 'smile',
          eyes: 'happy',
          eyebrows: 'default',
          skinColor: 'ae5d29',
          hairColor: '2c1b18',
          clothesColor: '5199e4',
          backgroundColor: 'b6e3f4',
        ),
      ),
      AvatarPresetOption(
        label: 'Focused Dev',
        url: _buildStyledUrl(
          seed: '$resolvedSeed-focused',
          top: 'dreads02',
          accessories: 'prescription01',
          clothing: 'collarAndSweater',
          mouth: 'twinkle',
          eyes: 'squint',
          eyebrows: 'defaultNatural',
          skinColor: '614335',
          hairColor: '2c1b18',
          clothesColor: '65c9ff',
          backgroundColor: 'c0aede',
        ),
      ),
    ];
  }

  static bool isDiceBearUrl(String? rawUrl) {
    final url = rawUrl?.trim() ?? '';
    if (url.isEmpty) {
      return false;
    }

    return url.startsWith(_diceBearHost);
  }

  static String _buildStyledUrl({
    required String seed,
    required String top,
    required String accessories,
    required String clothing,
    required String mouth,
    required String eyes,
    required String eyebrows,
    required String skinColor,
    required String hairColor,
    required String clothesColor,
    required String backgroundColor,
    String? facialHair,
    String? facialHairColor,
  }) {
    final query = <String, String>{
      'seed': seed,
      'size': '256',
      'backgroundType': 'solid',
      'backgroundColor': backgroundColor,
      'top': top,
      'accessories': accessories,
      'clothing': clothing,
      'mouth': mouth,
      'eyes': eyes,
      'eyebrows': eyebrows,
      'skinColor': skinColor,
      'hairColor': hairColor,
      'clothesColor': clothesColor,
    };

    if (facialHair != null) {
      query['facialHair'] = facialHair;
    }
    if (facialHairColor != null) {
      query['facialHairColor'] = facialHairColor;
    }

    final encodedQuery = query.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');

    return '$_diceBearHost/$_diceBearVersion/$_style/$_format?$encodedQuery';
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
