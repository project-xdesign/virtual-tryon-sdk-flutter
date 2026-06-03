import 'package:flutter/material.dart';

/// Design tokens class to allow host apps (like Myntra or Souled Store) to customize the SDK's UI look & feel.
class SnapITTheme {
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final String? fontFamily;
  final double borderRadius;

  const SnapITTheme({
    this.primaryColor = const Color(0xFFD4FF00), // Default Acid Lemon
    this.backgroundColor = const Color(0xFF09090B), // Default Obsidian
    this.cardColor = const Color(0xFF18181B), // Zinc-900 card
    this.textColor = Colors.white,
    this.fontFamily,
    this.borderRadius = 16.0,
  });

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        surface: backgroundColor,
        onSurface: textColor,
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          color: textColor.withValues(alpha: 0.9),
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          color: textColor.withValues(alpha: 0.7),
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}
