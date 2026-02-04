import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WhiteLabelTheme {
  // --- Core Palette (Square/Stripe Inspired) ---
  static const Color primaryBlack = Color(0xFF1A1A1A); // The "Ink" color
  static const Color primaryBlue = Color(0xFF006CFF); // Action Blue
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF7F7F7); // Very subtle grey
  static const Color borderGrey = Color(0xFFE5E5E5);
  static const Color textDark = Color(0xFF111111);
  static const Color textGrey = Color(0xFF757575);
  static const Color dangerRed = Color(0xFFD92D20);
  static const Color successGreen = Color(0xFF039855);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.light(
        primary: primaryBlack, // Buttons are often black in POS
        secondary: primaryBlue,
        surface: surfaceWhite,
        background: backgroundLight,
        error: dangerRed,
        onPrimary: Colors.white,
      ),

      // --- Typography (Inter & Outfit) ---
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32.sp,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.5,
        ),
        // Item Names
        titleLarge: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        // List Items
        bodyLarge: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: textGrey,
        ),
      ),

      // --- Components ---

      // Cards (Flat, Borders)
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: borderGrey, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Buttons (Big Touch Targets)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlack,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r), // Slightly squarer
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          textStyle: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Inputs (Clean, Minimal)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: textGrey),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.outfit(
          color: textDark,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
        shape: const Border(bottom: BorderSide(color: borderGrey, width: 1)),
      ),

      // Bottom Nav
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceWhite,
        indicatorColor: primaryBlue.withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryBlue);
          }
          return const IconThemeData(color: textGrey);
        }),
      ),
    );
  }
}
