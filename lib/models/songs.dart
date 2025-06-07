import 'package:drift/drift.dart';

@TableIndex(name: 'song_score', columns: {#score})
class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get key => integer()();
  TextColumn get title => text()();
  IntColumn get duration => integer()();
  IntColumn get daysAgo => integer()();
  IntColumn get listeningTime => integer()();
  DateTimeColumn get lastListen => dateTime()();
  IntColumn get nbOfListens => integer().withDefault(const Constant(1))();
  RealColumn get score => real().withDefault(const Constant(1.0))();  
}