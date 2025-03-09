import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:shadow_garden/utils/functions.dart';

class MarqueeSingle extends StatelessWidget {
  final String title;
  final double availableWidth;
  final TextStyle? textStyle;

  const MarqueeSingle({super.key, required this.title, required this.availableWidth, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final double labelWidth = (textStyle?.fontSize ?? 18) * title.length;
    final double labelHeight = Functions.getTextHeight(title, textStyle, availableWidth, verticalOffset: 1.5);

    if (labelWidth > availableWidth) {
      return SizedBox(height: labelHeight, child: MarqueeText(label: title, textStyle: textStyle));
    } else {
      return SizedBox(height: labelHeight, child: Text(title, style: textStyle));
    }
  }
}

class MarqueeMultiple extends StatelessWidget {
  final List<String?> labels;
  final double availableWidth;
  final TextStyle? textStyle;

  const MarqueeMultiple({super.key, required this.labels, required this.availableWidth, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final String content = labels.where((label) => label != null && label.isNotEmpty).join(' - ');

    return MarqueeSingle(
      title: content,
      availableWidth: availableWidth,
      textStyle: textStyle,
    );
  }
}

class MarqueeText extends StatelessWidget {
  final String label;
  final TextStyle? textStyle;

  const MarqueeText({super.key, required this.label, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: label,
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
  final TextStyle? textStyle;

  const TitleText({super.key, required this.title, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

class SubtitleText extends StatelessWidget {
  final String? album;
  final String? artist;
  final TextStyle? textStyle;

  const SubtitleText({super.key, this.album, this.artist, this.textStyle});

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