import 'package:flutter/material.dart';

class ThemeModel with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get currentTheme => _themeMode;

  void toggleTheme() {
    _themeMode =
    (_themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;

    notifyListeners();
  }
}