import 'package:flutter/material.dart';

class ThemeColors {
  static const Color primaryColor = Color(0xFFAAC9FF);
  static const Color darkPrimaryColor = Color(0xFF6A3DE8); // Previous color 7B93F6
  static const Color darkBlueGrey = Color(0xFF1D2530);
  static const Color errorColor = Color(0xFFFFAAC9);

  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: darkPrimaryColor,
      secondary: Colors.white,
      onSecondary: Colors.black,
      tertiary: Color(0xFFBDBDBD),
      error: errorColor,
      onError: Colors.white,
      surface: Colors.black, // Top bar, card, background
      onSurface: Colors.white,
      surfaceContainerHighest : Color(0xFF757575), // Disable switch background, textfield filled
      outlineVariant: Color(0xFF757575), // Divider
      inverseSurface: darkBlueGrey, // Snack bar
      onInverseSurface: Colors.white,
      surfaceTint: Colors.black,
    ),
    hintColor: const Color(0xFF616161),
    scaffoldBackgroundColor: Colors.black,
    splashColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    unselectedWidgetColor: const Color(0xFF616161),
    dialogTheme: const DialogThemeData(
      backgroundColor: darkBlueGrey,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    sliderTheme: const SliderThemeData(
      activeTickMarkColor: darkPrimaryColor,
      inactiveTrackColor: Color(0xFFEEEEEE),
      inactiveTickMarkColor: primaryColor,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(primaryColor),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      
      // Text styles not setup
      headlineLarge: TextStyle(color: errorColor),
      headlineMedium: TextStyle(color: errorColor),
      displayLarge: TextStyle(color: errorColor),
      displayMedium: TextStyle(color: errorColor),
      displaySmall: TextStyle(color: errorColor),
      titleSmall: TextStyle(color: errorColor),
      bodyMedium: TextStyle(color: errorColor),
      bodySmall: TextStyle(color: errorColor),
      labelSmall: TextStyle(color: errorColor),
    ),
  );
}

class DesignSystem {
  static const double scrollbarThickness = 6.0;
  static const double iconBtnSize = 35;
  static const double artworkSmallSize = 50;
  static const double artworkBannerSize = 45;
}