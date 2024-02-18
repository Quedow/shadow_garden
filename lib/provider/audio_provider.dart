import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider extends ChangeNotifier {
  bool isLoading = false;

  ConcatenatingAudioSource _playlists = ConcatenatingAudioSource(children: []);
  ConcatenatingAudioSource get playlists => _playlists;

  Future<bool> fetchAudioSongs() async {
    isLoading = true;
    notifyListeners();

    final OnAudioQuery audioQuery = OnAudioQuery();

    // Request permissions
    bool hasPermission = await audioQuery.permissionsStatus();
    if (!hasPermission) {
      await audioQuery.permissionsRequest();
    }

    try {
      List<SongModel> songs = await audioQuery.querySongs();

      _playlists = ConcatenatingAudioSource(
        children: songs.map((song) => AudioSource.uri(
            Uri.file(song.data),
            tag: MediaItem(
              id: song.id.toString(),
              title: song.title,
              album: song.album,
              artist: song.artist
            ),
          ),
        ).toList()
      );
      return songs.isNotEmpty;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}