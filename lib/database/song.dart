import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadow_garden/provider/settings_service.dart';

part 'song.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;

  int songId = -1;

  String title = '';

  int duration = 0;

  int daysAgo = 0;

  int nbOfListens = 0;

  int listeningTime = 0;

  DateTime lastListen;

  double score = 1.0;

  Song(this.songId, this.title, this.duration, this.daysAgo, this.nbOfListens, this.listeningTime, this.lastListen);
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late final Isar isar;

  final SettingsService _settings = SettingsService();
  static const double mainWeight = 0.90;
  static const double extraWeight = 0.05;
  final int _maxDateAdded = 30;
  final int _maxLastListen = 168;
  
  late double _lRWeight;
  late double _nOfLWeight;
  double get nOfLWeight => _nOfLWeight;
  void setNbOfListenWeight(double value) async {
    _nOfLWeight = value;
    _lRWeight = double.parse((mainWeight - _nOfLWeight).toStringAsFixed(2));
    await _settings.setNbOfListenWeight(value);
  }

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Isar> init() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [SongSchema],
      directory: dir.path,
      inspector: true,
    );
    _nOfLWeight = _settings.getNbOfListenWeight();
    _lRWeight = double.parse((mainWeight - _nOfLWeight).toStringAsFixed(2));

    return isar;
  }

  Future<void> updateSong(Song song) async {
    await isar.writeTxn(() async {
      await _insertOrUpdateSong(song);
      await _updateScores();
    });
  }

  Future<void> _insertOrUpdateSong(Song song) async {
    Song? songToUpdate = await isar.songs.filter().songIdEqualTo(song.songId).titleEqualTo(song.title).findFirst();
    if (songToUpdate != null) {
      songToUpdate.listeningTime += song.listeningTime;
      songToUpdate.nbOfListens += song.nbOfListens;
      songToUpdate.lastListen = song.lastListen;
      await isar.songs.put(songToUpdate);
    } else {
      await isar.songs.put(song);
    }
  }

  Future<void> _updateScores() async {
    List<Song> allSongs = await isar.songs.where().findAll();
    final DateTime now = DateTime.now();

    for (Song song in allSongs) {
      song.score = await _calculateScore(song, allSongs.length, now);
      await isar.songs.put(song);
    }
  }

  Future<double> _calculateScore(Song song, int totalSongs, DateTime now) async {
    int belowSongs = await isar.songs.filter().nbOfListensLessThan(song.nbOfListens).count();
    int equalSongs = await isar.songs.filter().nbOfListensEqualTo(song.nbOfListens).count();
    int listenHoursAgo = now.difference(song.lastListen).inHours;

    double addedDateScore = extraWeight * (song.daysAgo <= 2 ? 1 : song.daysAgo > _maxDateAdded ? 0 : (-1/_maxDateAdded * song.daysAgo + 1));
    double lastListenScore = extraWeight * (listenHoursAgo > _maxLastListen ? 0 : (-1/_maxLastListen * listenHoursAgo + 1));
    double nbOfListensScore = _nOfLWeight * ((belowSongs + 0.5 * equalSongs) / totalSongs);
    double listenRateScore = _lRWeight * (song.listeningTime / (song.nbOfListens * song.duration));

    return  double.parse((addedDateScore + lastListenScore + nbOfListensScore + listenRateScore).toStringAsFixed(3));
  }

  Future<void> updateDaysAgo(Map<int, int> songsDaysAgo) async {
    for (MapEntry<int, int> songDaysAgo in songsDaysAgo.entries) {
      await isar.writeTxn(() async {
        Song? songToUpdate = await isar.songs.filter().songIdEqualTo(songDaysAgo.key).findFirst();
        if (songToUpdate != null) {
          songToUpdate.daysAgo += songDaysAgo.value;
          await isar.songs.put(songToUpdate);
        }
      });
    }
  }

  Future<List<int>> getRanking() async {
    final List<Song> songsRanking = await isar.songs.where().sortByScoreDesc().thenByDaysAgo().findAll();
    return songsRanking.map((Song song) => song.songId).toList();
  }

  Future<Map<String, dynamic>> getDataSongs() async {
    return {
      'songs': await isar.songs.where().sortByScoreDesc().thenByDaysAgo().findAll(),
      'data': {
        'totalNbOfListens': await isar.songs.where().nbOfListensProperty().sum(),
        'totalListeningTime': await isar.songs.where().listeningTimeProperty().sum(),
      },
    };
  }

  Future<void> clearDatabase() async {
    await isar.writeTxn(() async {
      await isar.songs.clear();
    });
  }
}
