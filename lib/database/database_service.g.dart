// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<int> key = GeneratedColumn<int>(
      'key', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _daysAgoMeta =
      const VerificationMeta('daysAgo');
  @override
  late final GeneratedColumn<int> daysAgo = GeneratedColumn<int>(
      'daysAgo', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _listeningTimeMeta =
      const VerificationMeta('listeningTime');
  @override
  late final GeneratedColumn<int> listeningTime = GeneratedColumn<int>(
      'listeningTime', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastListenMeta =
      const VerificationMeta('lastListen');
  @override
  late final GeneratedColumn<DateTime> lastListen = GeneratedColumn<DateTime>(
      'lastListen', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _nbOfListensMeta =
      const VerificationMeta('nbOfListens');
  @override
  late final GeneratedColumn<int> nbOfListens = GeneratedColumn<int>(
      'nbOfListens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        key,
        title,
        duration,
        daysAgo,
        listeningTime,
        lastListen,
        nbOfListens,
        score
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Songs';
  @override
  VerificationContext validateIntegrity(Insertable<Song> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('daysAgo')) {
      context.handle(_daysAgoMeta,
          daysAgo.isAcceptableOrUnknown(data['daysAgo']!, _daysAgoMeta));
    } else if (isInserting) {
      context.missing(_daysAgoMeta);
    }
    if (data.containsKey('listeningTime')) {
      context.handle(
          _listeningTimeMeta,
          listeningTime.isAcceptableOrUnknown(
              data['listeningTime']!, _listeningTimeMeta));
    } else if (isInserting) {
      context.missing(_listeningTimeMeta);
    }
    if (data.containsKey('lastListen')) {
      context.handle(
          _lastListenMeta,
          lastListen.isAcceptableOrUnknown(
              data['lastListen']!, _lastListenMeta));
    } else if (isInserting) {
      context.missing(_lastListenMeta);
    }
    if (data.containsKey('nbOfListens')) {
      context.handle(
          _nbOfListensMeta,
          nbOfListens.isAcceptableOrUnknown(
              data['nbOfListens']!, _nbOfListensMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}key'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      daysAgo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daysAgo'])!,
      listeningTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}listeningTime'])!,
      lastListen: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}lastListen'])!,
      nbOfListens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nbOfListens'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  final int id;
  final int key;
  final String title;
  final int duration;
  final int daysAgo;
  final int listeningTime;
  final DateTime lastListen;
  final int nbOfListens;
  final double score;
  const Song(
      {required this.id,
      required this.key,
      required this.title,
      required this.duration,
      required this.daysAgo,
      required this.listeningTime,
      required this.lastListen,
      required this.nbOfListens,
      required this.score});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<int>(key);
    map['title'] = Variable<String>(title);
    map['duration'] = Variable<int>(duration);
    map['daysAgo'] = Variable<int>(daysAgo);
    map['listeningTime'] = Variable<int>(listeningTime);
    map['lastListen'] = Variable<DateTime>(lastListen);
    map['nbOfListens'] = Variable<int>(nbOfListens);
    map['score'] = Variable<double>(score);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      key: Value(key),
      title: Value(title),
      duration: Value(duration),
      daysAgo: Value(daysAgo),
      listeningTime: Value(listeningTime),
      lastListen: Value(lastListen),
      nbOfListens: Value(nbOfListens),
      score: Value(score),
    );
  }

  factory Song.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<int>(json['key']),
      title: serializer.fromJson<String>(json['title']),
      duration: serializer.fromJson<int>(json['duration']),
      daysAgo: serializer.fromJson<int>(json['daysAgo']),
      listeningTime: serializer.fromJson<int>(json['listeningTime']),
      lastListen: serializer.fromJson<DateTime>(json['lastListen']),
      nbOfListens: serializer.fromJson<int>(json['nbOfListens']),
      score: serializer.fromJson<double>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<int>(key),
      'title': serializer.toJson<String>(title),
      'duration': serializer.toJson<int>(duration),
      'daysAgo': serializer.toJson<int>(daysAgo),
      'listeningTime': serializer.toJson<int>(listeningTime),
      'lastListen': serializer.toJson<DateTime>(lastListen),
      'nbOfListens': serializer.toJson<int>(nbOfListens),
      'score': serializer.toJson<double>(score),
    };
  }

  Song copyWith(
          {int? id,
          int? key,
          String? title,
          int? duration,
          int? daysAgo,
          int? listeningTime,
          DateTime? lastListen,
          int? nbOfListens,
          double? score}) =>
      Song(
        id: id ?? this.id,
        key: key ?? this.key,
        title: title ?? this.title,
        duration: duration ?? this.duration,
        daysAgo: daysAgo ?? this.daysAgo,
        listeningTime: listeningTime ?? this.listeningTime,
        lastListen: lastListen ?? this.lastListen,
        nbOfListens: nbOfListens ?? this.nbOfListens,
        score: score ?? this.score,
      );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      title: data.title.present ? data.title.value : this.title,
      duration: data.duration.present ? data.duration.value : this.duration,
      daysAgo: data.daysAgo.present ? data.daysAgo.value : this.daysAgo,
      listeningTime: data.listeningTime.present
          ? data.listeningTime.value
          : this.listeningTime,
      lastListen:
          data.lastListen.present ? data.lastListen.value : this.lastListen,
      nbOfListens:
          data.nbOfListens.present ? data.nbOfListens.value : this.nbOfListens,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('duration: $duration, ')
          ..write('daysAgo: $daysAgo, ')
          ..write('listeningTime: $listeningTime, ')
          ..write('lastListen: $lastListen, ')
          ..write('nbOfListens: $nbOfListens, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, title, duration, daysAgo,
      listeningTime, lastListen, nbOfListens, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.key == this.key &&
          other.title == this.title &&
          other.duration == this.duration &&
          other.daysAgo == this.daysAgo &&
          other.listeningTime == this.listeningTime &&
          other.lastListen == this.lastListen &&
          other.nbOfListens == this.nbOfListens &&
          other.score == this.score);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<int> key;
  final Value<String> title;
  final Value<int> duration;
  final Value<int> daysAgo;
  final Value<int> listeningTime;
  final Value<DateTime> lastListen;
  final Value<int> nbOfListens;
  final Value<double> score;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.title = const Value.absent(),
    this.duration = const Value.absent(),
    this.daysAgo = const Value.absent(),
    this.listeningTime = const Value.absent(),
    this.lastListen = const Value.absent(),
    this.nbOfListens = const Value.absent(),
    this.score = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    required int key,
    required String title,
    required int duration,
    required int daysAgo,
    required int listeningTime,
    required DateTime lastListen,
    this.nbOfListens = const Value.absent(),
    this.score = const Value.absent(),
  })  : key = Value(key),
        title = Value(title),
        duration = Value(duration),
        daysAgo = Value(daysAgo),
        listeningTime = Value(listeningTime),
        lastListen = Value(lastListen);
  static Insertable<Song> custom({
    Expression<int>? id,
    Expression<int>? key,
    Expression<String>? title,
    Expression<int>? duration,
    Expression<int>? daysAgo,
    Expression<int>? listeningTime,
    Expression<DateTime>? lastListen,
    Expression<int>? nbOfListens,
    Expression<double>? score,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (duration != null) 'duration': duration,
      if (daysAgo != null) 'daysAgo': daysAgo,
      if (listeningTime != null) 'listeningTime': listeningTime,
      if (lastListen != null) 'lastListen': lastListen,
      if (nbOfListens != null) 'nbOfListens': nbOfListens,
      if (score != null) 'score': score,
    });
  }

  SongsCompanion copyWith(
      {Value<int>? id,
      Value<int>? key,
      Value<String>? title,
      Value<int>? duration,
      Value<int>? daysAgo,
      Value<int>? listeningTime,
      Value<DateTime>? lastListen,
      Value<int>? nbOfListens,
      Value<double>? score}) {
    return SongsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      daysAgo: daysAgo ?? this.daysAgo,
      listeningTime: listeningTime ?? this.listeningTime,
      lastListen: lastListen ?? this.lastListen,
      nbOfListens: nbOfListens ?? this.nbOfListens,
      score: score ?? this.score,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<int>(key.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (daysAgo.present) {
      map['daysAgo'] = Variable<int>(daysAgo.value);
    }
    if (listeningTime.present) {
      map['listeningTime'] = Variable<int>(listeningTime.value);
    }
    if (lastListen.present) {
      map['lastListen'] = Variable<DateTime>(lastListen.value);
    }
    if (nbOfListens.present) {
      map['nbOfListens'] = Variable<int>(nbOfListens.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('duration: $duration, ')
          ..write('daysAgo: $daysAgo, ')
          ..write('listeningTime: $listeningTime, ')
          ..write('lastListen: $lastListen, ')
          ..write('nbOfListens: $nbOfListens, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }
}

abstract class _$DatabaseService extends GeneratedDatabase {
  _$DatabaseService(QueryExecutor e) : super(e);
  $DatabaseServiceManager get managers => $DatabaseServiceManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final Index songScore =
      Index('song_score', 'CREATE INDEX song_score ON Songs (score)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [songs, songScore];
}

typedef $$SongsTableCreateCompanionBuilder = SongsCompanion Function({
  Value<int> id,
  required int key,
  required String title,
  required int duration,
  required int daysAgo,
  required int listeningTime,
  required DateTime lastListen,
  Value<int> nbOfListens,
  Value<double> score,
});
typedef $$SongsTableUpdateCompanionBuilder = SongsCompanion Function({
  Value<int> id,
  Value<int> key,
  Value<String> title,
  Value<int> duration,
  Value<int> daysAgo,
  Value<int> listeningTime,
  Value<DateTime> lastListen,
  Value<int> nbOfListens,
  Value<double> score,
});

class $$SongsTableFilterComposer
    extends Composer<_$DatabaseService, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysAgo => $composableBuilder(
      column: $table.daysAgo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listeningTime => $composableBuilder(
      column: $table.listeningTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastListen => $composableBuilder(
      column: $table.lastListen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nbOfListens => $composableBuilder(
      column: $table.nbOfListens, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));
}

class $$SongsTableOrderingComposer
    extends Composer<_$DatabaseService, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysAgo => $composableBuilder(
      column: $table.daysAgo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listeningTime => $composableBuilder(
      column: $table.listeningTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastListen => $composableBuilder(
      column: $table.lastListen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nbOfListens => $composableBuilder(
      column: $table.nbOfListens, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));
}

class $$SongsTableAnnotationComposer
    extends Composer<_$DatabaseService, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get daysAgo =>
      $composableBuilder(column: $table.daysAgo, builder: (column) => column);

  GeneratedColumn<int> get listeningTime => $composableBuilder(
      column: $table.listeningTime, builder: (column) => column);

  GeneratedColumn<DateTime> get lastListen => $composableBuilder(
      column: $table.lastListen, builder: (column) => column);

  GeneratedColumn<int> get nbOfListens => $composableBuilder(
      column: $table.nbOfListens, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);
}

class $$SongsTableTableManager extends RootTableManager<
    _$DatabaseService,
    $SongsTable,
    Song,
    $$SongsTableFilterComposer,
    $$SongsTableOrderingComposer,
    $$SongsTableAnnotationComposer,
    $$SongsTableCreateCompanionBuilder,
    $$SongsTableUpdateCompanionBuilder,
    (Song, BaseReferences<_$DatabaseService, $SongsTable, Song>),
    Song,
    PrefetchHooks Function()> {
  $$SongsTableTableManager(_$DatabaseService db, $SongsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> key = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> duration = const Value.absent(),
            Value<int> daysAgo = const Value.absent(),
            Value<int> listeningTime = const Value.absent(),
            Value<DateTime> lastListen = const Value.absent(),
            Value<int> nbOfListens = const Value.absent(),
            Value<double> score = const Value.absent(),
          }) =>
              SongsCompanion(
            id: id,
            key: key,
            title: title,
            duration: duration,
            daysAgo: daysAgo,
            listeningTime: listeningTime,
            lastListen: lastListen,
            nbOfListens: nbOfListens,
            score: score,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int key,
            required String title,
            required int duration,
            required int daysAgo,
            required int listeningTime,
            required DateTime lastListen,
            Value<int> nbOfListens = const Value.absent(),
            Value<double> score = const Value.absent(),
          }) =>
              SongsCompanion.insert(
            id: id,
            key: key,
            title: title,
            duration: duration,
            daysAgo: daysAgo,
            listeningTime: listeningTime,
            lastListen: lastListen,
            nbOfListens: nbOfListens,
            score: score,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SongsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseService,
    $SongsTable,
    Song,
    $$SongsTableFilterComposer,
    $$SongsTableOrderingComposer,
    $$SongsTableAnnotationComposer,
    $$SongsTableCreateCompanionBuilder,
    $$SongsTableUpdateCompanionBuilder,
    (Song, BaseReferences<_$DatabaseService, $SongsTable, Song>),
    Song,
    PrefetchHooks Function()>;

class $DatabaseServiceManager {
  final _$DatabaseService _db;
  $DatabaseServiceManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
}
