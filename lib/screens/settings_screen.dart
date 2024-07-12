import 'package:flutter/material.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/style/common_text.dart';
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
        settingToggle(Texts.textNeverListenFirst, Texts.textNeverListenFirstContent, widget.audioProvider.neverListenedFirst, _setNeverListenedFirst),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
        settingNumberInput(Texts.textSortWeight, Texts.textSortWeightContent, _db.pRWeight, _setPercentileRankWeight, Texts.textListenNbWeight, Texts.textListenRateWeight),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
        settingIconButton(Texts.textDeletePrefs, Texts.textDeletePrefsContent, Icons.delete_rounded, _settings.clearSettings),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
        settingIconButton(Texts.textDeleteData, Texts.textDeleteDataContent, Icons.delete_rounded, widget.audioProvider.clearDatabase),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
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
          Text(label, style: Styles.subtitleMedium.copyWith(color: ThemeColors.primaryColor)),
          Text(description, style: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor07)),
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
                Text(leftLabel, style: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor07)),
                Text(rightLabel, style: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor07)),
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
              Text(label, style: Styles.subtitleMedium.copyWith(color: ThemeColors.primaryColor)),
              Text(description, style: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor07)),
            ],
          ),
          IconButton(onPressed: onPressed, icon: Icon(icon, color: ThemeColors.primaryColor), highlightColor: ThemeColors.primaryColor02),
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
              Text(label, style: Styles.subtitleMedium.copyWith(color: ThemeColors.primaryColor)),
              Text(description, style: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor07)),
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