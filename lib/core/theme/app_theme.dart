import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF1B5E20),
        onPrimary: Colors.white,
        secondary: Color(0xFFA5D6A7),
        onSecondary: Color(0xFF143A17),
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: Color(0xFFF4FFF9),
        onSurface: Color(0xFF102114),
      ),
      scaffoldBackgroundColor: const Color(0xFFF4FFF9),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFA5D6A7),
        onPrimary: Color(0xFF062109),
        secondary: Color(0xFF1B5E20),
        onSecondary: Colors.white,
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        surface: Color(0xFF0E1A11),
        onSurface: Color(0xFFD6E7D8),
      ),
      scaffoldBackgroundColor: const Color(0xFF0E1A11),
    );
  }
}
