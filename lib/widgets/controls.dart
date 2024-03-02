// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
// import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:numberpicker/numberpicker.dart';
// import 'package:shadow_garden/utils/functions.dart';

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const Controls({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: audioPlayer.seekToPrevious,
          iconSize: IconSizes.iconBtnSize,
          color: ThemeColors.primaryColor,
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        PlayButton(audioPlayer: audioPlayer),
        IconButton(
          onPressed: audioPlayer.seekToNext,
          iconSize: IconSizes.iconBtnSize,
          color: ThemeColors.primaryColor,
          icon: const Icon(Icons.skip_next_rounded),
        ),
        LoopButton(audioPlayer: audioPlayer)
      ],
    );
  }
}

class PlayButton extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const PlayButton({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (!(playing ?? false)) {
          return IconButton(
            onPressed: audioPlayer.play,
            iconSize: IconSizes.iconBtnSize,
            color: ThemeColors.primaryColor,
            icon: const Icon(Icons.play_arrow_rounded),
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            onPressed: audioPlayer.pause,
            iconSize: IconSizes.iconBtnSize,
            color: ThemeColors.primaryColor,
            icon: const Icon(Icons.pause_rounded),
          );
        }
        return const Icon(
          Icons.play_arrow_rounded,
          size: IconSizes.iconBtnSize,
          color: ThemeColors.primaryColor,
        );
      },
    );
  }
}

// class LoopButton extends StatefulWidget {
//   final AudioPlayer audioPlayer;
//   final int n; // Number of songs to repeat in custom loop mode

//   const LoopButton({Key? key, required this.audioPlayer, this.n = 2}) : super(key: key);

//   @override
//   _LoopButtonState createState() => _LoopButtonState();
// }

// class _LoopButtonState extends State<LoopButton> { 

//   @override
//   void initState() {
//     super.initState();
//     widget.audioPlayer.positionDiscontinuityStream.listen((discontinuity) {
//       if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance) {
//         print("new song______________________________4");  
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<LoopMode>(
//       stream: widget.audioPlayer.loopModeStream,
//       builder: (context, snapshot) {
//         final LoopMode loopMode = snapshot.data ?? LoopMode.all;

//         if (loopMode == LoopMode.off) {
//           return IconButton(
//             onPressed: () => widget.audioPlayer.setLoopMode(LoopMode.all),
//             iconSize: IconSizes.iconBtnSize,
//             color: ThemeColors.primaryColor,
//             icon: Icon(Icons.repeat_rounded, color: ThemeColors.primaryColor.withOpacity(0.5)),
//           );
//         } else if (loopMode == LoopMode.all) {
//           return IconButton(
//             onPressed: () => widget.audioPlayer.setLoopMode(LoopMode.one),
//             iconSize: IconSizes.iconBtnSize,
//             color: ThemeColors.primaryColor,
//             icon: const Icon(Icons.repeat_rounded, color: ThemeColors.primaryColor),
//           );
//         } else if (loopMode == LoopMode.one) {
//           return IconButton(
//             onPressed: () => widget.audioPlayer.setLoopMode(LoopMode.off), // We'll handle the looping manually
//             iconSize: IconSizes.iconBtnSize,
//             color: ThemeColors.primaryColor,
//             icon: const Icon(Icons.repeat_one_rounded, color: ThemeColors.primaryColor),
//           );
//         } else {
//           return IconButton(
//             onPressed: () => widget.audioPlayer.setLoopMode(LoopMode.off),
//             iconSize: IconSizes.iconBtnSize,
//             color: ThemeColors.primaryColor,
//             icon: const Icon(Icons.repeat_one_rounded, color: ThemeColors.primaryColor),
//           );
//         }
//       },
//     );
//   }
// }

// class LoopButton extends StatelessWidget {
//   final AudioPlayer audioPlayer;

//   const LoopButton({Key? key, required this.audioPlayer}) : super(key: key);

class LoopButton extends StatefulWidget {
  final AudioPlayer audioPlayer;
  
  const LoopButton({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  State<LoopButton> createState() => _LoopButtonState();
}

class _LoopButtonState extends State<LoopButton> {
  late AudioProvider _audioProvider;

  @override
  void initState() {
    super.initState();
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoopMode>(
      stream: widget.audioPlayer.loopModeStream,
      builder: (context, snapshot) {
        final LoopMode loopMode = snapshot.data ?? LoopMode.all;

        if (loopMode == LoopMode.off) {
          return IconButton(
            onPressed: () => customLoopMode(),
            iconSize: IconSizes.iconBtnSize,
            color: ThemeColors.primaryColor,
            icon: Icon(Icons.repeat_rounded, color: ThemeColors.primaryColor.withOpacity(0.5)),
          );
        } else if (loopMode == LoopMode.all) {
            return IconButton(
              onPressed: () => widget.audioPlayer.setLoopMode(LoopMode.one),
              iconSize: IconSizes.iconBtnSize,
              color: ThemeColors.primaryColor,
              icon: const Icon(Icons.repeat_rounded, color: ThemeColors.primaryColor),
            );
        }
        return IconButton(
          onPressed: () => widget.audioPlayer.setLoopMode(LoopMode.off),
          iconSize: IconSizes.iconBtnSize,
          color: ThemeColors.primaryColor,
          icon: const Icon(Icons.repeat_one_rounded, color: ThemeColors.primaryColor),
        );
      }
    );
  }

  void customLoopMode() {
    widget.audioPlayer.setLoopMode(LoopMode.all);
    _audioProvider.setCustomLoop(widget.audioPlayer.currentIndex ?? 0, 3, widget.audioPlayer);
  }
}

class SortButtonIcon extends StatelessWidget {
  final int state;

  const SortButtonIcon({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late IconData icon;
    switch (state) {
      case 0:
        icon = Icons.music_note_rounded;
        break;
      case 1:
        icon = Icons.album_rounded;
        break;
      case 2:
        icon = Icons.person;
        break;
      case 3:
        icon = Icons.shuffle_rounded;
        break;
      case 4:
        icon = Icons.calendar_today_rounded;
        break;
    }
    return Icon(icon);
  }
}