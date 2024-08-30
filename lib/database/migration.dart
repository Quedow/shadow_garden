import 'package:isar/isar.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/settings_service.dart';

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
    case 3:
      await migrateV3ToV4(isar);
      return;
    case 4:
      // Si la version est déjà à 4, il n'est pas nécessaire de migrer.
      return;
    default:
      throw Exception('Unknown version: $currentVersion');
  }

  // Mise à jour de la version
  await settings.setVersion(4);
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

Future<void> migrateV3ToV4(Isar isar) async {
  final int songCount = await isar.songs.count();

  for (int i = 0; i < songCount; i += 50) {
    final List<Song> songs = await isar.songs.where().offset(i).limit(50).findAll();
    await isar.writeTxn(() async {
      for (Song song in songs) {
        song.smartScore = song.score;
      }
      await isar.songs.putAll(songs);
    });
  }
}