import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shadow_garden/database/database_service.dart';
import 'package:shadow_garden/providers/audio_provider.dart';
import 'package:shadow_garden/providers/settings_service.dart';
import 'package:shadow_garden/utils/translator.dart';
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListView(
        children: [
          SettingToggleTile(
            label: 'textNeverListenFirst'.t(),
            description: 'textNeverListenFirstContent'.t(),
            value :_audioProvider.neverListenedFirst, 
            onChanged: _setNeverListenedFirst,
          ),
          SettingSliderTile(
            label: 'textSortWeight'.t(),
            description: 'textSortWeightContent'.t(),
            value: _db.smartWeight,
            onChanged: _setSmartWeight,
            leftLabel: 'textSmartWeight'.t(),
            rightLabel: 'textDumbWeight'.t(),
          ),
          SettingIconButtonTile(
            label: 'textWhitelist'.t(),
            description: 'textWhitelistContent'.t(),
            icon: Icons.folder_rounded,
            onPressed: _pickFolder,
          ),
          SettingListView(items: _whitelist, onPressed: _removeFolder),
          SettingIconButtonTile(
            label: 'textDeletePrefs'.t(),
            description: 'textDeletePrefsContent'.t(),
            icon: Icons.delete_rounded,
            onPressed: () => Dialogs.deletionDialog(context, _clearSettings),
          ),
          SettingIconButtonTile(
            label: 'textDeleteData'.t(),
            description: 'textDeleteDataContent'.t(),
            icon: Icons.delete_rounded,
            onPressed: () => Dialogs.deletionDialog(context, _clearDatabase),
          ),
          SettingIconButtonTile(
            label: 'textDeleteGlobalStats'.t(),
            description: 'textDeleteGlobalStatsContent'.t(),
            icon: Icons.delete_rounded,
            onPressed: () => Dialogs.deletionDialog(context, _settings.clearGlobalStats),
          ),
          SettingIconButtonTile(
            label: 'textImport'.t(),
            description: 'textImportContent'.t(),
            icon: Icons.download_rounded,
            onPressed: _importData,
          ),
          SettingIconButtonTile(
            label: 'textExport'.t(),
            description: 'textExportContent'.t(),
            icon: Icons.upload_rounded,
            onPressed: _exportData,
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(onPressed: _openLicencesPage, child: Text('textAboutBtn'.t())),
          ),
        ],
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

  void _openLicencesPage() {
    final int currentYear = DateTime.now().year;
    showLicensePage(
      context: context,
      applicationName: 'Shadow Garden',
      applicationLegalese:  '© $currentYear Take Up Tech. All rights reserved.',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          child: Image.asset('assets/icons/shadow_garden_icon.png', height: 50),
        ),
      ),
      applicationVersion: '2509.1.9.0'
    );
  }
}