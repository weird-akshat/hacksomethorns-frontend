// Enhanced ThemeProvider with your configuration
import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/time_tracking_logging/configuration.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true; // Default to dark mode

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  // Helper methods to get current theme colors
  Color get scaffoldColor =>
      _isDarkMode ? scaffoldColorDark : scaffoldColorLight;
  Color get cardColor =>
      _isDarkMode ? timeEntryWidgetColorDark : timeEntryWidgetColorLight;
  Color get textColor => _isDarkMode
      ? timeEntryWidgetTextColorDark
      : timeEntryWidgetTextColorLight;
  Color get borderColor => _isDarkMode
      ? timeEntryWidgetBorderColorDark
      : timeEntryWidgetBorderColorLight;
  Color get primaryAccent =>
      _isDarkMode ? primaryAccentColorDark : primaryAccentColorLight;
  Color get secondaryAccent =>
      _isDarkMode ? secondaryAccentColorDark : secondaryAccentColorLight;
  Color get subtleAccent =>
      _isDarkMode ? subtleAccentColorDark : subtleAccentColorLight;
}
