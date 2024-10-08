import 'package:isar/isar.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/utils/functions.dart';

Future<void> performMigrationIfNeeded(Isar isar) async {
  final SettingsService settings = SettingsService();
  final int currentVersion = settings.getVersion();
  settings.getMonitoringDate();
  switch(currentVersion) {
    case 1:
      await migrateV1ToV2(isar);
      break;
    case 2:
      await migrateV2ToV3(isar);
      return;
    case 4:
      await migrateV4ToV5(isar, settings.getWhiteList());
      return;
    case 5:
      // Si la version est déjà à 5, il n'est pas nécessaire de migrer.
      return;
    default:
      throw Exception('Unknown version: $currentVersion');
  }

  // Mise à jour de la version
  await settings.setVersion(5);
}

Future<void> migrateV1ToV2(Isar isar) async {
  final int songCount = await isar.songs.count();

  // Nous paginons à travers les musiques pour éviter de tous les charger en mémoire en même temps
  for (int i = 0; i < songCount; i += 50) {
    final List<Song> songs = await isar.songs.where().offset(i).limit(50).findAll();
    final DateTime now = DateTime.now();
    await isar.writeTxn(() async {
      for (Song song in songs) {
        song.lastListen = now;
      }
      await isar.songs.putAll(songs);
    });
  }
}

Future<void> migrateV2ToV3(Isar isar) async {
  final int songCount = await isar.songs.count();

  for (int i = 0; i < songCount; i += 50) {
    final List<Song> songs = await isar.songs.where().offset(i).limit(50).findAll();
    await isar.writeTxn(() async {
      for (Song song in songs) {
        song.daysAgo = 30;
      }
      await isar.songs.putAll(songs);
    });
  }
}

Future<void> migrateV4ToV5(Isar isar, List<String> paths) async {
  final int songCount = await isar.songs.count();

  final OnAudioQuery audioQuery = OnAudioQuery();
  bool hasPermission = await audioQuery.permissionsStatus();
  if (!hasPermission) {
    await audioQuery.permissionsRequest();
  }

  final Map<int, int> idToKey = {};
  for (String path in paths) {
    List<SongModel> songs = await audioQuery.querySongs(
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: SongSortType.TITLE,
      ignoreCase: true,
      path: path,
    );

    for (SongModel song in songs) {
      idToKey[song.id] = Functions.fastHash(song.album, song.title, song.artist);
    }
  }

  for (int i = 0; i < songCount; i += 50) {
    final List<Song> songs = await isar.songs.where().offset(i).limit(50).findAll();
    await isar.writeTxn(() async {
      for (Song song in songs) {
        song.key = idToKey[song.songId] ?? -1;
      }
      await isar.songs.putAll(songs);
    });
  }
}