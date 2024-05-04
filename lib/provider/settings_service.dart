import 'package:shadow_garden/widgets/controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  static SharedPreferences? _preferences;

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  init() async {
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

  // Future<void> setLastSongId(int id) async {
  //   await _preferences!.setInt('lastSongId', id);
  // }

  // int getLastSongId() {
  //   return _preferences!.getInt('lastSongId') ?? 0;
  // }

  Future<void> clearSettings() async {
    await _preferences!.clear();
  }
}