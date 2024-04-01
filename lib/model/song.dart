import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'song.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;

  int songId = -1;

  String label = '';

  int dateAdded = 0;

  int nbOfListens = 0;

  double listeningRate = 1.0;

  double score = 1.0;

  bool favorite = false;

  Song(this.songId, this.label, this.dateAdded, this.nbOfListens, this.listeningRate);
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late final Isar isar;

  final int maxDateAdded = 12;

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
  }

  Future<void> updateSong(Song song) async {
    await isar.writeTxn(() async {
      await _insertOrUpdateSong(song);
      await _updateScores();
    });
  }

  Future<void> updateSongs(List<Song> songs) async {
    await isar.writeTxn(() async {
      for (var song in songs) {
        await _insertOrUpdateSong(song);
      }
      await _updateScores();
    });
  }

  Future<void> _insertOrUpdateSong(Song song) async {
    Song? songToUpdate = await isar.songs.filter().songIdEqualTo(song.songId).labelEqualTo(song.label).findFirst();
    if (songToUpdate != null) {
      songToUpdate.nbOfListens += song.nbOfListens;
      songToUpdate.listeningRate = double.parse(((songToUpdate.listeningRate + song.listeningRate)/2).toStringAsFixed(3));
      await isar.songs.put(songToUpdate);
    } else {
      await isar.songs.put(song);
    }
  }

  Future<void> _updateScores() async {
    List<Song> allSongs = await isar.songs.where().findAll();
    int totalOfListens = await isar.songs.where().nbOfListensProperty().sum();

    for (var song in allSongs) {
      song.score = _calculateScore(song.nbOfListens, totalOfListens, song.dateAdded, song.listeningRate);
      await isar.songs.put(song);
    }
  }

  double _calculateScore(int nbOfListens, int totalOfListens, int dateAdded, double listeningRate) {
    double addedDateScore = 0.15 * (dateAdded > maxDateAdded ? 0 : (-1/maxDateAdded * dateAdded + 1));
    double nbOfListensScore = 0.45 * (nbOfListens / totalOfListens);
    double listenRateScore = 0.40 * listeningRate;

    return  double.parse((addedDateScore + nbOfListensScore + listenRateScore).toStringAsFixed(2));
  }

  Future<List<String>> getRanking() async {
    final List<Song> songsRanking = await isar.songs.where().sortByScoreDesc().thenByNbOfListensDesc().thenByListeningRateDesc().findAll();
    return songsRanking.map((song) => song.label).toList();
  }

  Future<List<Song>> getAllSongs() async {
    return await isar.songs.where().sortByScoreDesc().thenByNbOfListensDesc().thenByListeningRateDesc().findAll();
  }

  Future<void> clearDatabase() async {
    await isar.writeTxn(() async {
      await isar.songs.clear();
    });
  }
}
