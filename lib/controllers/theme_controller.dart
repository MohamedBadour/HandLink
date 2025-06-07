import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'app_theme_mode';

  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  ThemeMode get themeMode => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      _isDarkMode.value = isDark;
    } catch (e) {
      _isDarkMode.value = false;
    }
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode.value = !_isDarkMode.value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode.value);

      // Update the app theme
      Get.changeThemeMode(themeMode);
    } catch (e) {
      // Handle error
      print('Error saving theme: $e');
    }
  }

  Future<void> setTheme(bool isDark) async {
    try {
      _isDarkMode.value = isDark;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);

      // Update the app theme
      Get.changeThemeMode(themeMode);
    } catch (e) {
      print('Error setting theme: $e');
    }
  }
}