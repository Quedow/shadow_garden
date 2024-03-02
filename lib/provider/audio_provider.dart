import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider extends ChangeNotifier {
  bool isLoading = false;

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  ConcatenatingAudioSource get playlist => _playlist;

  List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

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
      _songs = await audioQuery.querySongs(
        orderType: OrderType.ASC_OR_SMALLER,
        sortType: SongSortType.TITLE,
        ignoreCase: true,
        path: "/storage/emulated/0/Music"
      );

      if(_songs.isEmpty) { return false; }

      setPlaylist();

      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setPlaylist() {
    _playlist = ConcatenatingAudioSource(
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
  }

void setCustomLoop(int currentIndex, int number, AudioPlayer audioPlayer) {
  int endIndex = currentIndex + number;
  endIndex = endIndex > songs.length ? songs.length : endIndex;
  List<SongModel> slicedSongs = songs.sublist(currentIndex, endIndex);

  _playlist = ConcatenatingAudioSource(
    children: slicedSongs.map((song) => AudioSource.uri(
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
  audioPlayer.setAudioSource(_playlist);
}

  void sortSongs(bool playlistIsSongs, int state, [AudioPlayer? audioPlayer]) {
    switch(state) {
      case 0:
        songs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 1:
        songs.sort((a, b) => (a.album ?? '').compareTo(b.album ?? ''));
        break;
      case 2:
        songs.sort((a, b) => (a.artist ?? '').compareTo(b.artist ?? ''));
        break;
      case 3:
        songs.shuffle();
        break;
      case 4:
        songs.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
        break;
    }
    if (playlistIsSongs && audioPlayer != null) {
      setPlaylist();
      audioPlayer.setAudioSource(_playlist);
    }
  }
}