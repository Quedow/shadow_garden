import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'song.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;

  int songId = -1;

  String title = '';

  int dateAdded = 0;

  int nbOfListens = 0;

  double listeningRate = 1.0;

  double score = 1.0;

  Song(this.songId, this.title, this.dateAdded, this.nbOfListens, this.listeningRate);
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late final Isar isar;

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

  Future<void> insertSong(Song song) async {
    await isar.writeTxn(() async {
      await isar.songs.put(song);
    });
  }

  Future<void> updateSong(Song song) async {
    await isar.writeTxn(() async {
      await isar.songs.put(song);
    });
  }

  Future<void> removeSong(int id) async {
    await isar.writeTxn(() async {
      await isar.songs.delete(id);
    });
  }
}
