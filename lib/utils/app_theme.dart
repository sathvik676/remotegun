import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF060A12);
  static const Color surface = Color(0xFF101827);
  static const Color surfaceAlt = Color(0xFF162033);
  static const Color border = Color(0xFF22304A);
  static const Color cyan = Color(0xFF25E6E6);
  static const Color violet = Color(0xFF8B7CFF);
  static const Color green = Color(0xFF37E6A0);
  static const Color amber = Color(0xFFFFC857);
  static const Color red = Color(0xFFFF4D5E);
  static const Color textPrimary = Color(0xFFEAF2FF);
  static const Color textMuted = Color(0xFF8EA1BF);

  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      primary: cyan,
      onPrimary: background,
      secondary: violet,
      onSecondary: Colors.white,
      error: red,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      outline: border,
    );

    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: red),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: background,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cyan,
          side: const BorderSide(color: cyan),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: cyan,
        inactiveTrackColor: border,
        thumbColor: cyan,
        overlayColor: cyan.withOpacity(0.18),
        valueIndicatorColor: cyan,
        valueIndicatorTextStyle: const TextStyle(color: background),
        trackHeight: 6,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.withOpacity(0.96),
        selectedItemColor: cyan,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceAlt,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: border.withOpacity(0.7),
        thickness: 1,
      ),
    );
  }

  static LinearGradient pageGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF060A12),
        Color(0xFF0A1120),
        Color(0xFF080D18),
      ],
    );
  }

  static LinearGradient cardGradient(Color accent) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accent.withOpacity(0.16),
        surface.withOpacity(0.95),
      ],
    );
  }
}
