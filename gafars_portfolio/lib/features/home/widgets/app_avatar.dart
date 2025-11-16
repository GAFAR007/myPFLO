// lib/shared/widgets/app_avatar.dart
//
// Reusable avatar widget used across the app.
// - Accepts an avatarUrl and size.
// - If URL empty  → fallback icon.
// - On WEB       → <img> via HtmlElementView.
// - On others    → CircleAvatar with NetworkImage.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;

class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.avatarUrl, this.size = 120});

  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clean = avatarUrl?.trim() ?? '';

    // 1) No URL → fallback
    if (clean.isEmpty) {
      debugPrint('[AppAvatar] empty URL – using fallback icon');
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.white10,
        child: Icon(Icons.person, color: Colors.white70, size: size * 0.5),
      );
    }

    // 2) WEB → real <img>
    if (kIsWeb) {
      debugPrint('[AppAvatar] Using HtmlElementView <img> for avatar.');
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: HtmlElementView.fromTagName(
            tagName: 'img',
            onElementCreated: (element) {
              final img = element as web.HTMLImageElement;
              img.src = clean;
              img.alt = 'Profile avatar';
              img.style.objectFit = 'cover';
              img.style.width = '${size}px';
              img.style.height = '${size}px';
            },
          ),
        ),
      );
    }

    // 3) Mobile / desktop → normal NetworkImage
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.white10,
      backgroundImage: NetworkImage(clean),
      onBackgroundImageError: (_, __) {
        debugPrint('[AppAvatar] ❌ NetworkImage error for $clean');
      },
    );
  }
}
