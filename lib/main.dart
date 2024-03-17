import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadow_garden/screens/home_screen.dart';
import 'package:shadow_garden/style/style.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.quedow.shadow_garden.channel.audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true
  );

  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().init();

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
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(ThemeColors.accentColor),
        )
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false
    );
  }
}
