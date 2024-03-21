import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadow_garden/model/song.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/widgets/controls.dart';

class AudioProvider extends ChangeNotifier {
  final SettingsService _settings = SettingsService();
  final DatabaseService _db = DatabaseService();
  final Map<int, Song> _songsToDb = {};

  bool isLoading = false;

  List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  ConcatenatingAudioSource get playlist => _playlist;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  late int _songsPerLoop;
  int get songsPerLoop => _songsPerLoop;
  set songsPerLoop(int number) {
    _songsPerLoop = number;
    _settings.setSongsPerLoop(number);
    notifyListeners();
  }

  late CLoopMode _cLoopMode;
  CLoopMode get cLoopMode => _cLoopMode;
  set cLoopMode(CLoopMode cMode) {
    _cLoopMode = cMode;
    _settings.setCLoopMode(cMode);
    notifyListeners();
  }

  final int _totalState = 5;
  late int _sortState;
  int get sortState => _sortState;
  void setSortState() {
    _sortState = (_sortState + 1) % _totalState;
    _settings.setSortState(_sortState);
    sortSongs(_sortState);
    notifyListeners();
  }

  int _indexCounter = 0;
  int _lastIndex = 0;

  AudioProvider() {
    cLoopMode = _settings.getCLoopMode();
    songsPerLoop = _settings.getSongsPerLoop();
    _sortState = _settings.getSortState();

    _audioPlayer.currentIndexStream.listen((index) async {
      if (index == null) { return; }

      if (_cLoopMode == CLoopMode.custom) {
        _indexCounter = (index == _lastIndex + 1) ? _indexCounter + 1 : 0;
        _lastIndex = index;
        if (_indexCounter == _songsPerLoop) {
          resetLoop(index - _songsPerLoop);
          _indexCounter = 0;
        }
      }
    });

    _audioPlayer.positionDiscontinuityStream.listen((reason) {
      List<IndexedAudioSource>? sequence = _audioPlayer.sequence;
      int? index = _audioPlayer.currentIndex;

      if (sequence != null && index != null) {
        final int currentAudioId = int.parse(sequence[index].tag.id);
        final SongModel currentSong = _songs.firstWhere((song) => song.id == currentAudioId);
        _songsToDb.update(currentSong.id, 
          (song) => updateData(song), 
          ifAbsent: () => insertSong(currentSong)
        );
      }
    });
  }

  Song updateData(Song song) {
    song.nbOfListens++;
    return song;
  }

  Song insertSong(SongModel song) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch((song.dateAdded ?? 0) * 1000, isUtc: true);
    final int months = DateTime.now().difference(date).inDays ~/ 30;

    return Song(song.id, song.title, months, 1);
  }

  void saveInDatabase() {
    _db.updateSongs(_songsToDb.values.toList());
    _songsToDb.clear();
  }

  void clearDatabase() {
    _db.clearDatabase();
    _songsToDb.clear();
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
      sortSongs(_sortState);

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

    if (_cLoopMode == CLoopMode.custom) {
      _indexCounter = 0;
    }
  }

  Future<void> resetLoop(int index) async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero, index: index);
    if (_audioPlayer.playing) {
      await _audioPlayer.play();
    }
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
        _songs.shuffle();
        break;
      case 4:
        _songs.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
        break;
    }
    setPlaylist();
    _audioPlayer.setAudioSource(_playlist);
  }
}