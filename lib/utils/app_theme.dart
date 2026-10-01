import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme configuration for aesthetic dark blue & Foodpanda style
class AppTheme {
  // Light theme - aesthetic dark blue & clean surfaces
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.electricBlue,
          secondary: AppColors.skyAccent,
          surface: AppColors.lightSurface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.lightText,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightText,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 1.5,
          shadowColor: AppColors.midnightNavy.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.electricBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.softIce,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.softBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.softBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.electricBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.electricBlue,
          unselectedItemColor: AppColors.lightTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.midnightNavy,
          contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.softBorder,
          thickness: 1,
        ),
      );

  // Dark theme - deep midnight navy & cyan/sky accents
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.skyAccent,
          secondary: AppColors.electricBlue,
          surface: AppColors.darkSurface,
          error: AppColors.error,
          onPrimary: AppColors.midnightNavy,
          onSecondary: Colors.white,
          onSurface: AppColors.darkText,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkText,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 2,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.electricBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 3,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.skyAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.skyAccent,
          unselectedItemColor: AppColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.deepNavy,
          contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white.withValues(alpha: 0.08),
          thickness: 1,
        ),
      );
}
