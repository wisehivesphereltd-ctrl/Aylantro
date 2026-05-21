import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to Auto-Detect phone mode
  bool _isAdminOverridden = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemePreference();
    _fetchAdminThemeConfig();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString('theme_mode');
      if (modeStr != null && !_isAdminOverridden) {
        if (modeStr == 'light') _themeMode = ThemeMode.light;
        else if (modeStr == 'dark') _themeMode = ThemeMode.dark;
        else _themeMode = ThemeMode.system;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      String modeStr = 'system';
      if (mode == ThemeMode.light) modeStr = 'light';
      else if (mode == ThemeMode.dark) modeStr = 'dark';
      await prefs.setString('theme_mode', modeStr);
    } catch (_) {}
  }

  void toggleTheme(bool isOn) {
    setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
  }

  // Cloud-Driven Admin Theme Control
  Future<void> _fetchAdminThemeConfig() async {
    try {
      final url = Uri.parse('https://aylanpro.wisehivesphere.com/api/settings/theme');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final globalTheme = data['globalTheme']; // 'light', 'dark', 'system', or null
        if (globalTheme == 'light') {
          _themeMode = ThemeMode.light;
          _isAdminOverridden = true;
          notifyListeners();
        } else if (globalTheme == 'dark') {
          _themeMode = ThemeMode.dark;
          _isAdminOverridden = true;
          notifyListeners();
        } else if (globalTheme == 'system') {
          _themeMode = ThemeMode.system;
          _isAdminOverridden = true;
          notifyListeners();
        }
      }
    } catch (_) {
      // Fallback to local preference if offline or admin config not reachable
    }
  }
}
