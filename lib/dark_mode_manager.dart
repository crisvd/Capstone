import 'package:flutter/material.dart';

class DarkModeManager extends ChangeNotifier {
  bool _darkModeEnabled = false;

  bool get darkModeEnabled => _darkModeEnabled;

  void toggleDarkMode() {
    _darkModeEnabled = !_darkModeEnabled;
    notifyListeners();
  }
}
