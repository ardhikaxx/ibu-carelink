import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Curated Colors
  static const Color primaryRose = Color(0xFFE85A71);
  static const Color primaryTeal = Color(0xFF00A896);
  static const Color accentWarm = Color(0xFFF2C14E);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterialDesign: true,
      brightness: Brightness.light,
      primaryColor: primaryRose,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryRose,
        secondary: primaryTeal,
        tertiary: accentWarm,
        surface: lightSurface,
        error: errorRed,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      cardTheme: CardTheme(
        color: lightSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRose,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterialDesign: true,
      brightness: Brightness.dark,
      primaryColor: primaryRose,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryRose,
        secondary: primaryTeal,
        tertiary: accentWarm,
        surface: darkSurface,
        error: errorRed,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRose,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
