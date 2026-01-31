import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // === Primary Colors - Mystical Deep Purple ===
  static const Color primaryDark = Color(0xFF1A0A2E);
  static const Color primaryDeep = Color(0xFF2D1B4E);
  static const Color primaryMedium = Color(0xFF4A2C7A);
  static const Color primaryLight = Color(0xFF6B4D9E);
  
  // === Accent Colors - Sacred Gold ===
  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8D5A3);
  static const Color goldGlow = Color(0xFFFFF4D6);
  
  // === Secondary Colors ===
  static const Color roseDeep = Color(0xFF8B2252);
  static const Color roseLight = Color(0xFFE8A0BF);
  static const Color teal = Color(0xFF2D8B7A);
  
  // === Neutral Colors ===
  static const Color surfaceDark = Color(0xFF0D0518);
  static const Color surfaceCard = Color(0xFF1E1033);
  static const Color textPrimary = Color(0xFFF5F0FF);
  static const Color textSecondary = Color(0xFFB8A8D4);
  static const Color textMuted = Color(0xFF7A6A9A);
  
  // === Symbol Colors ===
  static const Color starGold = Color(0xFFFFD700);
  static const Color circleBlue = Color(0xFF4A90D9);
  static const Color triangleGreen = Color(0xFF4AD991);
  static const Color ravenPurple = Color(0xFF9B59B6);
  
  // === Gradients ===
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, surfaceDark],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient veilGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D1B4E),
      Color(0xFF1A0A2E),
      Color(0xFF0D0518),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFF7E7B2),
      Color(0xFFD4AF37),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const RadialGradient glowGradient = RadialGradient(
    colors: [
      Color(0x40D4AF37),
      Color(0x20D4AF37),
      Color(0x00D4AF37),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // === Shadows ===
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.5),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: goldPrimary.withValues(alpha: 0.3),
      blurRadius: 30,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> get subtleGlow => [
    BoxShadow(
      color: goldPrimary.withValues(alpha: 0.15),
      blurRadius: 15,
      spreadRadius: 1,
    ),
  ];

  // === Border Radius ===
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  // === Theme Data ===
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surfaceDark,
    colorScheme: const ColorScheme.dark(
      primary: goldPrimary,
      secondary: primaryLight,
      surface: surfaceCard,
      onPrimary: primaryDark,
      onSecondary: textPrimary,
      onSurface: textPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 1.5,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 1.2,
      ),
      displaySmall: GoogleFonts.cormorantGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 1.0,
      ),
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: goldLight,
        letterSpacing: 0.8,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      titleLarge: GoogleFonts.raleway(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.raleway(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.raleway(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      bodyLarge: GoogleFonts.raleway(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.raleway(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.raleway(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
      ),
      labelLarge: GoogleFonts.raleway(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: goldPrimary,
        letterSpacing: 1.5,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cormorantGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: goldLight,
        letterSpacing: 1.0,
      ),
      iconTheme: const IconThemeData(color: goldLight),
    ),
    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: BorderSide(color: primaryMedium.withValues(alpha: 0.3)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: goldPrimary,
        foregroundColor: primaryDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: GoogleFonts.raleway(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: goldLight,
        side: const BorderSide(color: goldPrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: GoogleFonts.raleway(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: primaryMedium.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: primaryMedium.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: goldPrimary, width: 1.5),
      ),
      labelStyle: GoogleFonts.raleway(
        color: textSecondary,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.raleway(
        color: textMuted,
        fontSize: 14,
      ),
    ),
    iconTheme: const IconThemeData(
      color: goldLight,
      size: 24,
    ),
    dividerTheme: DividerThemeData(
      color: primaryMedium.withValues(alpha: 0.3),
      thickness: 1,
    ),
  );
}
