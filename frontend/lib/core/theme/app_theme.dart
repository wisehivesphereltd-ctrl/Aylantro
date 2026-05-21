import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF800000); // Maroon
  static const Color secondaryColor = Color(0xFFAA3333);
  static const Color accentColor = Color(0xFFD4AF37); // Gold
  
  // Dark Colors
  static const Color darkBackgroundColor = Color(0xFF0F0F12);
  static const Color darkSurfaceColor = Color(0xFF1E1E26);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF9E9EAE);

  // Light Colors
  static const Color lightBackgroundColor = Color(0xFFF8F9FA);
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6C757D);

  // Compatibility Aliases (Default to Dark)
  static const Color backgroundColor = darkBackgroundColor;
  static const Color surfaceColor = darkSurfaceColor;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;

  static ThemeData get darkTheme {
    return _baseTheme(Brightness.dark);
  }

  static ThemeData get lightTheme {
    return _baseTheme(Brightness.light);
  }

  static ThemeData _baseTheme(Brightness brightness) {
    bool isDark = brightness == Brightness.dark;
    Color bg = isDark ? darkBackgroundColor : lightBackgroundColor;
    Color surface = isDark ? darkSurfaceColor : lightSurfaceColor;
    Color text = isDark ? darkTextPrimary : lightTextPrimary;
    Color textSub = isDark ? darkTextSecondary : lightTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      colorScheme: isDark 
        ? const ColorScheme.dark(primary: primaryColor, secondary: secondaryColor, surface: darkSurfaceColor)
        : const ColorScheme.light(primary: primaryColor, secondary: secondaryColor, surface: Colors.white),
      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: text, letterSpacing: -0.5),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: text),
          bodyLarge: TextStyle(fontSize: 16, color: text),
          bodyMedium: TextStyle(fontSize: 14, color: textSub),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: isDark ? 8 : 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black12,
      ),
    );
  }
}
