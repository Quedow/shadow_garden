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

  int monthsAgo = 0;

  int nbOfListens = 0;

  int listeningTime = 0;

  double score = 1.0;

  // bool favorite = false;

  Song(this.songId, this.title, this.duration, this.monthsAgo, this.nbOfListens, this.listeningTime);
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late final Isar isar;

  final SettingsService _settings = SettingsService();
  final int maxDateAdded = 12;
  late double _lRWeight;

  late double _nOfLWeight;
  double get nOfLWeight => _nOfLWeight;
  void setNbOfListenWeight (double value) async {
    _nOfLWeight = value;
    _lRWeight = double.parse((0.90 - nOfLWeight).toStringAsFixed(2));
    await _settings.setNbOfListenWeight(value);
  }

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [SongSchema],
      directory: dir.path,
      inspector: true
    );
    _nOfLWeight = _settings.getNbOfListenWeight();
    _lRWeight = double.parse((0.90 - nOfLWeight).toStringAsFixed(2));
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
      await isar.songs.put(songToUpdate);
    } else {
      await isar.songs.put(song);
    }
  }

  Future<void> _updateScores() async {
    List<Song> allSongs = await isar.songs.where().findAll();

    for (var song in allSongs) {
      song.score = await _calculateScore(song, allSongs.length);
      await isar.songs.put(song);
    }
  }

  Future<double> _calculateScore(Song song, int totalSongs) async {
    int belowSongs = await isar.songs.filter().nbOfListensLessThan(song.nbOfListens).count();
    int equalSongs = await isar.songs.filter().nbOfListensEqualTo(song.nbOfListens).count();

    double addedDateScore = 0.10 * (song.monthsAgo > maxDateAdded ? 0 : (-1/maxDateAdded * song.monthsAgo + 1));
    double nbOfListensScore = _nOfLWeight * ((belowSongs + 0.5 * equalSongs) / totalSongs);
    double listenRateScore = _lRWeight * (song.listeningTime / (song.nbOfListens * song.duration));

    return  double.parse((addedDateScore + nbOfListensScore + listenRateScore).toStringAsFixed(3));
  }

  Future<List<int>> getRanking() async {
    final List<Song> songsRanking = await isar.songs.where().sortByScoreDesc().thenByMonthsAgo().findAll();
    return songsRanking.map((song) => song.songId).toList();
  }

  Future<Map<String, dynamic>> getDataSongs() async {
    return {
      'songs': await isar.songs.where().sortByScoreDesc().thenByMonthsAgo().findAll(),
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
