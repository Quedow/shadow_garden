import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/style/common_text.dart';
import 'package:shadow_garden/style/style.dart';
import 'package:shadow_garden/widgets/alerts.dart';

class SettingsScreen extends StatefulWidget {
  final AudioProvider audioProvider;

  const SettingsScreen({super.key, required this.audioProvider});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  final DatabaseService _db = DatabaseService();
  late List<String> _whitelist;

  @override
  void initState() {
    super.initState();
    _whitelist = _settings.getWhiteList();
  }

  @override
  Widget build(BuildContext context) {    
    return ListView(
      children: [
        _settingToggle(Texts.textNeverListenFirst, Texts.textNeverListenFirstContent, widget.audioProvider.neverListenedFirst, _setNeverListenedFirst),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
        _settingSlider(Texts.textSortWeight, Texts.textSortWeightContent, _db.smartWeight, _setSmartWeight, Texts.textSmartWeight, Texts.textDumbWeight),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
        _settingIconButton(Texts.textWhitelist, Texts.textWhitelistContent, Icons.folder_rounded, _pickFolder),
        _settingListView(_whitelist, _removeFolder),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
        _settingIconButton(Texts.textDeletePrefs, Texts.textDeletePrefsContent, Icons.delete_rounded, () => Alerts.deletionDialog(context, _clearSettings)),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
        _settingIconButton(Texts.textDeleteData, Texts.textDeleteDataContent, Icons.delete_rounded, () => Alerts.deletionDialog(context, _clearDatabase)),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
        _settingIconButton(Texts.textDeleteGlobalStats, Texts.textDeleteGlobalStatsContent, Icons.delete_rounded, () => Alerts.deletionDialog(context, _settings.clearGlobalStats)),
        const Divider(height: 1, thickness: 1, color: ThemeColors.primaryColor04),
      ],
    );
  }

  ListTile _settingToggle(String label, String description, bool value, void Function(bool)? onChanged) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      title: Text(label, style: Styles.subtitleMedium.copyWith(color: ThemeColors.primaryColor)),
      subtitle: Text(description, style: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor07)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: ThemeColors.darkAccentColor,
        activeColor: ThemeColors.primaryColor,
      ),
    );
  }

  Padding _settingSlider(String label, String description, double value, void Function(double)? onChanged, [String? leftLabel, String? rightLabel]) {
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
            max: 1.0, divisions: 20, label: (value * 100).round().toString(),
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
  
  ListTile _settingIconButton(String label, String description, IconData icon, void Function() onPressed) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      title: Text(label, style: Styles.subtitleMedium.copyWith(color: ThemeColors.primaryColor)),
      subtitle: Text(description, style: Styles.labelLarge.copyWith(color: ThemeColors.primaryColor07)),
      trailing: IconButton(onPressed: onPressed, icon: Icon(icon, color: ThemeColors.primaryColor), highlightColor: ThemeColors.primaryColor02),
    );
  }

  SizedBox _settingListView(List<String> content, void Function(int index) onPressed) {
    return SizedBox(
      height: content.length * 50,
      child: ListView.builder(
        itemCount: content.length,
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            textColor: ThemeColors.primaryColor07,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            title: Text(content[index], style: Styles.labelLarge),
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, color: ThemeColors.primaryColor04), highlightColor: ThemeColors.primaryColor02, 
              onPressed: () => onPressed(index),
            ),
          );
        },
      ),
    );
  }

  void _setSmartWeight(double value) {
    setState(() {
      _db.setSmartWeight(value);
    });
  }

  void _setNeverListenedFirst(bool value) {
    setState(() {
      widget.audioProvider.setNeverListenedFirst(value);
    });
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() => _whitelist.add(selectedDirectory));
      await _settings.setWhiteList(_whitelist);
    }
  }

  Future<void> _removeFolder(int index) async {
    setState(() => _whitelist.removeAt(index));
    await _settings.setWhiteList(_whitelist);
  }

  void _clearSettings() async {
    await _settings.clearSettings();
    widget.audioProvider.getSettings();
    _whitelist = _settings.getWhiteList();
    _db.setSmartWeight(_settings.getSmartWeight());
    setState(() {});
  }

  void _clearDatabase() async {
    await _db.clearDatabase();
    await _settings.setMonitoringDate();
  }
}