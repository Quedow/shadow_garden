import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shadow_garden/style/style.dart';

class PlayingAnimation extends StatelessWidget {
  final bool isCurrentSong;
  final bool isPlaying;

  const PlayingAnimation({super.key, required this.isCurrentSong, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    if (isCurrentSong) {
      if (isPlaying) {
        return ColorFiltered(
          colorFilter: const ColorFilter.mode(ThemeColors.accentColor, BlendMode.srcATop),
          child: Lottie.asset('assets/icons/soundwave.json'),
        );
      } else {
        return const Icon(Icons.play_arrow_rounded);
      }
    } else {
      return const SizedBox();
    }
  }
}