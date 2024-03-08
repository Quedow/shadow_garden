import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:numberpicker/numberpicker.dart';

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const Controls({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const LoopButton()
      ],
    );
  }
}

class PlayButton extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const PlayButton({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: audioPlayer.playingStream,
      builder: (context, snapshot) {
        final bool playing = snapshot.data ?? false;

        if (!playing) {
          return IconButton(
            onPressed: audioPlayer.play,
            iconSize: IconSizes.iconBtnSize,
            color: ThemeColors.primaryColor,
            icon: const Icon(Icons.play_arrow_rounded),
          );
        }
        return IconButton(
          onPressed: audioPlayer.pause,
          iconSize: IconSizes.iconBtnSize,
          color: ThemeColors.primaryColor,
          icon: const Icon(Icons.pause_rounded),
        );
      },
    );
  }
}

enum CLoopMode { off, one, all, custom }

class LoopButton extends StatefulWidget {

  const LoopButton({Key? key}) : super(key: key);

  @override
  State<LoopButton> createState() => _LoopButtonState();
}

class _LoopButtonState extends State<LoopButton> {

  @override
  Widget build(BuildContext context) {
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    final CLoopMode loopMode = audioProvider.cLoopMode;

    if (loopMode == CLoopMode.off) {
      return IconButton(
        onPressed: () => audioProvider.setLoopMode(LoopMode.all, CLoopMode.custom),
        iconSize: IconSizes.iconBtnSize,
        color: ThemeColors.primaryColor,
        icon: Icon(Icons.repeat_rounded, color: ThemeColors.primaryColor.withOpacity(0.5)),
      );
    } else if (loopMode == CLoopMode.all) {
        return IconButton(
          onPressed: () => audioProvider.setLoopMode(LoopMode.one, CLoopMode.one),
          iconSize: IconSizes.iconBtnSize,
          color: ThemeColors.primaryColor,
          icon: const Icon(Icons.repeat_rounded, color: ThemeColors.primaryColor),
        );
    } else if (loopMode == CLoopMode.one) {
      return IconButton(
        onPressed: () => audioProvider.setLoopMode(LoopMode.off, CLoopMode.off),
        iconSize: IconSizes.iconBtnSize,
        color: ThemeColors.primaryColor,
        icon: const Icon(Icons.repeat_one_rounded, color: ThemeColors.primaryColor),
      );
    }
    return Row(
      children: [
        IconButton(
          onPressed: () => audioProvider.setLoopMode(LoopMode.all, CLoopMode.all),
          iconSize: IconSizes.iconBtnSize,
          color: ThemeColors.primaryColor,
          icon: const Icon(Icons.repeat_rounded, color: ThemeColors.primaryColor),
        ),
        NumberPicker(
          value: audioProvider.songsPerLoop,
          minValue: 1,
          maxValue: 10,
          itemWidth: 40,
          selectedTextStyle: Styles.numberPickerSelect,
          textStyle: Styles.numberPicker,
          axis: Axis.horizontal,
          onChanged: (value) { 
            setState(() => audioProvider.songsPerLoop = value );
            audioProvider.setLoopMode(LoopMode.all, CLoopMode.custom);
          }
        )
      ]
    );
  }
}