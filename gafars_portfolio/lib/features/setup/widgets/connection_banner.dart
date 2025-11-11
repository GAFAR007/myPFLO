// lib/features/setup/widgets/connection_banner.dart
//
// ConnectionBanner
// - Small status bar that shows:
//   • "Checking…" (blue) while probing Supabase
//   • "Connected" (green) if OK
//   • "Can’t reach…" (red) plus a Retry button and a tiny dev hint
//
// Keep this logic outside the page so SetupPage stays readable.

import 'package:flutter/material.dart';

class ConnectionBanner extends StatelessWidget {
  final bool checking; // true while testing the connection
  final bool ok; // true if last check succeeded
  final String? devHint; // optional detailed error text (for dev eyes)
  final VoidCallback onRetry;

  const ConnectionBanner({
    super.key,
    required this.checking,
    required this.ok,
    required this.devHint,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Pick background + message based on state
    Color bg;
    String msg;

    if (checking) {
      bg = Colors.blue.shade50;
      msg = 'Checking Supabase connection…';
    } else if (ok) {
      bg = Colors.green.shade50;
      msg = 'Connected to Supabase';
    } else {
      bg = Colors.red.shade50;
      msg = 'Can’t reach Supabase. Please check your internet or try again.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(msg)),
              const SizedBox(width: 12),
              TextButton(
                onPressed: checking ? null : onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
          if (!checking && !ok && devHint != null && devHint!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Dev hint: $devHint',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}
