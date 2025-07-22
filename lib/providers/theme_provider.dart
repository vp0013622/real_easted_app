import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:inhabit_realties/utils/color_utils.dart';
import 'package:inhabit_realties/constants/contants.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _fontSizeKey = 'app_font_size';

  String _currentTheme = 'light';
  String _fontSize = '1.0';

  // Getters
  String get currentTheme => _currentTheme;
  String get fontSize => _fontSize;

  // Theme data
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.lightPrimary,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSecondary,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      textTheme: _getTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.lightDarkText,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.lightDarkText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightDarkText,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: Colors.black87,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: const Color(0xFF2D2D2D),
        onSurface: Colors.white,
      ),
      textTheme: _getTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkWhiteText,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.darkWhiteText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkWhiteText,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  ThemeData get currentThemeData {
    return _currentTheme == 'dark' ? darkTheme : lightTheme;
  }

  // Initialize theme from settings
  Future<void> initializeTheme() async {
    await _loadThemeSettings();
    notifyListeners();
  }

  // Update theme
  Future<void> updateTheme(String theme) async {
    _currentTheme = theme;
    await _saveThemeSettings();
    notifyListeners();
  }

  // Update font size
  Future<void> updateFontSize(String size) async {
    _fontSize = size;
    await _saveThemeSettings();
    notifyListeners();
  }

  // Load theme settings from SharedPreferences
  Future<void> _loadThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentTheme = prefs.getString(_themeKey) ?? 'light';
      _fontSize = prefs.getString(_fontSizeKey) ?? '1.0';
    } catch (e) {
      // Use default values if there's an error
      _currentTheme = 'light';
      _fontSize = '1.0';
    }
  }

  // Save theme settings to SharedPreferences
  Future<void> _saveThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _currentTheme);
      await prefs.setString(_fontSizeKey, _fontSize);
    } catch (e) {
      // Handle error silently
    }
  }

  // Get text theme with custom font size
  TextTheme _getTextTheme() {
    final fontSizeMultiplier = double.tryParse(_fontSize) ?? 1.0;

    return TextTheme(
      displayLarge: TextStyle(fontSize: 96 * fontSizeMultiplier),
      displayMedium: TextStyle(fontSize: 60 * fontSizeMultiplier),
      displaySmall: TextStyle(fontSize: 48 * fontSizeMultiplier),
      headlineLarge: TextStyle(fontSize: 40 * fontSizeMultiplier),
      headlineMedium: TextStyle(fontSize: 34 * fontSizeMultiplier),
      headlineSmall: TextStyle(fontSize: 24 * fontSizeMultiplier),
      titleLarge: TextStyle(fontSize: 20 * fontSizeMultiplier),
      titleMedium: TextStyle(fontSize: 16 * fontSizeMultiplier),
      titleSmall: TextStyle(fontSize: 14 * fontSizeMultiplier),
      bodyLarge: TextStyle(fontSize: 16 * fontSizeMultiplier),
      bodyMedium: TextStyle(fontSize: 14 * fontSizeMultiplier),
      bodySmall: TextStyle(fontSize: 12 * fontSizeMultiplier),
      labelLarge: TextStyle(fontSize: 14 * fontSizeMultiplier),
      labelMedium: TextStyle(fontSize: 12 * fontSizeMultiplier),
      labelSmall: TextStyle(fontSize: 10 * fontSizeMultiplier),
    );
  }
}
