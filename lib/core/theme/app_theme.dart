import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised theme definitions for the Santo Rosaryo app.
///
/// Both light and dark themes follow the QuestUI design system:
/// Primary Gold (#CA8A04), Deep Red (#991B1B), parchment-brown surfaces.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5E6D3),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFCA8A04),
          secondary: Color(0xFF991B1B),
          surface: Color(0xFFE5D3BD),
          error: Color(0xFF991B1B),
        ),
        textTheme: GoogleFonts.spectralTextTheme(
          ThemeData.light().textTheme,
        ),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A0F0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFCA8A04),
          secondary: Color(0xFF991B1B),
          surface: Color(0xFF2C1A10),
          error: Color(0xFF991B1B),
        ),
        textTheme: GoogleFonts.spectralTextTheme(
          ThemeData.dark().textTheme,
        ),
      );
}
