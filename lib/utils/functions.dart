import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/common_text.dart';
import 'package:shadow_garden/style/style.dart';

abstract class Functions {
  static Future<void> init(AudioProvider audioProvider) async {
    await audioProvider.audioPlayer.setLoopMode(LoopMode.values[audioProvider.cLoopMode.index <= 2 ? audioProvider.cLoopMode.index : LoopMode.all.index]);
    await audioProvider.fetchAudioSongs();
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

  static void onLongPress(AudioProvider audioProvider, AudioPlayer audioPlayer, BuildContext context, int index) {
    audioProvider.playlist.move(index, (audioPlayer.currentIndex ?? 0) + 1);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(Texts.textNextSongSnack, style: Styles.labelLarge), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
    );
  }

  static SongModel? getSongModel(AudioPlayer audioPlayer, List<SongModel> songs, int? index) {
    final List<IndexedAudioSource>? sequence = audioPlayer.sequence;

    if (sequence == null || index == null) { return null; }

    final int currentAudioId = int.parse(sequence[index].tag.id);
    final SongModel currentSong = songs.firstWhere((song) => song.id == currentAudioId);
    return currentSong;
  }

  static int? getSongIndex(List<SongModel> songs, int? songId) {
    if (songId == null) return null;
    int index = songs.indexWhere((song) => song.id == songId);
    return index == -1 ? null : index;
  }
}