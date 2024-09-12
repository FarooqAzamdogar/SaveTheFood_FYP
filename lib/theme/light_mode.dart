import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade300,
    primary: Colors.grey.shade200,
    secondary: Colors.grey.shade500,
    surface: Colors.white, // Better visibility for cards and dialogs
    onPrimary: Colors.black, // Text color on primary background
    onSecondary: Colors.white, // Text color on secondary background
    onBackground: Colors.black, // Text color on the background
  ),
  textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.grey[800],
        displayColor: Colors.black,
      ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black, backgroundColor: Colors.grey.shade400, // Button text color
    ),
  ),
  cardColor: Colors.white,
  dialogBackgroundColor: Colors.white,
);
