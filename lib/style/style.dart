import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class ThemeColors {
  static const Color primaryColor = Colors.white;

  static const Color accentColor = Color(0xFFAAC9FF);

  static const Color darkAccentColor = Color(0xFF7b93f6);

  static const Color secondaryColor = Color.fromARGB(255, 29, 37, 48); 

  static const Color backgroundOled = Color.fromARGB(255, 0, 0, 0);
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
      artworkBorder: BorderRadius.circular(10.0),
      nullArtworkWidget: noArtworkStyle(imgWidth),
    );
  }

  static Container noArtworkStyle(double imgWidth) {
    return Container(
      width: imgWidth,
      height: imgWidth,
      decoration: BoxDecoration(color: ThemeColors.secondaryColor, borderRadius: BorderRadius.circular(10.0)),
      child: Icon(Icons.music_note_rounded, color: ThemeColors.accentColor, size: imgWidth/2),
    );
  }
}

abstract class Styles {
  // Songs screen
  static TextStyle audioLeadingTextStyle = const TextStyle(color: ThemeColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w500);

  static TextStyle songHomeTitle(bool isCurrentSong) {
    return TextStyle(
      color: isCurrentSong ? ThemeColors.accentColor : ThemeColors.primaryColor,
      fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
      fontSize: 18,
    );
  }

  // Song banner
  static TextStyle songBannerTitle = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 18);

  static TextStyle trackBannerSubtitle = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.w500, fontSize: 16);

  // Bottom sheet screen
  static TextStyle songSheetTilte = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 22);
  
  static TextStyle songSheetSubtitle = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.normal, fontSize: 14);

  static TextStyle progressBarTime = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.w500);

  static TextStyle numberPickerSelect = TextStyle(color: ThemeColors.primaryColor.withOpacity(0.8), fontSize: 24, fontWeight: FontWeight.w300);
  
  static TextStyle numberPicker = TextStyle(color: ThemeColors.primaryColor.withOpacity(0.15));

  // Settings screen
  static TextStyle settingsTitle = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.normal, fontSize: 16);
  
  static TextStyle settingsDescription = TextStyle(color: ThemeColors.primaryColor.withOpacity(0.7), fontWeight: FontWeight.normal, fontSize: 14);

  // Statistic screen
  static TextStyle statisticLabel = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.normal, fontSize: 16);
}