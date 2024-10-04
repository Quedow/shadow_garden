import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/screens/settings_screen.dart';
import 'package:shadow_garden/screens/songs_screen.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/screens/statistics_screen.dart';
import 'package:shadow_garden/style/common_text.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/utils/functions.dart';
import 'package:shadow_garden/widgets/sort_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AudioPlayer _audioPlayer;
  late AudioProvider _audioProvider;
  int currentScreenIndex = 0;
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
      appBar: [
        homeAppBar(),
        customAppBar(Texts.textStatisticsBar),
        customAppBar(Texts.textSettingsBar),
      ][currentScreenIndex],
      body: [
        SongsScreen(audioProvider: _audioProvider, isPlaying: isPlaying),
        StatisticsScreen(audioProvider: _audioProvider),
        SettingsScreen(audioProvider: _audioProvider),
      ].elementAt(currentScreenIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentScreenIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (index) {
          if (currentScreenIndex == index) { return; }
          setState(() {
            currentScreenIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(label: Texts.textHomeBar, icon: const Icon(Icons.music_note_rounded)),
          BottomNavigationBarItem(label: Texts.textStatisticsBar, icon: const Icon(Icons.bar_chart_rounded)),
          BottomNavigationBarItem(label: Texts.textSettingsBar, icon: const Icon(Icons.settings)),
        ],
      ),
    );
  }

  AppBar homeAppBar() {
    return AppBar(
      title: Text(Texts.textHomeBar),
      bottom: PreferredSize(preferredSize: Size.zero, child: Container(color: Theme.of(context).colorScheme.secondary, height: 1.0)),
      actions: [
        IconButton(onPressed: _audioProvider.setShuffleActive, icon: Icon(Icons.shuffle_rounded, color: _audioProvider.shuffleActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary)),
        IconButton(onPressed: _audioProvider.setSortState, icon: SortButtonIcon(state: _audioProvider.sortState), color: _audioProvider.shuffleActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary),
      ],
    );
  }

  AppBar customAppBar(String title) {
    return AppBar(
      title: Text(title),
      bottom: PreferredSize(preferredSize: Size.zero, child: Container(color: Theme.of(context).colorScheme.secondary, height: 1.0)),
    );
  }
}