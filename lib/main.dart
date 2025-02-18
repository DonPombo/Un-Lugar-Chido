import 'package:flutter/material.dart';
import 'package:un_lugar_chido_app/pages/screens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://alzwxzipmngvymwehlbm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsend4emlwbW5ndnltd2VobGJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcyMjI5NDAsImV4cCI6MjA1Mjc5ODk0MH0.0YjLe17b2O9pm1x78gmFNMHFuJMqcxg5iilZNzMIuDc',
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
