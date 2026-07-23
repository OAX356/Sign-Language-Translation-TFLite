import 'package:flutter/material.dart';

class AppTheme {
  // Splash-inspired colors
  static const Color splashBackground = Color(0xFFE8E8F6);
  static const Color primaryTeal = Color(0xFF35B6AD);
  static const Color darkTeal = Color(0xFF257F77);
  static const Color deepTeal = Color(0xFF143F3E);
  static const Color darkText = Color(0xFF15151F);
  static const Color grayText = Color(0xFF5E5E6A);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: splashBackground,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      primary: primaryTeal,
      secondary: darkTeal,
      surface: Colors.white,
      background: splashBackground,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: splashBackground,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkText,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: darkText),
    ),

    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.92),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTeal,
        side: const BorderSide(color: primaryTeal, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),

    iconTheme: const IconThemeData(color: darkTeal),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: darkText,
        fontSize: 32,
        fontWeight: FontWeight.w900,
      ),
      headlineMedium: TextStyle(
        color: darkText,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: darkText,
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: darkText,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: darkText, fontSize: 16, height: 1.4),
      bodyMedium: TextStyle(color: grayText, fontSize: 14, height: 1.4),
    ),

    dividerTheme: DividerThemeData(color: darkTeal.withOpacity(0.14)),

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryTeal;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryTeal.withOpacity(0.35);
        }
        return Colors.grey.shade300;
      }),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: primaryTeal,
      inactiveTrackColor: primaryTeal.withOpacity(0.22),
      thumbColor: primaryTeal,
      overlayColor: primaryTeal.withOpacity(0.14),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xFF101817),

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.dark,
      primary: primaryTeal,
      secondary: darkTeal,
      surface: const Color(0xFF172221),
      background: const Color(0xFF101817),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF101817),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF172221),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTeal,
        side: const BorderSide(color: primaryTeal, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
