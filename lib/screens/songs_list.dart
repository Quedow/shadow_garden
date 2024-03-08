import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shadow_garden/widgets/text_display.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/utils/functions.dart';
import 'package:shadow_garden/widgets/playing_animation.dart';

class SongsList extends StatefulWidget {
  final AudioProvider audioProvider;
  final bool isPlaying;

  const SongsList({Key? key, required this.audioProvider, required this.isPlaying}) : super(key: key);

  @override
  SongsListState createState() => SongsListState();
}

class SongsListState extends State<SongsList> {
  AudioPlayer get _audioPlayer => widget.audioProvider.audioPlayer;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<SequenceState?>(
        stream: _audioPlayer.sequenceStateStream,
        builder: (context, snapshot) {
          final SequenceState? state = snapshot.data;
          
          if (state?.sequence.isEmpty ?? true) {
            return const Center(child: Text('No music found...', style: TextStyle(color: ThemeColors.primaryColor)));
          } else {
            final int playlistLength = state!.sequence.length;
            
            return ListView.builder(
              itemCount: playlistLength,
              itemBuilder: (context, index) {
                final MediaItem metadata = state.sequence[index].tag;
                final bool isCurrentSong = _audioPlayer.currentIndex == index;
            
                return ListTile(
                  onTap: () => Functions.onTap(_audioPlayer, widget.isPlaying, isCurrentSong, index),
                  onLongPress: () => Functions.onLongPress(widget.audioProvider, _audioPlayer, context, index),
                  // leading: Text('${index}', style: Styles.audioLeadingTextStyle),
                  leading: QueryArtworkWidget(id: int.parse(metadata.id), type: ArtworkType.AUDIO, artworkFit: BoxFit.cover, artworkBorder: BorderRadius.circular(5.0)),
                  title: TitleText(title: "${index + 1} - ${metadata.title}", textStyle: Styles.trackHomeTitle(isCurrentSong)),
                  subtitle: SubtitleText(album: metadata.album, artist: metadata.artist, textStyle: Styles.trackPageSubtitle),
                  trailing: PlayingAnimation(isCurrentSong: isCurrentSong, isPlaying: widget.isPlaying),
                  iconColor: ThemeColors.primaryColor,
                );
              }
            );
          }
        }
      ),
    );
  }
}