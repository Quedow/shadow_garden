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

  Future<void> setWhiteList(List<String> whitelist) async {
    await _preferences!.setStringList('whitelist', whitelist);
  }

  List<String> getWhiteList() {
    return _preferences!.getStringList('whitelist') ?? ['/storage/emulated/0/Music'];
  }

  Future<void> setGlobalStats(int nbListensDB, int listeningTimeDB) async {
    List<String> globalStats = getGlobalStats();
    int nbListens = int.parse(globalStats[0]) + nbListensDB;
    int listeningTime = int.parse(globalStats[1]) + listeningTimeDB;
    await _preferences!.setStringList('globalStats', [nbListens.toString(), listeningTime.toString()]);
  }

  List<String> getGlobalStats() {
    return _preferences!.getStringList('globalStats') ?? ['0', '0'];
  }

  Future<void> clearGlobalStats() async {
    await _preferences!.remove('globalStats');
  }

  Future<void> setVersion(int version) async {
    await _preferences!.setInt('version', version);
  }

  int getVersion() {
    return _preferences!.getInt('version') ?? 4;
  }

  Future<void> clearSettings() async {
    String monitoringDateTemp = getMonitoringDate();
    List<String> globalStatTemp = getGlobalStats();
    await _preferences!.clear();
    await setMonitoringDate(monitoringDateTemp);
    await _preferences!.setStringList('globalStats', globalStatTemp);
  }
}