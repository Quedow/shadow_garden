import 'package:flutter/material.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/style/style.dart';

class SettingsScreen extends StatefulWidget {
  final AudioProvider audioProvider;

  const SettingsScreen({Key? key, required this.audioProvider}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();

  @override
  Widget build(BuildContext context) {    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        settingIconButton("Delete preferences", "Preference settings such as loop mode, \nsort mode or number of song per loop will \nbe reset default values.", Icons.delete_rounded, _settings.clearSettings),
        Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor.withOpacity(0.5)),
        settingIconButton("Delete data", "Listening data will be delete to reset\nsmart sort.", Icons.delete_rounded, widget.audioProvider.clearDatabase),
        Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor.withOpacity(0.5)),
      ],
    );
  }
  
  Padding settingIconButton(String label, String description, IconData icon, void Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Styles.settingsTitle),
              Text(description, style: Styles.settingsDescription)
            ],
          ),
          IconButton(onPressed: onPressed, icon: Icon(icon, color: ThemeColors.primaryColor), highlightColor: ThemeColors.primaryColor.withOpacity(0.2)),
        ]
      ),
    );
  }
}