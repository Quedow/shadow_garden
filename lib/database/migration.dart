import 'package:isar/isar.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/settings_service.dart';

Future<void> performMigrationIfNeeded(Isar isar) async {
  final SettingsService settings = SettingsService();
  final int currentVersion = settings.getVersion();
  switch(currentVersion) {
    case 1:
      await migrateV1ToV2(isar, settings.getPercentileRankWeight());
      break;
    case 2:
      await migrateV2ToV3(isar);
      return;
    case 3:
      // Si la version est déjà à 3, il n'est pas nécessaire de migrer.
      return;
    default:
      throw Exception('Unknown version: $currentVersion');
  }

  // Mise à jour de la version
  await settings.setVersion(3);
}

Future<void> migrateV1ToV2(Isar isar, double percentileRankWeight) async {
  final DatabaseService db = DatabaseService();
  if (percentileRankWeight > DatabaseService.mainWeight) { db.setPercentileRankWeight(DatabaseService.mainWeight); }

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