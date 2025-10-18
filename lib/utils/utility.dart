import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:shadow_garden/utils/translator.dart';
import 'package:shadow_garden/widgets/overlays.dart';

class Utility {
  static Future<void> init(AudioProvider audioProvider) async {
    await audioProvider.audioPlayer.setLoopMode(LoopMode.values[audioProvider.cLoopMode.index <= 2 ? audioProvider.cLoopMode.index : LoopMode.all.index]);
    await audioProvider.fetchAudioSongs();
  }
  
  static void onTap(AudioProvider audioProvider, AudioPlayer audioPlayer, bool isCurrentSong, int index) {
    final bool isPlaying = audioPlayer.playerState.playing;
    
    if (isCurrentSong) {
      if (isPlaying) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      }
    } else {
      audioPlayer.seek(Duration.zero, index: index);
      audioPlayer.play();
      audioProvider.resetLoop();
    }
  }

  static void onLongPress(AudioPlayer audioPlayer, BuildContext context, int index) {
    int currentIndex = audioPlayer.currentIndex ?? 0;
    int targetIndex = index > currentIndex ? currentIndex + 1 : currentIndex;

    if (index == currentIndex || index == currentIndex + 1) return;
      
    audioPlayer.moveAudioSource(index, targetIndex);
    
    ScaffoldMessenger.of(context).showSnackBar(
      Snack.floating(context, 'textNextSongSnack'.t(), 1000),
    );
  }

  static SongModel? getSongModel(AudioPlayer audioPlayer, List<SongModel> songs, int? index) {
    final List<IndexedAudioSource> sequence = audioPlayer.sequence;

    if (index == null) { return null; }

    final int currentAudioId = int.parse(sequence[index].tag.id);
    final SongModel currentSong = songs.firstWhere((song) => song.id == currentAudioId);
    return currentSong;
  }

  static int? getSongIndex(AudioPlayer audioPlayer, List<SongModel> songs, int? index) {
    final List<IndexedAudioSource> sequence = audioPlayer.sequence;

    if (index == null) { return null; }

    final int currentAudioId = int.parse(sequence[index].tag.id);
    return songs.indexWhere((song) => song.id == currentAudioId);
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

  static double getTextHeight(String text, TextStyle? style, double maxWidth, {double verticalOffset = 0}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter.size.height + verticalOffset;
  }

  static String getBackupDate() {
    return DateFormat('backupDateFormat'.t()).format(DateTime.now());
  }
}