import 'package:flutter/material.dart';
import '../../models/settings/UserSettingsModel.dart';
import '../../services/settings/UserSettingsService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserSettingsController extends ChangeNotifier {
  final UserSettingsService _settingsService = UserSettingsService();

  UserSettingsModel? _userSettings;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserSettingsModel? get userSettings => _userSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSettings => _userSettings != null;

  // Notification Settings
  NotificationSettings get notificationSettings =>
      _userSettings?.notificationSettings ?? NotificationSettings();

  // Display Settings
  DisplaySettings get displaySettings =>
      _userSettings?.displaySettings ?? DisplaySettings();

  // Privacy Settings
  PrivacySettings get privacySettings =>
      _userSettings?.privacySettings ?? PrivacySettings();

  // Report Settings
  ReportSettings get reportSettings =>
      _userSettings?.reportSettings ?? ReportSettings();

  // Theme Settings
  ThemeSettings get themeSettings =>
      _userSettings?.themeSettings ?? ThemeSettings();

  // Load user settings
  Future<void> loadUserSettings(String userId) async {

    _setLoading(true);
    _clearError();

    try {
      _userSettings = await _settingsService.getUserSettings(userId);

      if (_userSettings == null) {
        // Create default settings if none exist
        _userSettings = await _settingsService.createUserSettings(userId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    if (_userSettings == null) return;

    _setLoading(true);
    _clearError();

    try {
      _userSettings = await _settingsService.updateNotificationSettings(
          _userSettings!.userId, settings);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update notification settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update display settings
  Future<void> updateDisplaySettings(DisplaySettings settings) async {
    if (_userSettings == null) return;

    _setLoading(true);
    _clearError();

    try {
      _userSettings = await _settingsService.updateDisplaySettings(
          _userSettings!.userId, settings);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update display settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update privacy settings
  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    if (_userSettings == null) return;

    _setLoading(true);
    _clearError();

    try {
      _userSettings = await _settingsService.updatePrivacySettings(
          _userSettings!.userId, settings);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update privacy settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update report settings
  Future<void> updateReportSettings(ReportSettings settings) async {
    if (_userSettings == null) return;

    _setLoading(true);
    _clearError();

    try {
      _userSettings = await _settingsService.updateReportSettings(
          _userSettings!.userId, settings);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update report settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update theme settings
  Future<void> updateThemeSettings(ThemeSettings settings) async {
    if (_userSettings == null) return;

    _setLoading(true);
    _clearError();

    try {
      _userSettings = await _settingsService.updateThemeSettings(
          _userSettings!.userId, settings);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update theme settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update all settings at once
  Future<void> updateAllSettings(UserSettingsModel settings) async {
    if (_userSettings == null) return;

    _setLoading(true);
    _clearError();

    try {
      _userSettings = await _settingsService.updateUserSettings(
          _userSettings!.userId, settings);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save all settings
  Future<void> saveAllSettings() async {
    if (_userSettings == null) return;

    _setLoading(true);
    _clearError();

    try {
      // Save to backend
      await _settingsService.updateUserSettings(
          _userSettings!.userId, _userSettings!);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_settings_${_userSettings!.userId}',
          json.encode(_userSettings!.toJson()));

      notifyListeners();
    } catch (e) {
      _setError('Failed to save settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reset settings to default
  Future<void> resetToDefault(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _userSettings = await _settingsService.createUserSettings(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete user settings
  Future<void> deleteUserSettings(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _settingsService.deleteUserSettings(userId);
      if (success) {
        _userSettings = null;
        notifyListeners();
      } else {
        _setError('Failed to delete settings');
      }
    } catch (e) {
      _setError('Failed to delete settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Utility methods for quick access to common settings
  bool get isPushNotificationsEnabled => notificationSettings.pushNotifications;
  bool get isEmailNotificationsEnabled =>
      notificationSettings.emailNotifications;
  String get currentLanguage => displaySettings.language;
  String get currentCurrency => displaySettings.currency;
  String get currentThemeMode => themeSettings.themeMode;
  bool get isDarkMode => themeSettings.themeMode == 'dark';
  bool get isLightMode => themeSettings.themeMode == 'light';
  bool get isAutoTheme => themeSettings.themeMode == 'auto';
}
