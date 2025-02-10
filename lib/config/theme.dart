import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const primaryColor = Color(0xFF1A237E); // Deep Indigo
  static const secondaryColor = Color(0xFFFF3D00); // Deep Orange

  // Background colors
  static const backgroundColor = Color(0xFF1A237E); // Deep Indigo
  static const surfaceColor = Color(0xFF283593); // Slightly lighter Indigo
  static const cardColor = Color(0xFF303F9F); // Even lighter Indigo

  // Text colors
  static const primaryTextColor = Colors.white;
  static const secondaryTextColor = Color(0xFFE8EAF6); // Light Indigo
  static const disabledTextColor = Color(0xFF9FA8DA); // Lighter Indigo

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: primaryTextColor,
      onSecondary: primaryTextColor,
      onBackground: primaryTextColor,
      onSurface: primaryTextColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: surfaceColor,

    // Text theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: primaryTextColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: primaryTextColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: primaryTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: primaryTextColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: secondaryTextColor,
        fontSize: 14,
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: secondaryTextColor),
      hintStyle: const TextStyle(color: disabledTextColor),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: primaryTextColor,
        backgroundColor: secondaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTextColor,
        side: const BorderSide(color: secondaryTextColor),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryTextColor,
      ),
    ),
  );
}
