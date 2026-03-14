// lib/features/home/widgets/displayavarter.dart
//
// DisplayAvatar (web-friendly, minimal)
//
// PURPOSE
// -------
// This widget:
// 1) Fetches your SiteProfile once when the widget is created.
// 2) Logs ONLY the profile `id` and `avatarUrl` to the console (so you can debug).
// 3) Uses the shared AppAvatar widget to actually render the avatar image.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:gafars_portfolio/features/home/widgets/app_avatar.dart';

import '../../../data/api/models/site_profile.dart';
import '../../../data/api/profile_repository.dart';

class DisplayAvatar extends StatefulWidget {
  const DisplayAvatar({super.key, this.fullName, this.email});

  final String? fullName;
  final String? email;

  @override
  State<DisplayAvatar> createState() => _DisplayAvatarState();
}

class _DisplayAvatarState extends State<DisplayAvatar> {
  final _repo = ProfileRepository();

  String? _fullName;
  String? _email;
  String? _avatarUrl;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAndLogAvatar();
  }

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
        _fullName = profile.fullName.trim().isNotEmpty
            ? profile.fullName.trim()
            : [profile.firstName?.trim(), profile.lastName?.trim()]
                  .whereType<String>()
                  .where((value) => value.isNotEmpty)
                  .join(' ');
        _email = profile.email;
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
                fullName: _fullName ?? widget.fullName,
                email: _email ?? widget.email,
                size: 120,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
