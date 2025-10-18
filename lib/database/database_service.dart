import 'dart:io';
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
  
  late List<double> _weights;
  List<double> get weights => _weights;
  void setWeights(List<double> values) {
    _weights = values;
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
    _weights = _settings.getWeights();
  }

  Future<void> updateSong(SongsCompanion song) async {
    await _insertOrUpdateSong(song);
    await _updateScores(['nbOfListens', 'listeningTime', 'daysAgo', 'lastListen']);
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

  Future<void> _updateScores(List<String> columns) async {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < columns.length; i++) {
      if (i >= weights.length) break;

      final String column = columns[i];
      final double weight = _weights[i];

      if (i > 0) buffer.write(' + ');

      buffer.write('''
        $weight * (
          (SELECT COUNT(*) FROM songs AS s2 WHERE s2.$column < songs.$column)
          + 0.5 * (SELECT COUNT(*) FROM songs AS s3 WHERE s3.$column = songs.$column)
        ) / (SELECT COUNT(*) FROM songs)
      ''');
    }

    final String sql = '''
      UPDATE songs
      SET score = (${buffer.toString()})
    ''';

    await customUpdate(sql, updates: {songs});
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
      totalListeningTime: result.read(totalListeningTimeSum) ?? 0,
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

  Future<void> clearDatabase([bool keepGlobal = true]) async {
    if (keepGlobal) {
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