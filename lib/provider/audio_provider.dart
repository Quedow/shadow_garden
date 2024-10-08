import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/widgets/controls.dart';
import 'package:shadow_garden/utils/functions.dart';

class AudioProvider extends ChangeNotifier {
  final SettingsService _settings = SettingsService();
  final DatabaseService _db = DatabaseService();

  final List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  ConcatenatingAudioSource get playlist => _playlist;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  bool _shuffleActive = false;
  bool get shuffleActive => _shuffleActive;
  void setShuffleActive() async {
    if (!_shuffleActive) {
      _shuffleActive = true;
    }
    await _sortSongs(-1);
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
    await _settings.setCLoopMode(cMode);
    notifyListeners();
  }

  final int _totalState = 5;
  late int _sortState;
  int get sortState => _sortState;
  void setSortState() async {
    if (_shuffleActive) {
      _shuffleActive = false;
    } else {
      _sortState = (_sortState + 1) % _totalState;
    }
    await _settings.setSortState(_sortState);
    await _sortSongs(_sortState);
    notifyListeners();
  }

  late bool _neverListenedFirst;
  bool get neverListenedFirst => _neverListenedFirst;
  void setNeverListenedFirst(bool value) async {
    _neverListenedFirst = value;
    await _settings.setNeverListenedFirst(value);
  }

  List<int> _lastIndexes = [];
  Duration _lastPosition = Duration.zero;

  AudioProvider() {
    getSettings();

    _audioPlayer.currentIndexStream.listen((index) async {
      if (index == null) { return; }

      if (_cLoopMode == CLoopMode.custom) {
        if (_lastIndexes.isEmpty || audioPlayer.previousIndex != _lastIndexes.last) {
          _lastIndexes.clear();
        }
        _lastIndexes.add(index);

        if (_lastIndexes.length > _songsPerLoop) {
          await _resetLoop(_lastIndexes.first);
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

          final int key = Functions.fastHash(currentSong.album, currentSong.title, currentSong.artist);

          _db.updateSong(Song(key, currentSong.title, duration, _getDays(currentSong.dateAdded), _lastPosition.inSeconds, DateTime.now()));
        }
      }
    });
  }

  void getSettings() {
    _cLoopMode = _settings.getCLoopMode();
    _songsPerLoop = _settings.getSongsPerLoop();
    _sortState = _settings.getSortState();
    _neverListenedFirst = _settings.getNeverListenedFirst(); 
  }

  Future<bool> fetchAudioSongs() async {
    final OnAudioQuery audioQuery = OnAudioQuery();

    // Request permissions
    bool hasPermission = await audioQuery.permissionsStatus();
    if (!hasPermission) {
      await audioQuery.permissionsRequest();
    }

    try {
      List<String> paths = _settings.getWhiteList();
      for (String path in paths) {
        List<SongModel> songs = await audioQuery.querySongs(
          orderType: OrderType.ASC_OR_SMALLER,
          sortType: SongSortType.TITLE,
          ignoreCase: true,
          path: path,
        );
        _songs.addAll(songs);
      }

      if (_songs.isEmpty) { return false; }

      _setPlaylist();
      await _sortSongs(_sortState);
      await _updateDaysAgo();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _setPlaylist() {
    _playlist = ConcatenatingAudioSource(
      children: _songs.map((song) => AudioSource.uri(
          Uri.file(song.data),
          tag: MediaItem(
            id: song.id.toString(),
            title: song.title,
            album: song.album,
            artist: song.artist,
          ),
        ),
      ).toList(),
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

  Future<void> _resetLoop(int index) async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero, index: index);
    await _audioPlayer.play();
  }

  Future<void> _sortSongs(int state) async {
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
        await _smartSort();
        break;
      case -1:
        _songs.shuffle();
        break;
    }
    _setPlaylist();
    await _audioPlayer.setAudioSource(_playlist);
  }

  Future<void> _smartSort() async {
    final List<int> ranking = await _db.getRanking();
    final int size = ranking.length;
    final Map<int, int> keyToRank = {for (int i = 0; i < size; i++) ranking[i]: i};
    final int sortPosition = _neverListenedFirst ? -1 : size; // Musiques hors bases sont à la fin ou au début
    
    _songs.sort((a, b) {
      final int keyA = Functions.fastHash(a.album, a.title, a.artist);
      final int keyB = Functions.fastHash(b.album, b.title, b.artist);
      return (keyToRank[keyA] ?? sortPosition).compareTo(keyToRank[keyB] ?? sortPosition);
    });
  }

  Future<void> _updateDaysAgo() async {
    final Map<int, int> idToDaysAgo = Map.fromEntries(
      _songs.map((song) => MapEntry(song.id, _getDays(song.dateAdded)))
    );
    await _db.updateDaysAgo(idToDaysAgo);
  }

  int _getDays(int? dateAdded) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch((dateAdded ?? 30) * 1000, isUtc: true);
    return DateTime.now().difference(date).inDays;
  }
}