import 'package:flutter/material.dart';

abstract class ThemeColors {
  static const primaryColor = Colors.white;
  static const accentColor = Color(0xFFFBC711);
  static const secondaryColor = Color.fromARGB(255, 29, 37, 48);

  static const backgroundOled = Color.fromARGB(255, 0, 0, 0);
}

abstract class IconSizes {
  static const double iconBtnSize = 35;
}

abstract class Styles {
  static TextStyle audioLeadingTextStyle = const TextStyle(color: ThemeColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w500);

  static TextStyle trackHomeTitle(bool isCurrentItem) {
    return TextStyle(
      color: isCurrentItem ? ThemeColors.accentColor : ThemeColors.primaryColor,
      fontWeight: isCurrentItem ? FontWeight.bold : FontWeight.normal,
      fontSize: 18,
    );
  }

  static TextStyle trackPageTilte = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 22);
  
  static TextStyle trackPageSubtitle = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.normal, fontSize: 14);

  static TextStyle trackBannerTitle = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 18);

  static TextStyle trackBannerSubtitle = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.w500, fontSize: 16);

  static TextStyle progressBarTime = const TextStyle(color: ThemeColors.primaryColor, fontWeight: FontWeight.w500);
}