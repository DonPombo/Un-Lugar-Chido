import 'package:flutter/material.dart';

final ThemeData themeData = ThemeData(
  primaryColor: const Color.fromARGB(255, 243, 4, 123), // Verde mexicano
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
    displayMedium: TextStyle(
        fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black87),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
  ),
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(secondary: const Color.fromARGB(255, 2, 248, 35)),
);
