import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shadow_garden/database/database_service.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:shadow_garden/providers/settings_service.dart';
import 'package:shadow_garden/utils/common_text.dart';
import 'package:shadow_garden/widgets/overlays.dart';
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
        SettingToggleTile(
          label: Texts.textNeverListenFirst,
          description: Texts.textNeverListenFirstContent,
          value :_audioProvider.neverListenedFirst, 
          onChanged: _setNeverListenedFirst,
        ),
        SettingSliderTile(
          label: Texts.textSortWeight,
          description: Texts.textSortWeightContent,
          value: _db.smartWeight,
          onChanged: _setSmartWeight,
          leftLabel: Texts.textSmartWeight,
          rightLabel: Texts.textDumbWeight,
        ),
        SettingIconButtonTile(
          label: Texts.textWhitelist,
          description: Texts.textWhitelistContent,
          icon: Icons.folder_rounded,
          onPressed: _pickFolder,
        ),
        SettingListView(items: _whitelist, onPressed: _removeFolder),
        SettingIconButtonTile(
          label: Texts.textDeletePrefs,
          description: Texts.textDeletePrefsContent,
          icon: Icons.delete_rounded,
          onPressed: () => Dialogs.deletionDialog(context, _clearSettings),
        ),
        SettingIconButtonTile(
          label: Texts.textDeleteData,
          description: Texts.textDeleteDataContent,
          icon: Icons.delete_rounded,
          onPressed: () => Dialogs.deletionDialog(context, _clearDatabase),
        ),
        SettingIconButtonTile(
          label: Texts.textDeleteGlobalStats,
          description: Texts.textDeleteGlobalStatsContent,
          icon: Icons.delete_rounded,
          onPressed: () => Dialogs.deletionDialog(context, _settings.clearGlobalStats),
        ),
        SettingIconButtonTile(
          label: Texts.textImport,
          description: Texts.textImportContent,
          icon: Icons.download_rounded,
          onPressed: _importData,
        ),
        SettingIconButtonTile(
          label: Texts.textExport,
          description: Texts.textExportContent,
          icon: Icons.upload_rounded,
          onPressed: _exportData,
        ),
      ],
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

  Future<void> _importData() async {
    final String? path = (await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
    ))?.paths.first;
    if (path == null) return;
    final String result = await _db.importData(path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      Snack.floating(context, result, 2000),
    );
  }

  Future<void> _exportData() async {
    final String? path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;
    final String result = await _db.exportData(path);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      Snack.floating(context, result, 2000),
    );
  }
}