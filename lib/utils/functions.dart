import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/style/common_text.dart';

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
    int currentIndex = audioPlayer.currentIndex ?? 0;
    int newIndex = index > currentIndex ? currentIndex + 1 : currentIndex;
      
    audioProvider.playlist.move(index, newIndex);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(Texts.textNextSongSnack, style: Theme.of(context).textTheme.labelLarge), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
    );
  }

  static SongModel? getSongModel(AudioPlayer audioPlayer, List<SongModel> songs, int? index) {
    final List<IndexedAudioSource>? sequence = audioPlayer.sequence;

    if (sequence == null || index == null) { return null; }

    final int currentAudioId = int.parse(sequence[index].tag.id);
    final SongModel currentSong = songs.firstWhere((song) => song.id == currentAudioId);
    return currentSong;
  }

  static int fastHash(String? album, String title, String? artist) {
    String string = '${album ?? ''}$title${artist ?? ''}';
    int hash = 0xcbf29ce484222325;

    int i = 0;
    while (i < string.length) {
      final int codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }

    return hash;
  }
}