import 'package:flutter/material.dart';
import 'settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsService _settings = SettingsService();
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final darkMode = await _settings.getDarkMode();
    _themeMode = _boolToThemeMode(darkMode);
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _settings.setDarkMode(_themeModeToBool(mode));
    notifyListeners();
  }
  
  ThemeMode _boolToThemeMode(bool? value) {
    if (value == null) return ThemeMode.system;
    return value ? ThemeMode.dark : ThemeMode.light;
  }
  
  bool? _themeModeToBool(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return null;
    }
  }
}
