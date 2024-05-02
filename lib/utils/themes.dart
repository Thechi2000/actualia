import 'package:flutter/material.dart';

const double UNIT_PADDING = 16.0;

ThemeData ACTUALIA_THEME = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    textTheme: const TextTheme(
      titleLarge: TextStyle(
          fontFamily: "EB Garamond",
          fontSize: 32.0,
          height: 0.95,
          fontWeight: FontWeight.w400),
      titleMedium: TextStyle(
          fontFamily: "EB Garamond",
          fontSize: 24.0,
          height: 0.95,
          leadingDistribution: TextLeadingDistribution.even,
          fontWeight: FontWeight.w400),
      titleSmall: TextStyle(
          fontFamily: "EB Garamond",
          fontSize: 16.0,
          color: Color(0xFF818181),
          fontWeight: FontWeight.w300),
      displayLarge: TextStyle(
          fontFamily: "Fira Code", fontSize: 32.0, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(
          fontFamily: "Fira Code", fontSize: 24.0, fontWeight: FontWeight.w500),
      displaySmall: TextStyle(
          fontFamily: "Fira Code",
          fontSize: 16.0,
          color: Color(0xFF818181),
          fontWeight: FontWeight.w300),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5EDCE4)));
