import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';

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

class LoopButton extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const LoopButton({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoopMode loopMode = audioPlayer.loopMode;

    if (loopMode == LoopMode.off) {
      return IconButton(
        onPressed: () => audioPlayer.setLoopMode(LoopMode.all),
        iconSize: IconSizes.iconBtnSize,
        color: ThemeColors.primaryColor,
        icon: Icon(Icons.repeat_rounded, color: ThemeColors.primaryColor.withOpacity(0.5)),
      );
    } else if (loopMode == LoopMode.all) {
        return IconButton(
          onPressed: () => audioPlayer.setLoopMode(LoopMode.one),
          iconSize: IconSizes.iconBtnSize,
          color: ThemeColors.primaryColor,
          icon: const Icon(Icons.repeat_rounded, color: ThemeColors.primaryColor),
        );
    }
    return IconButton(
      onPressed: () => audioPlayer.setLoopMode(LoopMode.off),
      iconSize: IconSizes.iconBtnSize,
      color: ThemeColors.primaryColor,
      icon: const Icon(Icons.repeat_one_rounded, color: ThemeColors.primaryColor),
    );
  }
}

class SortButton extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final AudioProvider audioProvider;

  const SortButton({super.key, required this.audioPlayer, required this.audioProvider});

  @override
  SortButtonState createState() => SortButtonState();
}

class SortButtonState extends State<SortButton> {
  int _state = 0;

  void _handleTap() {
    setState(() {
      _state = (_state + 1) % 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    AudioPlayer audioPlayer = widget.audioPlayer;
    // AudioProvider audioProvider = widget.audioProvider;

    late IconData icon;
    switch (_state) {
      case 0:
        icon = Icons.sort_by_alpha_rounded;
        audioPlayer.setShuffleModeEnabled(false);
        break;
      case 1:
        icon = Icons.shuffle_rounded;
        audioPlayer.setShuffleModeEnabled(true);
        break;
    }
    return IconButton(
      icon: Icon(icon),
      onPressed: _handleTap,
    );
  }
}
