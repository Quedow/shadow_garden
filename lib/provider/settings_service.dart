import 'package:intl/intl.dart';
import 'package:shadow_garden/widgets/controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  static SharedPreferences? _preferences;

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> setCLoopMode(CLoopMode cMode) async {
    await _preferences!.setInt('cLoopMode', cMode.index);
  }

  CLoopMode getCLoopMode() {
    return CLoopMode.values[_preferences!.getInt('cLoopMode') ?? 2];
  }

  Future<void> setSongsPerLoop(int value) async {
    await _preferences!.setInt('songsPerLoop', value);
  }

  int getSongsPerLoop() {
    return _preferences!.getInt('songsPerLoop') ?? 2;
  }

  Future<void> setSortState(int state) async {
    await _preferences!.setInt('sortState', state);
  }

  int getSortState() {
    return _preferences!.getInt('sortState') ?? 0;
  }

  Future<void> setNeverListenedFirst(bool value) async {
    await _preferences!.setBool('neverListenedFirst', value);
  }

  bool getNeverListenedFirst() {
    return _preferences!.getBool('neverListenedFirst') ?? false;
  }

  Future<void> setSmartWeight (double value) async {
    await _preferences!.setDouble('smartWeight', value);
  }

  double getSmartWeight() {
    return _preferences!.getDouble('smartWeight') ?? 0.9;
  }

  // Save the last song listened
  // Future<void> setLastSongId(int id) async {
  //   await _preferences!.setInt('lastSongId', id);
  // }

  // int getLastSongId() {
  //   return _preferences!.getInt('lastSongId') ?? 0;
  // }

  Future<void> setVersion(int version) async {
    await _preferences!.setInt('version', version);
  }

  int getVersion() {
    return _preferences!.getInt('version') ?? 4;
  }

  Future<void> setMonitoringDate([String? date]) async {
    await _preferences!.setString('monitoringDate', date ?? DateFormat('MM/dd/yyyy').format(DateTime.now()));
  }

  String getMonitoringDate() {
    String? monitoringDate = _preferences!.getString('monitoringDate');
    if (monitoringDate == null) {
      monitoringDate = DateFormat('MM/dd/yyyy').format(DateTime.now());
      setMonitoringDate(monitoringDate);
    }
    return monitoringDate;
  }

  // Save the last playlist
  // Future<void> setLastPlaylist(List<int> ids) async {
  //   List<String> lastQueue = ids.map((id) => id.toString()).toList();
  //   await _preferences!.setStringList('lastPlaylist', lastQueue);
  // }

  // List<int> getLastPlaylist() {
  //   List<String> lastQueue = _preferences!.getStringList('lastPlaylist') ?? [];
  //   return lastQueue.map((id) => int.parse(id)).toList();
  // }

  Future<void> clearSettings() async {
    String monitoringDateTemp = getMonitoringDate();
    await _preferences!.clear();
    await setMonitoringDate(monitoringDateTemp);
  }
}