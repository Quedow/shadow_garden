import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shadow_garden/database/song.dart';
import 'package:shadow_garden/pages/statistics_page.dart';
import 'package:shadow_garden/provider/audio_provider.dart';
import 'package:shadow_garden/provider/settings_service.dart';
import 'package:shadow_garden/style/common_text.dart';
import 'package:shadow_garden/widgets/alerts.dart';
import 'package:shadow_garden/widgets/settings_components.dart';

class SettingsScreen extends StatefulWidget {
  final AudioProvider audioProvider;

  const SettingsScreen({super.key, required this.audioProvider});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late final AudioProvider _audioProvider;
  final SettingsService _settings = SettingsService();
  final DatabaseService _db = DatabaseService();
  late List<String> _whitelist;

  @override
  void initState() {
    super.initState();
    _audioProvider = widget.audioProvider;
    _whitelist = _settings.getWhiteList();
  }

  @override
  Widget build(BuildContext context) {    
    return ListView(
      children: [
        SettingButtonTile(label: 'Statistics', icon: Icons.bar_chart_rounded, onPressed: () => _openStatistics(_audioProvider)),
        const Divider(height: 1, thickness: 1),
        SettingToggleTile(
          label: Texts.textNeverListenFirst,
          description: Texts.textNeverListenFirstContent,
          value :_audioProvider.neverListenedFirst, 
          onChanged: _setNeverListenedFirst,
        ),
        const Divider(height: 1, thickness: 1),
        SettingSliderTile(
          label: Texts.textSortWeight,
          description: Texts.textSortWeightContent,
          value: _db.smartWeight,
          onChanged: _setSmartWeight,
          leftLabel: Texts.textSmartWeight,
          rightLabel: Texts.textDumbWeight,
        ),
        const Divider(height: 1, thickness: 1),
        SettingIconButtonTile(
          label: Texts.textWhitelist,
          description: Texts.textWhitelistContent,
          icon: Icons.folder_rounded,
          onPressed: _pickFolder,
        ),
        SettingListView(items: _whitelist, onPressed: _removeFolder),
        const Divider(height: 1, thickness: 1),
        SettingIconButtonTile(
          label: Texts.textDeletePrefs,
          description: Texts.textDeletePrefsContent,
          icon: Icons.delete_rounded,
          onPressed: () => Alerts.deletionDialog(context, _clearSettings),
        ),
        const Divider(height: 1, thickness: 1),
        SettingIconButtonTile(
          label: Texts.textDeleteData,
          description: Texts.textDeleteDataContent,
          icon: Icons.delete_rounded,
          onPressed: () => Alerts.deletionDialog(context, _clearDatabase),
        ),
        const Divider(height: 1, thickness: 1),
        SettingIconButtonTile(
          label: Texts.textDeleteGlobalStats,
          description: Texts.textDeleteGlobalStatsContent,
          icon: Icons.delete_rounded,
          onPressed: () => Alerts.deletionDialog(context, _settings.clearGlobalStats),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }

  void _openStatistics(AudioProvider audioProvider) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsPage(audioProvider: audioProvider)));
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
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

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