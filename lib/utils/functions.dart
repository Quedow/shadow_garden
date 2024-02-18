import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/style.dart';

enum SortMode { alpha, shuffle }

abstract class Functions {
  static Future<void> init(AudioPlayer audioPlayer, AudioProvider audioProvider) async {
    await audioPlayer.setLoopMode(LoopMode.all);
    bool audioSongsFound = await audioProvider.fetchAudioSongs();
    if (audioSongsFound) {
      await audioPlayer.setAudioSource(audioProvider.playlists, initialIndex: 0);
    }
  }

  static void onTap(AudioPlayer audioPlayer, bool isPlaying, bool isCurrentItem, int index) {
    if (isCurrentItem) {
      if (isPlaying) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      }
    } else {
      audioPlayer.seek(Duration.zero, index: index);
      audioPlayer.play();
    }
  }

  static void onTrackLongPress(AudioProvider audioProvider, AudioPlayer audioPlayer, BuildContext context, int index) {
    audioProvider.playlists.move(index, (audioPlayer.currentIndex ?? 0) + 1);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add to next song'), backgroundColor: ThemeColors.secondaryColor, behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2))
    );
  }

  static void onSortBtnTap(AudioPlayer audioPlayer) {
    audioPlayer.setShuffleModeEnabled(true);
  }
}