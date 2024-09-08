import 'package:flutter/material.dart';

final ThemeData themeData = ThemeData(
  primaryColor: const Color.fromARGB(255, 255, 21, 111),
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
      .copyWith(secondary: const Color.fromARGB(255,190, 242, 0),
));
