import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/model/song.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/widgets/controls.dart';
import 'package:shadow_garden/utils/functions.dart';

class AudioProvider extends ChangeNotifier {
  final SettingsService _settings = SettingsService();
  final DatabaseService _db = DatabaseService();

  List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  ConcatenatingAudioSource get playlist => _playlist;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  bool _shuffleActive = false;
  bool get shuffleActive => _shuffleActive;
  void switchShuffle() async {
    _shuffleActive = !_shuffleActive;
    _shuffleActive ? await sortSongs(-1) : await sortSongs(_sortState);
    notifyListeners();
  }

  late int _songsPerLoop;
  int get songsPerLoop => _songsPerLoop;
  void setSongsPerLoop(int number) async {
    _songsPerLoop = number;
    await _settings.setSongsPerLoop(number);
    notifyListeners();
  }

  late CLoopMode _cLoopMode;
  CLoopMode get cLoopMode => _cLoopMode;
  void setCLoopMode(CLoopMode cMode) async {
    _cLoopMode = cMode;
    _settings.setCLoopMode(cMode);
    notifyListeners();
  }

  final int _totalState = 5;
  late int _sortState;
  int get sortState => _sortState;
  void setSortState() async {
    _sortState = (_sortState + 1) % _totalState;
    await _settings.setSortState(_sortState);
    await sortSongs(_sortState);
    notifyListeners();
  }

  late bool _neverListenedFirst;
  bool get neverListenedFirst => _neverListenedFirst;
  void setNeverListenedFirst(bool value) async {
    _neverListenedFirst = value;
    await _settings.setNeverListenedFirst(value);
  }

  // late int _lastSongId;
  // int get lastSongId => _lastSongId;
  // void setLastSongId(int id) async {
  //   _lastSongId = id;
  //   await _settings.setLastSongId(id);
  // }

  List<int> _lastIndexes = [];
  Duration _lastPosition = Duration.zero;

  AudioProvider() {
    _cLoopMode = _settings.getCLoopMode();
    _songsPerLoop = _settings.getSongsPerLoop();
    _sortState = _settings.getSortState();
    _neverListenedFirst = _settings.getNeverListenedFirst();
    // _lastSongId = _settings.getLastSongId();

    _audioPlayer.currentIndexStream.listen((index) async {
      if (index == null) { return; }

      if (_cLoopMode == CLoopMode.custom) {
        if (_lastIndexes.isEmpty || audioPlayer.previousIndex != _lastIndexes.last) {
          _lastIndexes.clear();
        }
        _lastIndexes.add(index);

        if (_lastIndexes.length > _songsPerLoop) {
          await resetLoop(_lastIndexes.first);
          _lastIndexes = [_lastIndexes.first];
        }
      }
    });

    _audioPlayer.positionStream.listen((position) {
      _lastPosition = position;
    });

    _audioPlayer.positionDiscontinuityStream.listen((discontinuity) {
      if (_audioPlayer.position.inSeconds == 0 && audioPlayer.playerState.playing) {
        SongModel? currentSong = Functions.getSongModel(_audioPlayer, _songs, discontinuity.previousEvent.currentIndex);

        if (currentSong != null) {
          int duration =  discontinuity.previousEvent.duration != null
            ? discontinuity.previousEvent.duration!.inSeconds
            : _lastPosition.inSeconds;

          _db.updateSong(Song(currentSong.id, currentSong.title, duration, getMonths(currentSong.dateAdded), 1, _lastPosition.inSeconds));
        }
      }
    });
  }

  int getMonths(int? dateAdded) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch((dateAdded ?? 0) * 1000, isUtc: true);
    return DateTime.now().difference(date).inDays ~/ 30;
  }

  void clearDatabase() async {
    await _db.clearDatabase();
  }

  Future<bool> fetchAudioSongs() async {
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
      await sortSongs(_sortState);

      return true;
    } catch (e) {
      return false;
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

  void setLoopMode(LoopMode mode, CLoopMode cMode) async {
    await _audioPlayer.setLoopMode(mode);
    setCLoopMode(cMode);

    if (_cLoopMode == CLoopMode.custom) {
      _lastIndexes.clear();
      _lastIndexes.add(_audioPlayer.currentIndex ?? 0);
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
        _songs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 1:
        _songs.sort((a, b) => (a.album ?? '').compareTo(b.album ?? ''));
        break;
      case 2:
        _songs.sort((a, b) => (a.artist ?? '').compareTo(b.artist ?? ''));
        break;
      case 3:
        _songs.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
        break;
      case 4:
        await smartSort();
        break;
      case -1:
        _songs.shuffle();
        break;
    }
    setPlaylist();
    await _audioPlayer.setAudioSource(_playlist);
  }

  Future<void> smartSort() async {
    final List<int> ranking = await _db.getRanking();
    final int size = ranking.length;
    final Map<int, int> mapRanking = {for (int i = 0; i < size; i++) ranking[i]: i};
    int sortPosition = neverListenedFirst ? -1 : size; // Musiques hors bases sont à la fin ou au début
    _songs.sort((a, b) => (mapRanking[a.id] ?? sortPosition).compareTo(mapRanking[b.id] ?? sortPosition));
  }
}