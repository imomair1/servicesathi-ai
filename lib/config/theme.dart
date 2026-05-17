import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.surfaceLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.electricBlue,
          secondary: AppColors.purpleDeep,
          surface: AppColors.surfaceCard,
          error: AppColors.error,
        ),
        textTheme: _textTheme(AppColors.textPrimary, AppColors.textSecondary),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceLight,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderLight, width: 1),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceCard,
          selectedItemColor: AppColors.electricBlue,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintStyle: GoogleFonts.outfit(
            color: AppColors.textTertiary,
            fontSize: 15,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.electricBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.electricBlue,
          secondary: AppColors.purpleDeep,
          surface: AppColors.darkCard,
          error: AppColors.error,
        ),
        textTheme:
            _textTheme(AppColors.textDarkPrimary, AppColors.textDarkSecondary),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.textDarkPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.cyan,
          unselectedItemColor: AppColors.textDarkSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintStyle: GoogleFonts.outfit(
            color: AppColors.textDarkSecondary,
            fontSize: 15,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.electricBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        displayLarge: GoogleFonts.outfit(
            fontSize: 32, fontWeight: FontWeight.w700, color: primary),
        displayMedium: GoogleFonts.outfit(
            fontSize: 28, fontWeight: FontWeight.w700, color: primary),
        displaySmall: GoogleFonts.outfit(
            fontSize: 24, fontWeight: FontWeight.w600, color: primary),
        headlineMedium: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w600, color: primary),
        titleLarge: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w600, color: primary),
        titleMedium: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w500, color: primary),
        titleSmall: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w500, color: primary),
        bodyLarge: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w400, color: primary),
        bodyMedium: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
        bodySmall: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
        labelLarge: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      );
}
