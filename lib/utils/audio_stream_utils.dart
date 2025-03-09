import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/models/position_data.dart';
import 'package:rxdart/rxdart.dart';

abstract class AudioStreamUtils {
  static Stream<PositionData> getPositionDataStream(AudioPlayer audioPlayer) {
    return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      audioPlayer.positionStream,
      audioPlayer.bufferedPositionStream,
      audioPlayer.durationStream,
      (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero),
    );
  }
}
