// lib/features/auth/widgets/auth_gate.dart
//
// Wrapper that decides what to show based on backend auth state:
//
// - If NOT logged in  -> show LoginPage (admin login)
// - If logged in      -> show the protected child (e.g. SetupPage)

import 'package:flutter/material.dart';

import '../../../data/api/auth_repository.dart';
import '../view/login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child});

  /// Widget to show when user is authenticated (our SetupPage).
  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authRepository = AuthRepository();
  AdminSession? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void didUpdateWidget(covariant AuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_loading && _session == null) {
      _loadSession();
    }
  }

  Future<void> _loadSession() async {
    setState(() => _loading = true);

    try {
      _session = await _authRepository.fetchCurrentAdmin();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_session == null) {
      return const LoginPage();
    }

    return widget.child;
  }
}
