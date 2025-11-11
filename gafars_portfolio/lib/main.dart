import 'package:flutter/material.dart';
import 'app.dart';
import 'data/supabase/supabase_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fail fast in dev if you forget to pass the Supabase values.
  Supa.assertConfigured(); // (keep during Step 1 only)
  runApp(const App());
}
