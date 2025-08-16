import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // MagicCraft Color Palette
  static const Color midnightBlue = Color(0xFF1A1B2F);
  static const Color arcanePurple = Color(0xFF6E4B9E);
  static const Color shimmeringGold = Color(0xFFF1C40F);
  static const Color darkPurple = Color(0xFF2D1B3D);
  static const Color lightPurple = Color(0xFF8B5FBF);

  // Gradient Colors
  static const LinearGradient magicGradient = LinearGradient(
    colors: [arcanePurple, darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [shimmeringGold, Color(0xFFE6B800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Duration magicAnimationDuration = Duration(milliseconds: 800);
  static const Duration quickAnimationDuration = Duration(milliseconds: 300);
  static const Curve magicCurve = Curves.easeInOutCubic;

  static const LinearGradient enchantedGradient = LinearGradient(
    colors: [Color(0xFF6E4B9E), Color(0xFF8B5FBF), Color(0xFF2D1B3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient spellGradient = LinearGradient(
    colors: [Color(0xFFF1C40F), Color(0xFFE6B800), Color(0xFFD4AC0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient orbGradient = RadialGradient(
    colors: [Color(0xFF8B5FBF), Color(0xFF6E4B9E), Color(0xFF2D1B3D)],
    stops: [0.0, 0.7, 1.0],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: midnightBlue,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: arcanePurple,
        secondary: shimmeringGold,
        surface: darkPurple,
        background: midnightBlue,
        onPrimary: Colors.white,
        onSecondary: midnightBlue,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: shimmeringGold,
          ),
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: shimmeringGold),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: darkPurple.withOpacity(0.8),
        elevation: 8,
        shadowColor: arcanePurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: arcanePurple.withOpacity(0.3), width: 1),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: arcanePurple,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: arcanePurple.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkPurple.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: arcanePurple.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: arcanePurple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: shimmeringGold, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkPurple,
        selectedItemColor: shimmeringGold,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
    );
  }
}
