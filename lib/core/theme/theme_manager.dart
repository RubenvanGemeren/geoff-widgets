import 'package:flutter/material.dart';
import 'themes/default_theme.dart';
import 'themes/dark_theme.dart';
import 'themes/light_theme.dart';
import 'themes/ambient_theme.dart';

class ThemeManager extends ChangeNotifier {
  static const String _defaultTheme = 'default';
  static const String _darkTheme = 'dark';
  static const String _lightTheme = 'light';
  static const String _ambientTheme = 'ambient';

  String _currentThemeName = _defaultTheme;

  String get currentThemeName => _currentThemeName;

  ThemeData get currentTheme {
    switch (_currentThemeName) {
      case _darkTheme:
        return DarkTheme.theme;
      case _lightTheme:
        return LightTheme.theme;
      case _ambientTheme:
        return AmbientTheme.theme;
      default:
        return DefaultTheme.theme;
    }
  }

  List<String> get availableThemes => [
    _defaultTheme,
    _darkTheme,
    _lightTheme,
    _ambientTheme,
  ];

  void setTheme(String themeName) {
    if (availableThemes.contains(themeName)) {
      _currentThemeName = themeName;
      notifyListeners();
    }
  }

  void cycleTheme() {
    final currentIndex = availableThemes.indexOf(_currentThemeName);
    final nextIndex = (currentIndex + 1) % availableThemes.length;
    setTheme(availableThemes[nextIndex]);
  }
}
