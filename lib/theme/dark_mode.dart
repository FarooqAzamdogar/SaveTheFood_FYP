import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade600,
    surface: Colors.grey.shade800, // Better visibility for cards and dialogs
    onPrimary: Colors.white, // Text color on primary background
    onSecondary: Colors.black, // Text color on secondary background
    onBackground: Colors.white, // Text color on the background
  ),
  textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.grey[300],
        displayColor: Colors.white,
      ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: Colors.grey.shade700, // Button text color
    ),
  ),
  cardColor: Colors.grey.shade800,
  dialogBackgroundColor: Colors.grey.shade800,
);
