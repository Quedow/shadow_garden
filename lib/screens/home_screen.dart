import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadow_garden/widgets/controls.dart';
import 'package:shadow_garden/widgets/text_display.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/utils/functions.dart';
import 'package:shadow_garden/screens/track_screen.dart';
import 'package:shadow_garden/widgets/playing_animation.dart';
// import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AudioPlayer _audioPlayer;
  late AudioProvider _audioProvider;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
    Functions.init(_audioPlayer, _audioProvider);

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.backgroundOled, 
        leading: IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => {}),
        title: const Text('Shadow Garden'), foregroundColor: ThemeColors.primaryColor, bottom: PreferredSize(preferredSize: Size.zero, child: Container(color: ThemeColors.primaryColor, height: 1.0)),
        centerTitle: true,
        // actions: [IconButton(icon: const Icon(Icons.sort_rounded), onPressed: () => { _audioPlayer.setShuffleModeEnabled(true) })],
        actions: [SortButton(audioPlayer: _audioPlayer, audioProvider: _audioProvider)],
      ),
      backgroundColor: ThemeColors.backgroundOled,
      body: Column(
        children: [
          Expanded(
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
                      final bool isCurrentItem = _audioPlayer.currentIndex == index;

                      return ListTile(
                        onTap: () => Functions.onTap(_audioPlayer, isPlaying, isCurrentItem, index),
                        onLongPress: () => Functions.onTrackLongPress(_audioProvider, _audioPlayer, context, index),
                        leading: Text('${index + 1}', style: Styles.audioLeadingTextStyle),
                        // leading: QueryArtworkWidget(id: int.parse(metadata.id), type: ArtworkType.AUDIO, artworkFit: BoxFit.cover, artworkBorder: BorderRadius.circular(5.0)),
                        title: TitleText(title: metadata.title, textStyle: Styles.trackHomeTitle(isCurrentItem)),
                        subtitle: SubtitleText(album: metadata.album, artist: metadata.artist, textStyle: Styles.trackPageSubtitle),
                        trailing: PlayingAnimation(isCurrentItem: isCurrentItem, isPlaying: isPlaying),
                        iconColor: ThemeColors.primaryColor,
                      );
                    }
                  );
                }
              }
            )
          ),
          TrackBanner(audioPlayer: _audioPlayer, sequenceState: _audioPlayer.sequenceState, isPlaying: isPlaying),
        ]
      )
    );
  }
}