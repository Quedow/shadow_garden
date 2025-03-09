import 'package:isar/isar.dart';

part 'song.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;

  // Required in constructor
  int key;
  String title;
  int duration;
  int daysAgo;
  int listeningTime;
  DateTime lastListen;

  // Not required in constructor
  int songId = -1; // Useless since migration 4 to 5
  int nbOfListens = 1;

  @Index()
  double score = 1.0;

  Song(this.key, this.title, this.duration, this.daysAgo, this.listeningTime, this.lastListen);
}