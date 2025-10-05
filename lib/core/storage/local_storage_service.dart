import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _themeBoxName = 'theme_settings';
  static const String _userPreferencesBoxName = 'user_preferences';

  late Box _themeBox;
  late Box _userPreferencesBox;

  Future<void> init() async {
    _themeBox = await Hive.openBox(_themeBoxName);
    _userPreferencesBox = await Hive.openBox(_userPreferencesBoxName);
  }

  // Theme Settings
  String getThemeName() {
    return _themeBox.get('current_theme', defaultValue: 'default');
  }

  Future<void> setThemeName(String themeName) async {
    await _themeBox.put('current_theme', themeName);
  }

  // User Preferences
  bool getNotificationsEnabled() {
    return _userPreferencesBox.get('notifications_enabled', defaultValue: true);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _userPreferencesBox.put('notifications_enabled', enabled);
  }

  String getLocation() {
    return _userPreferencesBox.get('location', defaultValue: 'London, UK');
  }

  Future<void> setLocation(String location) async {
    await _userPreferencesBox.put('location', location);
  }

  // Clean up
  Future<void> dispose() async {
    await _themeBox.close();
    await _userPreferencesBox.close();
  }
}