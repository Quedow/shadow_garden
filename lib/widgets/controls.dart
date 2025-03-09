import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:shadow_garden/utils/styles.dart';
import 'package:numberpicker/numberpicker.dart';

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const Controls({super.key, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: audioPlayer.seekToPrevious,
          iconSize: DesignSystem.iconBtnSize,
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        PlayButton(audioPlayer: audioPlayer),
        IconButton(
          onPressed: audioPlayer.seekToNext,
          iconSize: DesignSystem.iconBtnSize,
          icon: const Icon(Icons.skip_next_rounded),
        ),
        const LoopButton(),
      ],
    );
  }
}

class PlayButton extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const PlayButton({super.key, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: audioPlayer.playingStream,
      builder: (context, snapshot) {
        final bool isPlaying = snapshot.data ?? false;
        final IconData iconData = isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;

        return Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: DesignSystem.iconBtnSize,
            icon: Icon(iconData),
            onPressed: isPlaying ? audioPlayer.pause : audioPlayer.play,
          ),
        );
      },
    );
  }
}


enum CLoopMode { off, one, all, custom }

class LoopButton extends StatefulWidget {

  const LoopButton({super.key});

  @override
  State<LoopButton> createState() => _LoopButtonState();
}

class _LoopButtonState extends State<LoopButton> {

  @override
  Widget build(BuildContext context) {
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    final CLoopMode cLoopMode = audioProvider.cLoopMode;

    if (cLoopMode == CLoopMode.all) {
      return IconButton(
        onPressed: () => audioProvider.setLoopMode(LoopMode.off, CLoopMode.off),
        iconSize: DesignSystem.iconBtnSize,
        icon: const Icon(Icons.repeat_rounded),
      );
    } else if (cLoopMode == CLoopMode.off) {
      return IconButton(
        onPressed: () => audioProvider.setLoopMode(LoopMode.one, CLoopMode.one),
        iconSize: DesignSystem.iconBtnSize,
        icon: Icon(Icons.repeat_rounded, color: Theme.of(context).unselectedWidgetColor),
      );
    } else if (cLoopMode == CLoopMode.one) {
      return IconButton(
        onPressed: () => audioProvider.setLoopMode(LoopMode.all, CLoopMode.custom),
        iconSize: DesignSystem.iconBtnSize,
        icon: const Icon(Icons.repeat_one_rounded),
      );
    }
    return Row(
      children: [
        IconButton(
          onPressed: () => audioProvider.setLoopMode(LoopMode.all, CLoopMode.all),
          iconSize: DesignSystem.iconBtnSize,
          icon: const Icon(Icons.repeat_rounded),
        ),
        NumberPicker(
          value: audioProvider.songsPerLoop,
          minValue: 2,
          maxValue: 20,
          itemWidth: 40,
          selectedTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.tertiary),
          textStyle: TextStyle(color: Theme.of(context).hintColor),
          axis: Axis.horizontal,
          onChanged: (value) => audioProvider.setSongsPerLoop(value),
        ),
      ],
    );
  }
}

class SortButtonIcon extends StatelessWidget {
  final int state;

  const SortButtonIcon({super.key, required this.state});

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
        icon = Icons.calendar_today_rounded;
        break;
      case 4:
        icon = Icons.smart_toy_rounded;
        break;
    }
    return Icon(icon);
  }
}