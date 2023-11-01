import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  primaryColor: Colors.blue,
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16.0),
      titleSmall: TextStyle(fontSize: 10.0),
      bodyMedium: TextStyle(fontSize: 16.0)),
  appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontSize: 24.0,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto')),
);
