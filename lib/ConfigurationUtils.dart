import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationUtils {

  static void saveConstant(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String> loadConstant(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }
}