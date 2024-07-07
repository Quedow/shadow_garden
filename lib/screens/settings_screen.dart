import 'package:flutter/material.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/style/style.dart';

class SettingsScreen extends StatefulWidget {
  final AudioProvider audioProvider;

  const SettingsScreen({super.key, required this.audioProvider});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        settingToggle('Smart sort', 'Put musics never listened at the beginning.', widget.audioProvider.neverListenedFirst, _setNeverListenedFirst),
        Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor.withOpacity(0.5)),
        settingNumberInput('Smart sort weight', 'Choose the importance of the number of listens compared to the listening rate for Smart sorting.', _db.pRWeight, _setPercentileRankWeight, 'Number of listens', 'Listening rate'),
        Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor.withOpacity(0.5)),
        settingIconButton('Delete preferences', 'Preference settings such as loop mode, \nsort mode or number of song per loop will \nbe reset default values.', Icons.delete_rounded, _settings.clearSettings),
        Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor.withOpacity(0.5)),
        settingIconButton('Delete data', 'Listening data will be delete to reset\nsmart sort.', Icons.delete_rounded, widget.audioProvider.clearDatabase),
        Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor.withOpacity(0.5)),
      ],
    );
  }

  Padding settingNumberInput(String label, String description, double value, void Function(double)? onChanged, [String? leftLabel, String? rightLabel]) {
    double maxWeight = DatabaseService.mainWeight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Styles.settingsTitle),
          Text(description, style: Styles.settingsDescription),
          Slider(
            value: value,
            activeColor: ThemeColors.darkAccentColor,
            max: maxWeight, divisions: (maxWeight / 0.05).round(), label: ((value * 100) / maxWeight).round().toString(),
            onChanged: onChanged,
          ),
          if (leftLabel != null && rightLabel != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(leftLabel, style: Styles.settingsDescription),
                Text(rightLabel, style: Styles.settingsDescription),
              ],
            ),
        ],
      ),
    );
  }

  void _setPercentileRankWeight(double value) {
    setState(() {
      _db.setPercentileRankWeight(value);
    });
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
              Text(description, style: Styles.settingsDescription),
            ],
          ),
          IconButton(onPressed: onPressed, icon: Icon(icon, color: ThemeColors.primaryColor), highlightColor: ThemeColors.primaryColor.withOpacity(0.2)),
        ],
      ),
    );
  }
  
  Padding settingToggle(String label, String description, bool value, void Function(bool)? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Styles.settingsTitle),
              Text(description, style: Styles.settingsDescription),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: ThemeColors.darkAccentColor,
            activeColor: ThemeColors.primaryColor,
          ),
        ],
      ),
    );
  }

  void _setNeverListenedFirst(bool value) {
    setState(() {
      widget.audioProvider.setNeverListenedFirst(value);
    });
  }
}