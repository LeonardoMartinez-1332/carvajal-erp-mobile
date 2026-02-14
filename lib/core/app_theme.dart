import 'package:flutter/material.dart';
// Si usas google_fonts, descomenta:
// import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
    static const primary = Color(0xFF0D47A1); // azul barra
    static const primaryDark = Color(0xFF08306B);
    static const accent = Color(0xFF1565C0);

    // Fondo degradado
    static const bgA = Color(0xFFEBF3FA);
    static const bgB = Color(0xFFE3F2FD);
    static const bgC = Color(0xFFE8EAF6);

    // Tarjetas
    static const card = Colors.white;

    // Estados
    static const info = Color(0xFF1E88E5);
    static const success = Color(0xFF43A047);
    static const warning = Color(0xFFFFA726);
    static const danger = Color(0xFFF4511E);

    // Texto
    static const textPrimary = Color(0xFF102027);
    static const textSecondary = Color(0xFF546E7A);
}

class AppTheme {
    static ThemeData light() {
        // Base con Material 3 y tu seed color corporativo
        final base = ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
            primary: AppColors.primary,
            secondary: AppColors.accent,
        ),
        useMaterial3: true,
        );

        // final textTheme = GoogleFonts.interTextTheme(base.textTheme); // opcional

        return base.copyWith(
        // textTheme: textTheme,

        // ===== Fondo general =====
        scaffoldBackgroundColor: Colors.white,

        // ===== AppBar global =====
        appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: false,
        ),

        // ===== Card global (fix: CardThemeData en vez de CardTheme) =====
        cardTheme: const CardThemeData(
            color: AppColors.card,
            elevation: 2,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
        ),

        // ===== Inputs (TextField, DropdownButtonFormField, etc.) =====
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(
            color: Colors.black54,
            ),
        ),

        // ===== SnackBars =====
        snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            contentTextStyle: TextStyle(color: Colors.white),
            actionTextColor: Colors.white,
        ),

        // ===== FAB extendido =====
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            extendedPadding: EdgeInsets.symmetric(horizontal: 16),
            elevation: 3,
        ),
        );
    }
}
