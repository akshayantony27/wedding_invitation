import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();
  static const blush = Color(0xFFFBE4E1);
  static const peach = Color(0xFFFDEADB);
  static const cream = Color(0xFFFFF8F4);
  static const rose = Color(0xFFE79AA3);
  static const deepRose = Color(0xFFC4606F);
  static const blushDeep = Color(0xFFF6CBC9);
  static const forest = Color(0xFF1F3D2B);
  static const leaf = Color(0xFF3F6B4C);
  static const leafLight = Color(0xFF8DB08E);
  static const gold = Color(0xFFCDAA6D);
  static const wax = Color(0xFF9C2C3A);
}

class AppText {
  AppText._();

  /// Calligraphy for the couple's names and flourishes.
  static TextStyle script(double size, {Color color = AppColors.forest}) =>
      GoogleFonts.greatVibes(fontSize: size, color: color, height: 1.15);

  /// Elegant serif for body text.
  static TextStyle serif(
    double size, {
    FontWeight weight = FontWeight.w500,
    FontStyle style = FontStyle.normal,
    Color color = AppColors.forest,
    double letterSpacing = 0,
    double height = 1.35,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight,
        fontStyle: style,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// Classical capitals for the parents' names and button labels.
  static TextStyle caps(double size,
          {Color color = AppColors.forest, double letterSpacing = 2.5, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.cinzel(
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
        fontWeight: weight,
        height: 1.4,
      );
}

class AppTheme {
  AppTheme._();
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.rose, brightness: Brightness.light),
        scaffoldBackgroundColor: AppColors.blush,
        textTheme: GoogleFonts.cormorantGaramondTextTheme(),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      );
}

class Responsive {
  Responsive._();
  static const double maxContent = 640;

  /// Type/spacing multiplier: 1.0 at a 390px phone, grows gently up to 1.4.
  static double scale(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (math.min(w, 720.0) / 390.0).clamp(0.85, 1.4).toDouble();
  }

  static bool isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= 900;
}
