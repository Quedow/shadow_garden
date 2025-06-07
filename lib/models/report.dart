import 'package:shadow_garden/database/database_service.dart';

class Report {
  final List<Song> songs;
  final Statistics statistics;

  Report({required this.songs, required this.statistics});
}

class Statistics {
  final int totalNbOfListens;
  final int totalListeningTime;

  Statistics({required this.totalNbOfListens, required this.totalListeningTime});
}