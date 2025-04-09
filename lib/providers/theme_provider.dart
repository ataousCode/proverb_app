import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';

class ThemeProvider extends ChangeNotifier {
  // Key for saving theme preference
  static const String _themePreferenceKey = 'theme_mode';

  // Theme mode (light or dark)
  ThemeMode _themeMode = ThemeMode.light;

  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;

  // Check if dark mode is enabled
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Constructor loads saved theme preference
  ThemeProvider() {
    _loadThemePreference();
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  // Set a specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference();
    notifyListeners();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);

      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }

      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  // Save theme preference
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themePreferenceKey,
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }
}
