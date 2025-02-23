import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class ThemeColors {
  static const Color primaryColor = Color(0xFFAAC9FF);
  static const Color darkPrimaryColor = Color(0xFF6A3DE8); // Previous color 7B93F6

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
      error: Color(0xFFFFAAC9),
      onError: Colors.white,
      surface: Colors.black, // Top bar, card, background
      onSurface: Colors.white,
      surfaceVariant: Color(0xFF757575), // Disable switch background, textfield filled
      outlineVariant: Color(0xFF757575), // Divider
      inverseSurface: Color(0xFF1D2530), // Snack bar
      onInverseSurface: Colors.white,
      surfaceTint: Colors.black,
    ),
    dialogBackgroundColor: const Color(0xFF1D2530),
    hintColor: const Color(0xFF616161),
    scaffoldBackgroundColor: Colors.black,
    splashColor: Colors.transparent,
    unselectedWidgetColor: const Color(0xFF616161),
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
      thumbColor: MaterialStateProperty.all(primaryColor),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    ),
  );
}

abstract class Styles {
  static TextStyle songHomeTitle(BuildContext context, bool isCurrentSong) {
    return TextStyle(
      color: isCurrentSong ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
      fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
      fontSize: 18,
    );
  }

  static TextStyle hintText = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
}

abstract class IconSizes {
  static const double iconBtnSize = 35;
}

abstract class Artworks {
  static double artworkSmallSize = 50;

  static QueryArtworkWidget artworkStyle(BuildContext context, int songId, double imgWidth) {
    return QueryArtworkWidget(
      id: songId,
      type: ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      artworkWidth: imgWidth,
      artworkHeight: imgWidth,
      artworkQuality: FilterQuality.low,
      artworkBorder: BorderRadius.circular(10.0),
      nullArtworkWidget: noArtworkStyle(context, imgWidth),
    );
  }

  static Container noArtworkStyle(BuildContext context, double imgWidth) {
    return Container(
      width: imgWidth,
      height: imgWidth,
      decoration: BoxDecoration(color: Theme.of(context).dialogBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
      child: Icon(Icons.music_note_rounded, color: Theme.of(context).colorScheme.primary, size: imgWidth/2),
    );
  }

  static Container errorArtworkStyle(BuildContext context, double imgWidth) {
    return Container(
      width: imgWidth,
      height: imgWidth,
      decoration: BoxDecoration(color: Theme.of(context).dialogBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
      child: Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error, size: imgWidth/2),
    );
  }
}