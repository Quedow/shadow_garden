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

  Future<void> setLastIndex(int? index) async {
    if (index == null) return;
    await _preferences!.setInt('lastIndex', index);
  }

  int getLastIndex() {
    return _preferences!.getInt('lastIndex') ?? 0;
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

  Future<void> setWeights(List<double> weights) async {
    List<String> data = weights.map((weight) => weight.toString()).toList();
    await _preferences!.setStringList('weights', data);
  }

  List<double> getWeights() {
    final List<String>? data = _preferences!.getStringList('weights');
    if (data == null) return [0.25, 0.25, 0.25, 0.25];
    return data.map(double.parse).toList();
  }

  Future<void> setWhiteList(List<String> whitelist) async {
    await _preferences!.setStringList('whitelist', whitelist);
  }

  List<String> getWhiteList() {
    return _preferences!.getStringList('whitelist') ?? ['/storage/emulated/0/Music'];
  }

  Future<void> setGlobalStats(int nbListensDB, int listeningTimeDB) async {
    final List<String> globalStats = getGlobalStats();
    final int nbListens = int.parse(globalStats[0]) + nbListensDB;
    final int listeningTime = int.parse(globalStats[1]) + listeningTimeDB;
    await _preferences!.setStringList('globalStats', [nbListens.toString(), listeningTime.toString()]);
  }

  List<String> getGlobalStats() {
    return _preferences!.getStringList('globalStats') ?? ['0', '0'];
  }

  Future<void> clearGlobalStats() async {
    await _preferences!.remove('globalStats');
  }

  Future<void> clearSettings() async {
    final List<String> globalStatTemp = getGlobalStats();
    await _preferences!.clear();
    await _preferences!.setStringList('globalStats', globalStatTemp);
  }
}