import 'package:flutter/material.dart';
import 'package:un_lugar_chido_app/presentation/screens.dart';
//importaciones de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
