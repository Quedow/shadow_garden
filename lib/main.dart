import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadow_garden/database/database_service.dart';
import 'package:shadow_garden/database/migration.dart';
import 'package:shadow_garden/providers/settings_service.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/screens/home_screen.dart';
import 'package:shadow_garden/utils/styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.quedow.shadow_garden.channel.audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );
  await SettingsService().init();
  final Isar isar = await DatabaseService().init();
  await performMigrationIfNeeded(isar);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AudioProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeColors.themeData,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
