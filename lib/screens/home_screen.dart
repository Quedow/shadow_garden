import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/widgets/interactive_banner.dart';
import 'package:shadow_garden/screens/songs_screen.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:shadow_garden/screens/statistics_screen.dart';
import 'package:shadow_garden/utils/translator.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/utils/utility.dart';
import 'package:shadow_garden/widgets/custom_app_bar.dart';

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
    Utility.init(_audioProvider);
    _audioPlayer = _audioProvider.audioPlayer;
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
        CustomAppBar(appBarType: AppBarType.home, audioProvider: _audioProvider, title: 'textHomeBar'.t()),
        CustomAppBar(appBarType: AppBarType.setting, audioProvider: _audioProvider, title: 'textStatisticsBar'.t()),
      ][currentScreenIndex],
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: currentScreenIndex,
              children: [
                SongsScreen(audioProvider: _audioProvider),
                StatisticsScreen(audioProvider: _audioProvider),
              ],
            ),
          ),
          InteractiveBanner(audioPlayer: _audioPlayer),
        ],
      ),
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
          BottomNavigationBarItem(label: 'textHomeBar'.t(), icon: const Icon(Icons.music_note_rounded)),
          BottomNavigationBarItem(label: 'textStatisticsBar'.t(), icon: const Icon(Icons.bar_chart_rounded)),
        ],
      ),
    );
  }
}