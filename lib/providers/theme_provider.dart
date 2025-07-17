import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:inhabit_realties/utils/color_utils.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _primaryColorKey = 'app_primary_color';
  static const String _accentColorKey = 'app_accent_color';
  static const String _fontSizeKey = 'app_font_size';

  String _currentTheme = 'light';
  String _primaryColor = '#2196F3';
  String _accentColor = '#FF4081';
  String _fontSize = '1.0';

  // Getters
  String get currentTheme => _currentTheme;
  String get primaryColor => _primaryColor;
  String get accentColor => _accentColor;
  String get fontSize => _fontSize;

  // Theme data
  ThemeData get lightTheme {
    final primaryColor = _parseColor(_primaryColor);
    final accentColor = _parseColor(_accentColor);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      textTheme: _getTextTheme(),
      appBarTheme: ColorUtils.getAppBarTheme(primaryColor, false),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ColorUtils.getSafeButtonStyle(primaryColor, false),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: ColorUtils.getContrastingColor(primaryColor),
      ),
      iconTheme: IconThemeData(
        color: Colors.black87,
      ),
    );
  }

  ThemeData get darkTheme {
    final primaryColor = _parseColor(_primaryColor);
    final accentColor = _parseColor(_accentColor);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: const Color(0xFF2D2D2D),
        onSurface: Colors.white,
      ),
      textTheme: _getTextTheme(),
      appBarTheme: ColorUtils.getAppBarTheme(primaryColor, true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ColorUtils.getSafeButtonStyle(primaryColor, true),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: ColorUtils.getContrastingColor(primaryColor),
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

  // Update primary color
  Future<void> updatePrimaryColor(String color) async {
    _primaryColor = color;
    await _saveThemeSettings();
    notifyListeners();
  }

  // Update accent color
  Future<void> updateAccentColor(String color) async {
    _accentColor = color;
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
      _primaryColor = prefs.getString(_primaryColorKey) ?? '#2196F3';
      _accentColor = prefs.getString(_accentColorKey) ?? '#FF4081';
      _fontSize = prefs.getString(_fontSizeKey) ?? '1.0';
    } catch (e) {
      // Use default values if there's an error
      _currentTheme = 'light';
      _primaryColor = '#2196F3';
      _accentColor = '#FF4081';
      _fontSize = '1.0';
    }
  }

  // Save theme settings to SharedPreferences
  Future<void> _saveThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _currentTheme);
      await prefs.setString(_primaryColorKey, _primaryColor);
      await prefs.setString(_accentColorKey, _accentColor);
      await prefs.setString(_fontSizeKey, _fontSize);
    } catch (e) {
      // Handle error silently
    }
  }

  // Parse color string to Color
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
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
