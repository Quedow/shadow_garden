import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadow_garden/models/report.dart';
import 'package:shadow_garden/models/songs.dart';
import 'package:shadow_garden/providers/settings_service.dart';
import 'package:shadow_garden/utils/translator.dart';
import 'package:shadow_garden/utils/utility.dart';

part 'database_service.g.dart';

@DriftDatabase(tables: [Songs])
class DatabaseService extends _$DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

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

  factory DatabaseService() => _instance;

  DatabaseService._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'shadow_garden_db',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }

  void init() {
    _smartWeight = _settings.getSmartWeight();
    _dumbWeight = double.parse((1.0 - _smartWeight).toStringAsFixed(2));
  }

  Future<void> updateSong(SongsCompanion song) async {
    await _insertOrUpdateSong(song);
    await _updateScores();
  }


  Future<Song?> _getSong(int key) {
    return managers.songs.filter((s) => s.key.equals(key)).getSingleOrNull();
  }

  Future<void> _insertOrUpdateSong(SongsCompanion song) async {
    final Song? songToUpdate = song.key.present
      ? await _getSong(song.key.value)
      : null;

    if (songToUpdate != null) {
      await managers.songs.filter((s) => s.key.equals(song.key.value)).update(
        (s) => s(
          listeningTime: Value(songToUpdate.listeningTime + song.listeningTime.value),
          nbOfListens: Value(songToUpdate.nbOfListens + 1),
          lastListen: Value(song.lastListen.value),
        )
      );
    } else {
      await managers.songs.create((_) => song);
    }
  }

  Future<void> _updateScores() async {
    final List<Song> allSongs = await managers.songs.get();
    final DateTime now = DateTime.now();

    for (Song song in allSongs) {
      final double smartScore = await _calculateSmartScore(song, allSongs.length, now);
      final double dumbScore = smartScore <= 0.5 ? _dumbWeight * Random().nextDouble() : 0;
      await managers.songs.filter((s) => s.id.equals(song.id)).update(
        (s) => s(
          score: Value(smartScore + dumbScore),
        )
      );
    }
  }

  Future<double> _calculateSmartScore(Song song, int totalSongs, DateTime now) async {
    final int belowSongs = await managers.songs.filter((s) => s.nbOfListens.isSmallerThan(song.nbOfListens)).count();
    final int equalSongs = await managers.songs.filter((s) => s.nbOfListens.equals(song.nbOfListens)).count();
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
      final bool exists = await managers.songs.filter((s) => s.id.equals(entry.key)).exists();
      if (exists) {
        await managers.songs.filter((s) => s.id.equals(entry.key)).update(
          (s) => s(
            daysAgo: Value(entry.value),
          )
        );
      }
    }
  }

  Future<List<int>> getRanking() async {
    final List<Song> songsRanking = await managers.songs.orderBy((s) => s.score.desc()).get();
    return songsRanking.map((Song song) => song.key).toList();
  }

  Future<Statistics> _getGlobalStats() async {
    final Expression<int> nbOfListensSum = songs.nbOfListens.sum();
    final Expression<int> totalListeningTimeSum = songs.listeningTime.sum();
    final query = selectOnly(songs)..addColumns([nbOfListensSum, totalListeningTimeSum]);
    final result = await query.getSingle();

    return Statistics(
      totalNbOfListens: result.read(nbOfListensSum) ?? 0,
      totalListeningTime: result.read(totalListeningTimeSum) ?? 0
    );
  }

  Future<Report> getReport() async {
    final Statistics globalStats = await _getGlobalStats();

    return Report(
      songs: await managers.songs.orderBy((s) => s.score.desc()).get(),
      statistics: Statistics(
        totalNbOfListens: globalStats.totalNbOfListens,
        totalListeningTime: globalStats.totalListeningTime,
      ),
    );
  }

  Future<bool> clearData(int id) async {
    return await managers.songs.filter((s) => s.id.equals(id)).delete() > 0;
  }

  Future<void> clearDatabase([bool keepStats = true]) async {
    if (keepStats) {
      final Statistics globalStats = await _getGlobalStats();
      await _settings.setGlobalStats(globalStats.totalNbOfListens, globalStats.totalListeningTime);
    } else {
      await _settings.clearGlobalStats();
    }
    await managers.songs.delete();
  }

  Future<String> importData(String path) async {
    try {
      final File file = File(path);
      if (!await file.exists()) return 'errorBackupNotFoundSnack'.t();

      final String raw = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(raw);

      final List<Song> songs = (jsonData['songs'] as List).map((s) => Song.fromJson(s)).toList();
      final List<int> globalStats = (jsonData['globalStats'] as List).map((g) => g as int).toList();

      await clearDatabase(false);

      await managers.songs.bulkCreate((_) => songs);
      await _settings.setGlobalStats(globalStats[0], globalStats[1]);
      return 'textSuccessImportSnack'.t();
    } catch (e) {
      return 'errorImportSnack'.t();
    }
  }

  Future<String> exportData(String path) async {
    try {
      final File file = File('$path/shadow_garden_backup_${Utility.getBackupDate()}.json');

      final List<Song> songs = await managers.songs.get();
      final List<String> globalStats = _settings.getGlobalStats();

      final Map<String, dynamic> data = {
        'songs': songs.map((s) => s.toJson()).toList(),
        'globalStats': [int.parse(globalStats[0]), int.parse(globalStats[1])],
      };
      await file.writeAsString(jsonEncode(data));
      return 'textSuccessExportSnack'.t();
    } catch (e) {
      return 'errorExportSnack'.t();
    }
  }
}