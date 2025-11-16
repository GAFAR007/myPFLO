// lib/features/home/widgets/displayavarter.dart
//
// DisplayAvatar (web-friendly, minimal)
//
// PURPOSE
// -------
// This widget:
// 1) Fetches your SiteProfile from Supabase ONCE when the widget is created.
// 2) Logs ONLY the profile `id` and `avatarUrl` to the console (so you can debug).
// 3) Uses the shared AppAvatar widget to actually render the avatar image.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:gafars_portfolio/features/home/widgets/app_avatar.dart'; // 👈 NEW shared avatar

import '../../../data/supabase/profile_repository.dart';
import '../../../data/supabase/models/site_profile.dart';

class DisplayAvatar extends StatefulWidget {
  const DisplayAvatar({super.key});

  @override
  State<DisplayAvatar> createState() => _DisplayAvatarState();
}

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
    _loadAndLogAvatar();
  }

  /// Fetch profile from Supabase once and log the two fields we care about.
  Future<void> _loadAndLogAvatar() async {
    try {
      final SiteProfile? profile = await _repo.fetchProfile();

      if (profile == null) {
        debugPrint('[Avatar] ⚠️ No profile row found.');
        setState(() {
          _error = 'No profile row found.';
          _loading = false;
        });
        return;
      }

      final avatarUrl = profile.avatarUrl?.trim();

      // ⭐ ONLY THESE TWO LOGS (your priority)
      debugPrint('id        : ${profile.id}');
      debugPrint('avatarUrl : $avatarUrl');

      setState(() {
        _avatarUrl = avatarUrl;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('[Avatar] ❌ Error fetching profile: $e');

      if (kDebugMode) {
        debugPrint(st.toString());
      }

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
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    // 2) ERROR STATE
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }

    // 3) SUCCESS STATE – delegate actual drawing to AppAvatar
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppAvatar(
                avatarUrl: _avatarUrl,
                size: 120, // big hero avatar
              ),
            ],
          ),
        ),
      ),
    );
  }
}
