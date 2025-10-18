import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadow_garden/database/database_service.dart';
import 'package:shadow_garden/models/report.dart';
import 'package:shadow_garden/providers/settings_service.dart';
import 'package:shadow_garden/widgets/controls.dart';
import 'package:shadow_garden/utils/utility.dart';

class AudioProvider extends ChangeNotifier {
  final SettingsService _settings = SettingsService();
  final DatabaseService _db = DatabaseService();

  final List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;

  List<AudioSource> _playlist = [];
  List<AudioSource> get playlist => _playlist;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  late final String _directoryPath;
  bool _loading = false;

  bool get shuffleEnabled => _audioPlayer.shuffleModeEnabled;
  void setShuffleEnabled() async {
    await _shuffle(!_audioPlayer.shuffleModeEnabled);
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
    if (shuffleEnabled) {
      await _shuffle(false);
    } else {
      _sortState = (_sortState + 1) % _totalState;
      await _settings.setSortState(_sortState);
      await _sortSongs(_sortState, index: _audioPlayer.currentIndex);
    }
    notifyListeners();
  }

  late bool _neverListenedFirst;
  bool get neverListenedFirst => _neverListenedFirst;
  void setNeverListenedFirst(bool value) async {
    _neverListenedFirst = value;
    await _settings.setNeverListenedFirst(value);
  }

  Report _report = Report(songs: [], statistics: Statistics(totalNbOfListens: 0, totalListeningTime: 0));
  Report get report => _report;

  Future<void> fetchReport() async {
    _report = await _db.getReport();
    notifyListeners();
  }

  Set<int> _cLoopIndexes = {0};
  bool _restLoopFlag = false;
  Duration _lastPosition = Duration.zero;

  AudioProvider() {
    initSettings();

    _audioPlayer.currentIndexStream.listen((int? index) async {
      if (_cLoopMode != CLoopMode.custom || shuffleEnabled) return;
      if (index == null || index == _cLoopIndexes.lastOrNull) return;

      final int first = _cLoopIndexes.first;
      if (_restLoopFlag) {
        _cLoopIndexes = {index};
        _restLoopFlag = false;
      } else if (index == 0 && first != 0) {
        _cLoopIndexes = {first};
        await _restartLoop(first);
      } else if (_cLoopIndexes.length == _songsPerLoop && index == (first + _songsPerLoop) % _playlist.length) {
        _cLoopIndexes = {first};
        await _restartLoop(first);
      } else if (index == _cLoopIndexes.last || index == _cLoopIndexes.last + 1) {
        _cLoopIndexes.add(index);
      } else if (index < first) {
        _cLoopIndexes = {index};
      }
    });

    _audioPlayer.positionStream.listen((Duration position) {
      _lastPosition = position;
    });

    _audioPlayer.positionDiscontinuityStream.listen((PositionDiscontinuity discontinuity) {
      if (_audioPlayer.position.inSeconds == 0 && audioPlayer.playerState.playing) {
        SongModel? currentSong = Utility.getSongModel(_audioPlayer, _songs, discontinuity.previousEvent.currentIndex);

        if (currentSong != null) {
          int duration =  discontinuity.previousEvent.duration != null
            ? discontinuity.previousEvent.duration!.inSeconds
            : _lastPosition.inSeconds;

          final int key = Utility.fastHash(currentSong.album, currentSong.title, currentSong.artist);

          _db.updateSong(SongsCompanion(
            key: Value(key),
            title: Value(currentSong.title),
            duration: Value(duration),
            addedDate: Value(DateTime.now()),
            listeningTime: Value(_lastPosition.inSeconds),
            lastListen: Value(DateTime.now()),
          ));
        }
      }
    });
  }

  void initSettings() {
    _cLoopMode = _settings.getCLoopMode();
    _songsPerLoop = _settings.getSongsPerLoop();
    _sortState = _settings.getSortState();
    _neverListenedFirst = _settings.getNeverListenedFirst();
  }

  Future<bool> fetchAudioSongs() async {
    final OnAudioQuery audioQuery = OnAudioQuery();
    _directoryPath = (await getTemporaryDirectory()).path;

    // Request permissions
    bool hasPermission = await audioQuery.permissionsStatus();
    if (!hasPermission) {
      await audioQuery.permissionsRequest();
    }

    try {
      List<String> paths = _settings.getWhiteList();
      for (String path in paths) {
        List<SongModel> results = await audioQuery.querySongs(
          orderType: OrderType.ASC_OR_SMALLER,
          sortType: SongSortType.TITLE,
          ignoreCase: true,
          path: path,
        );
        _songs.addAll(results);
      }

      if (_songs.isEmpty) { return false; }

      await _sortSongs(_sortState, initialIndex: _settings.getLastIndex());
      _loadArtworkInBackground(audioQuery);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  void _loadArtworkInBackground(OnAudioQuery audioQuery) {
    Future(() async {
      await Future.wait(_songs.map((song) async {
        final File file = File('$_directoryPath/${song.id}.jpg');

        if (await file.exists()) return;

        try {
          final Uint8List? artworkData = await audioQuery.queryArtwork(song.id, ArtworkType.AUDIO);
          if (artworkData != null) {
            await file.writeAsBytes(artworkData, flush: true);
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }));
    });
  }

  void _setPlaylist() {
    _playlist = _songs.map((song) => AudioSource.uri(
      Uri.file(song.data),
      tag: MediaItem(
        id: song.id.toString(),
        title: song.title,
        album: song.album,
        artist: song.artist,
        artUri: Uri.parse('file://$_directoryPath/${song.id}.jpg')
      ),
    )).toList();
  }

  void setLoopMode(LoopMode mode, CLoopMode cMode) async {
    await _audioPlayer.setLoopMode(mode);
    setCLoopMode(cMode);

    if (_cLoopMode == CLoopMode.custom) {
      _cLoopIndexes = {_audioPlayer.currentIndex ?? 0};
    }
  }

  void resetLoop() {
    if (_cLoopMode != CLoopMode.custom) return;
    _restLoopFlag = true;
  }

  Future<void> _restartLoop(int index) async {
    final bool playing = _audioPlayer.playing;
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero, index: index);
    if (playing) await _audioPlayer.play();
  }

  Future<void> _sortSongs(int state, {int? initialIndex, int? index}) async {
    if (_loading) return;
    _loading = true;
    SongModel? currentSong;
    if (index != null && _audioPlayer.playing) {
      currentSong = Utility.getSongModel(_audioPlayer, songs, index);
      await _audioPlayer.moveAudioSource(index, 0);
    }
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
    }
    _setPlaylist();    
    if (currentSong != null) {
      await _audioPlayer.removeAudioSourceRange(1, _audioPlayer.sequence.length);
      final duplicateCurrentIndex = _songs.indexOf(currentSong);
      await _audioPlayer.addAudioSources(_playlist..removeAt(duplicateCurrentIndex));
    } else {
      await _audioPlayer.setAudioSources(_playlist, initialIndex: initialIndex);
    }
    _loading = false;
  }

  Future<void> _shuffle(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  Future<void> _smartSort() async {
    final List<int> ranking = await _db.getRanking();
    final int size = ranking.length;
    final Map<int, int> keyToRank = {for (int i = 0; i < size; i++) ranking[i]: i};
    final int sortPosition = _neverListenedFirst ? -1 : size; // Musiques hors bases sont à la fin ou au début
    
    _songs.sort((a, b) {
      final int keyA = Utility.fastHash(a.album, a.title, a.artist);
      final int keyB = Utility.fastHash(b.album, b.title, b.artist);
      return (keyToRank[keyA] ?? sortPosition).compareTo(keyToRank[keyB] ?? sortPosition);
    });
  }
}