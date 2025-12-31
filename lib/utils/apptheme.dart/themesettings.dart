import 'package:flutter/material.dart';

class ThemeSettings {
  // The toggle state
  static final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  static Color get scaffoldColor =>
      isDarkMode.value ? const Color(0xFF121212) : Colors.white;
  static Color get mainTextColor =>
      isDarkMode.value ? Colors.white : Colors.black;
  static Color get cardColor =>
      isDarkMode.value ? const Color(0xFF1E1E1E) : Colors.white;
  static Color get secondaryTextColor =>
      isDarkMode.value ? Colors.white70 : Colors.grey;
  static Color get inputFieldColor =>
      isDarkMode.value ? const Color(0xFF2C2C2C) : Colors.grey.shade200;
  static Color get appBarColor =>
      isDarkMode.value ? const Color(0xFF121212) : Colors.white;
}
