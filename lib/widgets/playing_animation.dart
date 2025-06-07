import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';

class PlayingAnimation extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final bool isCurrentSong;

  const PlayingAnimation({super.key, required this.audioPlayer, required this.isCurrentSong});

  @override
  Widget build(BuildContext context) {
    if (isCurrentSong) {
      return StreamBuilder(
        stream: audioPlayer.playingStream,
        builder: (context, snapshot) {
          final bool isPlaying = snapshot.data ?? false;
          if (isPlaying) {
            return ColorFiltered(
              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcATop),
              child: Lottie.asset('assets/visualizers/soundwave.json'),
            );
          } else {
            return const Icon(Icons.play_arrow_rounded);
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }
}