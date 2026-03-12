import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDark') ?? false;
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = !isDarkMode.value;
    await prefs.setBool('isDark', isDarkMode.value);
  }

  static Color get scaffoldColor =>
      isDarkMode.value ? const Color(0xFF121212) : Colors.white;
  static Color get mainTextColor =>
      isDarkMode.value ? Colors.white : Colors.black;
  static Color get cardColor =>
      isDarkMode.value ? const Color(0xFF1E1E1E) : Colors.white;
  static Color get secondaryTextColor =>
      isDarkMode.value ? Colors.white70 : Colors.grey;
  static Color get appBarColor =>
      isDarkMode.value ? const Color(0xFF121212) : Colors.white;
}
