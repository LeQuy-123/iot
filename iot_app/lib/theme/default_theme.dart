import 'package:flutter/material.dart';

final ThemeData defalutTheme = ThemeData(
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: Color(0xFF121317)
  ),
  colorScheme: const ColorScheme.light(
    primary:  Color(0xff848484),
    onPrimary: Colors.white, // header text color
    onSurface: Colors.white70, // body text color
  ),
  primaryColor: const Color(0xff0A68FF),
  appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          color: Colors.white70, fontSize: 24.0, fontWeight: FontWeight.w400, fontFamily: 'Roboto')),
  scaffoldBackgroundColor: const Color(0xFF121317),
  dialogBackgroundColor: const Color(0xFF121212),
   
);
