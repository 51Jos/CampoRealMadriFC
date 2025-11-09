import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para almacenamiento local usando SharedPreferences
class StorageService {
  final SharedPreferences _preferences;

  StorageService(this._preferences);

  // String
  Future<bool> setString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  String? getString(String key) {
    return _preferences.getString(key);
  }

  // Int
  Future<bool> setInt(String key, int value) async {
    return await _preferences.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  // Bool
  Future<bool> setBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  // Double
  Future<bool> setDouble(String key, double value) async {
    return await _preferences.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  // List<String>
  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _preferences.getStringList(key);
  }

  // Remove
  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  // Clear all
  Future<bool> clear() async {
    return await _preferences.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }
}
