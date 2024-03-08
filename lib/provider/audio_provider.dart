import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/widgets/controls.dart';

class AudioProvider extends ChangeNotifier {
  bool isLoading = false;

  List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  ConcatenatingAudioSource get playlist => _playlist;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  int _songsPerLoop = 3;
  int get songsPerLoop => _songsPerLoop;
  set songsPerLoop(int number) {
    _songsPerLoop = number;
    notifyListeners();
  }

  CLoopMode _cLoopMode = CLoopMode.all;
  CLoopMode get cLoopMode => _cLoopMode;
  set cLoopMode(CLoopMode mode) {
    _cLoopMode = mode;
    notifyListeners();
  }

  int _indexCounter = 0;
  int _lastIndex = 0;

  AudioProvider() {
    audioPlayer.currentIndexStream.listen((index) async {
      if (cLoopMode == CLoopMode.custom  && index != null) {
        _indexCounter = (index == _lastIndex + 1) ? _indexCounter + 1 : 0;
        _lastIndex = index;
        if (_indexCounter == songsPerLoop) {
          resetLoop(index - songsPerLoop);
          _indexCounter = 0;
        }
      }
    });
  }

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

  void setLoopMode(LoopMode mode, CLoopMode cMode) {
    _audioPlayer.setLoopMode(mode);
    cLoopMode = cMode;

    if (cLoopMode == CLoopMode.custom) {
      _indexCounter = 0;
    }
  }

  Future<void> resetLoop(int index) async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero, index: index);
    await _audioPlayer.play();
  }

  Future<void> sortSongs(int state) async {
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

    setPlaylist();
    audioPlayer.setAudioSource(_playlist);
  }
}