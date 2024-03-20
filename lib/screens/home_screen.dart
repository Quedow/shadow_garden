import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/screens/songs_list.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/utils/functions.dart';
import 'package:shadow_garden/screens/song_banner.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/widgets/sort_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.backgroundOled, 
        leading: IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => {}),
        title: const Text('Shadow Garden'), foregroundColor: ThemeColors.primaryColor, bottom: PreferredSize(preferredSize: Size.zero, child: Container(color: ThemeColors.primaryColor, height: 1.0)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _audioProvider.clearDatabase, icon: const Icon(Icons.delete_rounded)),
          IconButton(onPressed: _audioProvider.saveInDatabase, icon: const Icon(Icons.save_alt_rounded)),
          IconButton(icon: SortButtonIcon(state: _audioProvider.sortState), onPressed: _audioProvider.setSortState)
        ],
      ),
      backgroundColor: ThemeColors.backgroundOled,
      body: Column(
        children: [
          SongsList(audioProvider: _audioProvider, isPlaying: isPlaying),
          SongBanner(audioPlayer: _audioPlayer, isPlaying: isPlaying),
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}