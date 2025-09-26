import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadow_garden/database/database_service.dart';
import 'package:shadow_garden/database/migration.dart';
import 'package:shadow_garden/providers/settings_service.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/screens/home_screen.dart';
import 'package:shadow_garden/utils/styles.dart';
import 'package:shadow_garden/utils/translator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.shadow_garden.channel.audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );
  await SettingsService().init();
  await Translator.load();

  DatabaseService db = DatabaseService()..init();
  await performMigrationIfNeeded(db);

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
      theme: Styles.themeData,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
