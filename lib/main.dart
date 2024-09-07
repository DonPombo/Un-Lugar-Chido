import 'package:flutter/material.dart';
import 'package:un_lugar_chido_app/presentation/home.dart';
import 'package:un_lugar_chido_app/presentation/screens.dart';


void main() {
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
