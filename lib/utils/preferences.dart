import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static String? getString(String key) => _instance.getString(key);
  static Future<bool> setString(String key, String value) => _instance.setString(key, value);
  static bool? getBool(String key) => _instance.getBool(key);
  static Future<bool> setBool(String key, bool value) => _instance.setBool(key, value);
  static int? getInt(String key) => _instance.getInt(key);
  static Future<bool> setInt(String key, int value) => _instance.setInt(key, value);
  static double? getDouble(String key) => _instance.getDouble(key);
  static Future<bool> setDouble(String key, double value) => _instance.setDouble(key, value);
  static List<String>? getStringList(String key) => _instance.getStringList(key);
  static Future<bool> setStringList(String key, List<String> value) => _instance.setStringList(key, value);
  static Future<bool> remove(String key) => _instance.remove(key);
  static Future<bool> clear() => _instance.clear();
  static bool containsKey(String key) => _instance.containsKey(key);
}
