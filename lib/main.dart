import 'package:flutter/material.dart';
import 'package:un_lugar_chido_app/pages/screens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// IMPORTANT: Do NOT commit Supabase credentials.
/// The app reads Supabase credentials from compile-time defines.
/// Provide them when running or building the app:
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read Supabase config from --dart-define
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    // Fail fast with a clear message so the developer knows how to provide keys.
    throw Exception(
        'Supabase credentials not provided. Run with:\n'
        "flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY\n"
        'Or set these variables in your CI environment (GitHub Actions secrets) and use them as --dart-define in the workflow.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const RestauranteMexicanoApp());
}

class RestauranteMexicanoApp extends StatelessWidget {
  const RestauranteMexicanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Un Lugar Chido',
      routerConfig: appRouter,
      theme: themeData,
    );
  }
}
