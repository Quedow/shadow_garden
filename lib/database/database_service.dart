import 'dart:io';

import 'dart:math';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadow_garden/models/report.dart';
import 'package:shadow_garden/models/song.dart';
import 'package:shadow_garden/providers/settings_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late final Isar isar;

  final SettingsService _settings = SettingsService();
  final int _maxDateAdded = 30;
  final int _maxLastListen = 168;
  
  late double _dumbWeight;
  late double _smartWeight;
  double get smartWeight => _smartWeight;
  void setSmartWeight(double value) async {
    _smartWeight = value;
    _dumbWeight = double.parse((1.0 - _smartWeight).toStringAsFixed(2));
    await _settings.setSmartWeight(value);
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
      inspector: false, // set to false for build
    );
    _smartWeight = _settings.getSmartWeight();
    _dumbWeight = double.parse((1.0 - _smartWeight).toStringAsFixed(2));

    return isar;
  }

  Future<void> updateSong(Song song) async {
    await isar.writeTxn(() async {
      await _insertOrUpdateSong(song);
      await _updateScores();
    });
  }

  Future<void> _insertOrUpdateSong(Song song) async {
    final Song? songToUpdate = await isar.songs.filter().keyEqualTo(song.key).findFirst();
    if (songToUpdate != null) {
      songToUpdate.listeningTime += song.listeningTime;
      songToUpdate.nbOfListens += 1;
      songToUpdate.lastListen = song.lastListen;
      await isar.songs.put(songToUpdate);
    } else {
      await isar.songs.put(song);
    }
  }

  Future<void> _updateScores() async {
    final List<Song> allSongs = await isar.songs.where().findAll();
    final DateTime now = DateTime.now();

    for (Song song in allSongs) {
      final double smartScore = await _calculateSmartScore(song, allSongs.length, now);
      final double dumbScore = smartScore <= 0.5 ? _dumbWeight * Random().nextDouble() : 0;
      song.score = smartScore + dumbScore;
      await isar.songs.put(song);
    }
  }

  Future<double> _calculateSmartScore(Song song, int totalSongs, DateTime now) async {
    final int belowSongs = await isar.songs.filter().nbOfListensLessThan(song.nbOfListens).count();
    final int equalSongs = await isar.songs.filter().nbOfListensEqualTo(song.nbOfListens).count();
    final int listenHoursAgo = now.difference(song.lastListen).inHours;

    final double addedDateScore = song.daysAgo <= 2 ? 1 : song.daysAgo > _maxDateAdded ? 0 : (-1/_maxDateAdded * song.daysAgo + 1);
    final double lastListenScore = listenHoursAgo > _maxLastListen ? 0 : (-1/_maxLastListen * listenHoursAgo + 1);
    final double listeningRate = song.listeningTime / (song.nbOfListens * song.duration);
    final double percentileRank = (belowSongs + 0.5 * equalSongs) / totalSongs;

    return double.parse((
      _smartWeight * (
        0.05 * addedDateScore
        + 0.05 * lastListenScore
        + 0.4 * listeningRate
        + 0.5 * percentileRank
      )
    ).toStringAsFixed(3));
  }

  Future<void> updateDaysAgo(Map<int, int> idToDaysAgo) async {
    for (MapEntry<int, int> entry in idToDaysAgo.entries) {
      await isar.writeTxn(() async {
        Song? songToUpdate = await isar.songs.filter().idEqualTo(entry.key).findFirst();
        if (songToUpdate != null) {
          songToUpdate.daysAgo = entry.value;
          await isar.songs.put(songToUpdate);
        }
      });
    }
  }

  Future<List<int>> getRanking() async {
    final List<Song> songsRanking = await isar.songs.where(sort: Sort.desc).anyScore().findAll();
    return songsRanking.map((Song song) => song.key).toList();
  }

  Future<Report> getReport() async {
    return Report(
      songs: await isar.songs.where(sort: Sort.desc).anyScore().findAll(),
      statistics: Statistics(
        totalNbOfListens: await isar.songs.where().nbOfListensProperty().sum(),
        totalListeningTime: await isar.songs.where().listeningTimeProperty().sum(),
      ),
    );
  }

  Future<bool> clearData(int id) async {
    late bool success;
    await isar.writeTxn(() async {
      success = await isar.songs.delete(id);
    });
    return success;
  }

  Future<void> clearDatabase() async {
    final List<int> globalStats = await Future.wait([
      isar.songs.where().nbOfListensProperty().sum(),
      isar.songs.where().listeningTimeProperty().sum(),
    ]);
    await _settings.setGlobalStats(globalStats[0], globalStats[1]);

    await isar.writeTxn(() async {
      await isar.songs.clear();
    });
  }
}
