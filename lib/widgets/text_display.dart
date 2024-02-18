import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class MarqueeTitle extends StatelessWidget {
  final String title;
  final double availableWidth;
  final TextStyle textStyle;

  const MarqueeTitle({Key? key, required this.title, required this.availableWidth, required this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double titleWidth = (textStyle.fontSize ?? 18) * title.length;

    if (titleWidth > availableWidth) {
      return SizedBox(height: 25, child: MarqueeText(title: title, textStyle: textStyle));
    } else {
      return SizedBox(height: 25, child: Text(title, style: textStyle));
    }
  }
}

class MarqueeSubtitle extends StatelessWidget {
  final String? album;
  final String? artist;
  final double availableWidth;
  final TextStyle textStyle;

  const MarqueeSubtitle({Key? key, this.album, this.artist, required this.textStyle, required this.availableWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String albumStr = album ?? '';
    String artistStr = artist ?? '';

    String subtitle = albumStr.isNotEmpty && artistStr.isNotEmpty 
      ? '$albumStr - $artistStr' 
      : albumStr.isNotEmpty ? albumStr : artistStr;

    // return Text(subtitle, style: textStyle);
    return MarqueeTitle(title: subtitle, availableWidth: availableWidth, textStyle: textStyle);
  }
}

class MarqueeText extends StatelessWidget {
  final String title;
  final TextStyle textStyle;

  const MarqueeText({Key? key, required this.title, required this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: title,
      style: textStyle,
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 20.0,
      velocity: 35.0,
      startPadding: 8.0,
      accelerationCurve: Curves.linear,
    );
  }
}

class TitleText extends StatelessWidget {
  final String title;
  final TextStyle textStyle;

  const TitleText({Key? key, required this.title, required this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

class SubtitleText extends StatelessWidget {
  final String? album;
  final String? artist;
  final TextStyle textStyle;

  const SubtitleText({Key? key, this.album, this.artist, required this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String albumStr = album ?? '';
    String artistStr = artist ?? '';

    String subtitle = albumStr.isNotEmpty && artistStr.isNotEmpty 
      ? '$albumStr - $artistStr' 
      : albumStr.isNotEmpty ? albumStr : artistStr;

    return Text(subtitle, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}