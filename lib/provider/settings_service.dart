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
    return CLoopMode.values[_preferences!.getInt('cLoopMode') ?? 0];
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
}