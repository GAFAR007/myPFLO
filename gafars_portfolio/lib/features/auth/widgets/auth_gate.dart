// lib/features/auth/widgets/auth_gate.dart
//
// Wrapper that decides what to show based on Supabase auth state:
//
// - If NOT logged in  -> show LoginPage (admin login)
// - If logged in      -> show the protected child (e.g. SetupPage)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase/supabase_client.dart';
import '../view/login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child});

  /// Widget to show when user is authenticated (our SetupPage).
  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Session? _session;
  bool _loading = true;
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();

    // 1) Get existing session (if already logged in)
    _session = Supa.client.auth.currentSession;
    _loading = false;

    // 2) Listen for login / logout changes
    _sub = Supa.client.auth.onAuthStateChange.listen((event) {
      setState(() {
        _session = event.session;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show spinner while we check the session the first time.
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // No session -> show LoginPage.
    if (_session == null) {
      return const LoginPage();
    }

    // Session exists -> show the protected child (SetupPage).
    return widget.child;
  }
}
