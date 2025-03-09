import 'package:flutter/material.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:shadow_garden/screens/settings_screen.dart';
import 'package:shadow_garden/utils/common_text.dart';
import 'package:shadow_garden/widgets/custom_app_bar.dart';

class SettingsPage extends StatefulWidget {
  final AudioProvider audioProvider;

  const SettingsPage({super.key, required this.audioProvider});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(appBarType: AppBarType.classic, title: Texts.textSettingsBar, audioProvider: widget.audioProvider),
      body: SettingsScreen(audioProvider: widget.audioProvider),
    );
  }
}