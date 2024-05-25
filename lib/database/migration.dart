import 'package:isar/isar.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/settings_service.dart';

Future<void> performMigrationIfNeeded(Isar isar) async {
  final SettingsService settings = SettingsService();
  final currentVersion = settings.getVersion();
  switch(currentVersion) {
    case 1:
      await migrateV1ToV2(isar, settings.getNbOfListenWeight());
      break;
    case 2:
      // Si la version est déjà à 2, il n'est pas nécessaire de migrer.
      return;
    default:
      throw Exception('Unknown version: $currentVersion');
  }

  // Mise à jour de la version
  await settings.setVersion(2);
}

Future<void> migrateV1ToV2(Isar isar, double nbOfListenWeight) async {
  final DatabaseService db = DatabaseService();
  if (nbOfListenWeight > DatabaseService.mainWeight) { db.setNbOfListenWeight(DatabaseService.mainWeight); }

  final songCount = await isar.songs.count();

  // Nous paginons à travers les musiques pour éviter de tous les charger en mémoire en même temps
  for (var i = 0; i < songCount; i += 50) {
    final List<Song> songs = await isar.songs.where().offset(i).limit(50).findAll();
    final now = DateTime.now();
    await isar.writeTxn(() async {
      for (var song in songs) {
        song.lastListen = now;
      }
      await isar.songs.putAll(songs);
    });
  }
}
