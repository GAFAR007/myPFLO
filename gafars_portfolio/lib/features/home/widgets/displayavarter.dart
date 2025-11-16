// lib/features/home/widgets/displayavarter.dart
//
// DisplayAvatar (web-friendly, minimal)
//
// PURPOSE
// -------
// This widget:
// 1) Fetches your SiteProfile from Supabase ONCE when the widget is created.
// 2) Logs ONLY the profile `id` and `avatarUrl` to the console (so you can debug).
// 3) Shows the avatar as an image.
//    - On WEB → uses a real <img> element via HtmlElementView (avoids ImageDecoder issues).
//    - On OTHER platforms → uses Image.network normally.
//
// VISUAL BEHAVIOUR
// ----------------
// - While loading → show CircularProgressIndicator.
// - If there's an error → show a red error message.
// - If avatarUrl is empty → show a fallback person icon.
// - Otherwise → show a round (circular) avatar with the image.
//
// ⭐ MAIN THING: If you don't see your image, first check the logs for:
//      id        : ...
//      avatarUrl : ...
//   Those tell you what Supabase actually returned.

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
// kIsWeb  -> lets us detect if we are running in a browser.
// kDebugMode -> lets us show extra logs only in debug mode.

import 'package:web/web.dart' as web;
// 👆 This is for direct access to browser DOM types like HTMLImageElement
// (only used when running on the web).

import 'package:flutter/material.dart';

import '../../../data/supabase/profile_repository.dart';
// 👆 Your own repository that talks to Supabase to read/write profile data.

import '../../../data/supabase/models/site_profile.dart';
// 👆 Model class that represents a row from your "site_profile" table.

class DisplayAvatar extends StatefulWidget {
  const DisplayAvatar({super.key});

  @override
  State<DisplayAvatar> createState() => _DisplayAvatarState();
}

// ⭐ StatefulWidget because:
// - We need to load data asynchronously from Supabase.
// - We store avatarUrl, loading, and error in state and then rebuild the UI.
class _DisplayAvatarState extends State<DisplayAvatar> {
  // Repository instance used to fetch profile data from Supabase.
  final _repo = ProfileRepository();

  // The URL of the avatar image, as stored in Supabase.
  String? _avatarUrl;

  // Whether we are currently waiting for Supabase response.
  bool _loading = true;

  // If something goes wrong (no row, network error, etc.), we store a message here.
  String? _error;

  @override
  void initState() {
    super.initState();
    // When this widget is first created, immediately start loading the profile.
    _loadAndLogAvatar();
  }

  /// Fetch profile from Supabase once and log the two fields we care about.
  ///
  /// SUMMARY OF WHAT HAPPENS
  /// -----------------------
  /// 1) Ask Supabase for the SiteProfile (via ProfileRepository).
  /// 2) If no row → log and show "No profile row found."
  /// 3) If there's a row:
  ///    - Trim the avatar URL.
  ///    - LOG:
  ///        id        : ...
  ///        avatarUrl : ...
  ///    - Save avatarUrl to state and stop loading.
  /// 4) If there's an exception:
  ///    - Log error in console.
  ///    - Show "Error fetching profile." in the UI.
  Future<void> _loadAndLogAvatar() async {
    try {
      // 1) Fetch profile from Supabase via your repository.
      final SiteProfile? profile = await _repo.fetchProfile();

      // 2) If no row exists in database, we can't show an avatar.
      if (profile == null) {
        debugPrint('[Avatar] ⚠️ No profile row found.');
        setState(() {
          _error = 'No profile row found.'; // UI will show this message.
          _loading = false; // Stop showing the spinner.
        });
        return;
      }

      // 3) We have a row. Extract avatarUrl and clean it up.
      final avatarUrl = profile.avatarUrl?.trim();

      // ⭐ ONLY THESE TWO LOGS (your priority) ⭐
      // They help you verify:
      // - which profile row is being used
      // - what URL Supabase returned
      debugPrint('id        : ${profile.id}');
      debugPrint('avatarUrl : $avatarUrl');

      // Update state with the avatarUrl and mark loading as done.
      setState(() {
        _avatarUrl = avatarUrl;
        _loading = false;
      });
    } catch (e, st) {
      // 4) If any error happens during the fetch, we land here.
      debugPrint('[Avatar] ❌ Error fetching profile: $e');

      // In debug mode, also print the stack trace for deeper investigation.
      if (kDebugMode) {
        debugPrint(st.toString());
      }

      // Update UI to show a generic error.
      setState(() {
        _error = 'Error fetching profile.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1) LOADING STATE
    if (_loading) {
      // While waiting for Supabase, show a small spinner.
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    // 2) ERROR STATE
    if (_error != null) {
      // If something went wrong (no row, network error, etc.),
      // show the error in red so you know there’s a problem.
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }

    // 3) SUCCESS STATE – we have either a non-empty URL or an empty one.
    // ignore: unused_local_variable
    final textTheme = Theme.of(context).textTheme;

    // Card UI that shows:
    // - The avatar image (or fallback icon).
    // - The actual avatarUrl as text, so you can copy/check it.
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 👇 This is the only place that actually tries to display the image
              _avatarImage(_avatarUrl),

              // SelectableText lets you copy the URL easily.
              //    SelectableText(
              //     _avatarUrl ?? '<null>', // If null → display "<null>".
              //  textAlign: TextAlign.center,
              //   style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
              //  ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔍 Image display helper
  ///
  /// RESPONSIBILITIES
  /// ----------------
  /// - Take the avatar URL and normalize it (trim whitespace).
  /// - If empty → show a simple fallback icon.
  /// - On WEB:
  ///     Use `HtmlElementView.fromTagName` to create a real <img> element.
  ///     This avoids the Flutter web ImageDecoder bug with some URLs.
  /// - On OTHER PLATFORMS:
  ///     Use `Image.network` with an `errorBuilder` to catch failures.
  ///
  /// This function is the only place where we actually render the avatar.
  Widget _avatarImage(String? url) {
    // Clean up the URL: convert null to '' and trim spaces.
    final clean = url?.trim() ?? '';

    // If there's no usable URL, show a fallback icon.
    if (clean.isEmpty) {
      debugPrint('[Avatar] URL is empty – showing fallback icon.');
      return const Icon(Icons.person, size: 60);
    }

    // ⭐ WEB-SPECIFIC BRANCH
    // On the web we avoid using Image.network directly because:
    // - Some browsers and URLs can trigger ImageDecoder/ImageCodec exceptions.
    // - Using a plain <img> element lets the browser handle decoding natively.
    if (kIsWeb) {
      debugPrint('[Avatar] Using HtmlElementView <img> for web avatar.');

      return ClipOval(
        child: SizedBox(
          width: 120,
          height: 120,
          child: HtmlElementView.fromTagName(
            tagName: 'img', // We are creating: <img />
            onElementCreated: (element) {
              // The element is a generic DOM element, so we cast it to HTMLImageElement.
              final img = element as web.HTMLImageElement;

              // Set the image source to the Supabase public URL.
              img.src = clean;

              // Good practice for accessibility (screen readers).
              img.alt = 'Profile avatar';

              // CSS styles to make it behave like BoxFit.cover.
              img.style.objectFit = 'cover';
              img.style.width = '120px';
              img.style.height = '120px';
            },
          ),
        ),
      );
    }

    // 📱 NON-WEB BRANCH (Android / iOS / desktop)
    // Here we can safely use Flutter's Image.network.
    return ClipOval(
      child: Image.network(
        clean,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        // errorBuilder is called if the image fails to load for ANY reason.
        errorBuilder: (_, error, __) {
          debugPrint('[Avatar] ❌ Image.network error for $clean → $error');
          // Show a fallback icon if loading fails.
          return const Icon(Icons.person, size: 60);
        },
      ),
    );
  }
}
