import 'package:shared_preferences/shared_preferences.dart';

class TutorialLocalDatasource {
  Future<bool> isTutorialSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> setTutorialSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }
}
