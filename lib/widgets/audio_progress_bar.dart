import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/utils/position_data.dart';
import 'package:shadow_garden/style/style.dart';

class AudioProgressBar extends StatelessWidget {
  final Stream<PositionData> _positionDataStream;
  final AudioPlayer _audioPlayer;

  const AudioProgressBar({super.key, required Stream<PositionData> positionDataStream, required AudioPlayer audioPlayer}) : _positionDataStream = positionDataStream, _audioPlayer = audioPlayer;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PositionData>(
      stream: _positionDataStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) { return const CircularProgressIndicator(); }
        
        final positionData = snapshot.data;
        return ProgressBar(
          barHeight: 5.0,
          thumbRadius: 7.0,
          baseBarColor: Theme.of(context).colorScheme.inverseSurface,
          bufferedBarColor: Theme.of(context).colorScheme.inverseSurface,
          timeLabelLocation: TimeLabelLocation.sides,
          timeLabelType: TimeLabelType.totalTime,
          timeLabelTextStyle: Styles.labelLarge.copyWith(fontWeight: FontWeight.w500),
          progress: positionData?.position ?? Duration.zero,
          buffered: positionData?.bufferedPosition ?? Duration.zero,
          total: positionData?.duration ?? Duration.zero,
          onSeek: _audioPlayer.seek,
        );
      },
    );
  }
}
