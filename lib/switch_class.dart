// switch_class.dart dosyası
import 'package:shared_preferences/shared_preferences.dart';

class SwitchPreferences {
  static const String albumKey = 'albumSwitch';
  static const String dateKey = 'dateSwitch';
  static const String writerKey = 'writerSwitch';
  static const String videoButtonKey = 'videoButtonSwitch';
  static const String historyButtonKey = 'historyButtonSwitch';
  static const String ircButtonKey = 'ircButtonSwitch';
  static const String timerButtonKey = 'timerButtonSwitch';

  static Future<void> setSwitchValue(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getSwitchValue(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }
}
