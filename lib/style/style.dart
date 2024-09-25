import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class ThemeColors {
  static const Color primaryColor = Colors.white;
  static const Color primaryColor02 = Color(0x33FFFFFF);
  static const Color primaryColor03 = Color(0x4DFFFFFF);
  static const Color primaryColor04 = Color(0x66FFFFFF);
  static const Color primaryColor07 = Color(0xB3FFFFFF);

  static const Color accentColor = Color(0xFFAAC9FF);
  static const Color darkAccentColor = Color(0xFF7B93F6);

  static const Color errorColor = Color(0xFFFFAAC9);
  static const Color otherColor = Color(0xFF1D2530);
  static const Color backgroundOled = Color(0xFF000000);
}

abstract class IconSizes {
  static const double iconBtnSize = 35;
}

abstract class Artworks {
  static double artworkSmallSize = 50;

  static QueryArtworkWidget artworkStyle(int songId, double imgWidth) {
    return QueryArtworkWidget(
      id: songId,
      type: ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      artworkWidth: imgWidth,
      artworkHeight: imgWidth,
      artworkQuality: FilterQuality.medium,
      artworkBorder: BorderRadius.circular(10.0),
      nullArtworkWidget: noArtworkStyle(imgWidth),
    );
  }

  static Container noArtworkStyle(double imgWidth) {
    return Container(
      width: imgWidth,
      height: imgWidth,
      decoration: BoxDecoration(color: ThemeColors.otherColor, borderRadius: BorderRadius.circular(10.0)),
      child: Icon(Icons.music_note_rounded, color: ThemeColors.accentColor, size: imgWidth/2),
    );
  }

  static Container errorArtworkStyle(double imgWidth) {
    return Container(
      width: imgWidth,
      height: imgWidth,
      decoration: BoxDecoration(color: ThemeColors.otherColor, borderRadius: BorderRadius.circular(10.0)),
      child: Icon(Icons.error_outline_rounded, color: ThemeColors.errorColor, size: imgWidth/2),
    );
  }
}

abstract class Styles {
  static TextStyle songHomeTitle(bool isCurrentSong) {
    return TextStyle(
      color: isCurrentSong ? ThemeColors.accentColor : ThemeColors.primaryColor,
      fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
      fontSize: 18,
    );
  }

  static TextStyle titleLarge = const TextStyle(fontSize: 24, fontWeight: FontWeight.w300);
  static TextStyle titleMedium = const TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
  static TextStyle subtitleLarge = const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
  static TextStyle subtitleMedium = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle labelLarge = const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
}