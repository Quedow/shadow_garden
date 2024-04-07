import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadow_garden/model/song.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/screens/home_screen.dart';
import 'package:shadow_garden/style/style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.quedow.shadow_garden.channel.audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true
  );
  await SettingsService().init();
  await DatabaseService().init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AudioProvider(),
      child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: ThemeColors.primaryColor.withOpacity(0.2),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(ThemeColors.accentColor),
        )
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false
    );
  }
}
