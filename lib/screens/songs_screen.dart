import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shadow_garden/widgets/sort_button.dart';
import 'package:shadow_garden/widgets/text_display.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/utils/functions.dart';
import 'package:shadow_garden/screens/song_banner.dart';
import 'package:shadow_garden/widgets/playing_animation.dart';
import 'package:provider/provider.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({Key? key}) : super(key: key);

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  late AudioPlayer _audioPlayer;
  late AudioProvider _audioProvider;
  bool isPlaying = true;
  int currentIndex = 0;

  int _state = 0;
  final int _totalState = 5;

  @override
  void initState() {
    super.initState();
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
    Functions.init(_audioProvider);
    _audioPlayer = _audioProvider.audioPlayer;

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

  void sortSongs() {
    setState(() {
      _state = (_state + 1) % _totalState;
    });
    _audioProvider.sortSongs(_state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.backgroundOled, 
        leading: IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => {}),
        title: const Text('Shadow Garden'), foregroundColor: ThemeColors.primaryColor, bottom: PreferredSize(preferredSize: Size.zero, child: Container(color: ThemeColors.primaryColor, height: 1.0)),
        centerTitle: true,
        actions: [IconButton(icon: SortButtonIcon(state: _state), onPressed: sortSongs)],
      ),
      backgroundColor: ThemeColors.backgroundOled,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<int?>(
              stream: _audioPlayer.currentIndexStream,
              builder: (context, snapshot) {           
                if (_audioProvider.songs.isEmpty) {
                  return const Center(child: Text('No music found...', style: TextStyle(color: ThemeColors.primaryColor)));
                } else {
                  return ListView.builder(
                    itemCount: _audioProvider.songs.length,
                    itemBuilder: (context, index) {
                      final SongModel metadata = _audioProvider.songs[index];
                      final int currentAudioId = int.parse(_audioPlayer.sequence?[snapshot.data ?? 0].tag.id);
                      final SongModel currentSong = _audioProvider.songs.firstWhere((song) => song.id == currentAudioId);
                      final bool isCurrentSong = currentSong == metadata;

                      return ListTile(
                        onTap: () => Functions.onTap(_audioPlayer, isPlaying, isCurrentSong, index),
                        onLongPress: () => Functions.onLongPress(_audioProvider, _audioPlayer, context, index),
                        leading: Text('${index + 1}', style: Styles.audioLeadingTextStyle),
                        title: TitleText(title: metadata.title, textStyle: Styles.trackHomeTitle(isCurrentSong)),
                        subtitle: SubtitleText(album: metadata.album, artist: metadata.artist, textStyle: Styles.trackPageSubtitle),
                        trailing: PlayingAnimation(isCurrentSong: isCurrentSong, isPlaying: isPlaying),
                        iconColor: ThemeColors.primaryColor,
                      );
                    }
                  );
                }
              }
            )
          ),
          SongBanner(audioPlayer: _audioPlayer, isPlaying: isPlaying),
        ]
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: 0, // currentPageIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: ThemeColors.backgroundOled,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          selectedFontSize: 14,
          unselectedFontSize: 14,
          onTap: (index) { // Respond to item press.
            setState(() {
              // currentPageIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(label: 'Songs', icon: Icon(Icons.music_note_rounded)),
            BottomNavigationBarItem(label: 'Albums', icon: Icon(Icons.album)),
            BottomNavigationBarItem(label: 'Playlists', icon: Icon(Icons.playlist_play_rounded))
          ],
        ),
      ),
    );
  }
}