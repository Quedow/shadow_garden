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

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'title': title,
    'duration': duration,
    'daysAgo': daysAgo,
    'listeningTime': listeningTime,
    'lastListen': lastListen.toIso8601String(),
    'songId': songId,
    'nbOfListens': nbOfListens,
    'score': score,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    json['key'] as int,
    json['title'] as String,
    json['duration'] as int,
    json['daysAgo'] as int,
    json['listeningTime'] as int,
    DateTime.parse(json['lastListen'] as String),
  )
  ..id = json['id'] as int
  ..songId = json['songId'] as int
  ..nbOfListens = json['nbOfListens'] as int
  ..score = (json['score'] as num).toDouble();
}