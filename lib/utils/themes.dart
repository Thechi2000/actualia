import 'package:flutter/material.dart';

ThemeData actualIATheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    textTheme: const TextTheme(
      titleLarge: TextStyle(
          fontFamily: "EB Garamond",
          fontSize: 36.0,
          fontWeight: FontWeight.w700),
      titleMedium: TextStyle(
          fontFamily: "EB Garamond",
          fontSize: 24.0,
          fontWeight: FontWeight.w500),
      titleSmall: TextStyle(
          fontFamily: "EB Garamond",
          fontSize: 16.0,
          color: Color(0xFF818181),
          fontWeight: FontWeight.w300),
      displayLarge: TextStyle(
          fontFamily: "Fira Code", fontSize: 36.0, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(
          fontFamily: "Fira Code", fontSize: 24.0, fontWeight: FontWeight.w500),
      displaySmall: TextStyle(
          fontFamily: "Fira Code",
          fontSize: 16.0,
          color: Color(0xFF818181),
          fontWeight: FontWeight.w300),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5EDCE4)));
