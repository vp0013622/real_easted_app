import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../interfaces/settings/UserSettingsInterface.dart';
import '../../models/settings/UserSettingsModel.dart';
import '../../constants/apiUrls.dart';

class UserSettingsService implements UserSettingsInterface {
  final String baseUrl = ApiUrls.baseUrl;

  @override
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    print(
        '🔍 [DEBUG] UserSettingsService.getUserSettings called with userId: $userId');

    try {
      // Try to get from local storage first
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('user_settings_$userId');

      if (settingsJson != null) {
        print('🔍 [DEBUG] Found settings in local storage');
        final data = json.decode(settingsJson);
        return UserSettingsModel.fromJson(data);
      }

      // If not in local storage, try backend
      print('🔍 [DEBUG] No local settings, trying backend...');
      print('🔍 [DEBUG] Base URL: $baseUrl');
      print('🔍 [DEBUG] Full URL: $baseUrl/settings/$userId');

      final response = await http.get(
        Uri.parse('$baseUrl/settings/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 [DEBUG] GET response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('🔍 [DEBUG] Successfully got settings from backend');
          return UserSettingsModel.fromJson(data['data']);
        }
      } else if (response.statusCode == 404) {
        print(
            '🔍 [DEBUG] Settings not found in backend (404), will create default');
        return null;
      }

      print('🔍 [DEBUG] Backend not available, using default settings');
      return null;
    } catch (e) {
      print('❌ [DEBUG] Exception in getUserSettings: $e');
      print('🔍 [DEBUG] Using default settings due to error');
      return null;
    }
  }

  @override
  Future<UserSettingsModel> createUserSettings(String userId) async {
    print(
        '🔍 [DEBUG] UserSettingsService.createUserSettings called with userId: $userId');

    try {
      // Create default settings
      final defaultSettings = UserSettingsModel(
        id: '',
        userId: userId,
        notificationSettings: NotificationSettings(),
        displaySettings: DisplaySettings(),
        privacySettings: PrivacySettings(),
        reportSettings: ReportSettings(),
        themeSettings: ThemeSettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'user_settings_$userId', json.encode(defaultSettings.toJson()));
      print('🔍 [DEBUG] Saved default settings to local storage');

      // Try to save to backend (optional)
      try {
        print('🔍 [DEBUG] POST URL: $baseUrl/settings');

        final requestBody = {
          'userId': userId,
          'notificationSettings': defaultSettings.notificationSettings.toJson(),
          'displaySettings': defaultSettings.displaySettings.toJson(),
          'privacySettings': defaultSettings.privacySettings.toJson(),
          'reportSettings': defaultSettings.reportSettings.toJson(),
          'themeSettings': defaultSettings.themeSettings.toJson(),
        };

        final response = await http.post(
          Uri.parse('$baseUrl/settings'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );

        print('🔍 [DEBUG] POST response status: ${response.statusCode}');

        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            print('🔍 [DEBUG] Successfully created settings in backend');
            return UserSettingsModel.fromJson(data['data']);
          }
        }
      } catch (e) {
        print('🔍 [DEBUG] Backend not available, using local storage only: $e');
      }

      return defaultSettings;
    } catch (e) {
      print('❌ [DEBUG] Exception in createUserSettings: $e');
      rethrow;
    }
  }

  @override
  Future<UserSettingsModel> updateUserSettings(
      String userId, UserSettingsModel settings) async {
    try {
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'user_settings_$userId', json.encode(settings.toJson()));
      print('🔍 [DEBUG] Updated settings in local storage');

      // Try to update in backend (optional)
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/settings/$userId'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'notificationSettings': settings.notificationSettings.toJson(),
            'displaySettings': settings.displaySettings.toJson(),
            'privacySettings': settings.privacySettings.toJson(),
            'reportSettings': settings.reportSettings.toJson(),
            'themeSettings': settings.themeSettings.toJson(),
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            print('🔍 [DEBUG] Successfully updated settings in backend');
            return UserSettingsModel.fromJson(data['data']);
          }
        }
      } catch (e) {
        print('🔍 [DEBUG] Backend not available, using local storage only: $e');
      }

      return settings;
    } catch (e) {
      print('❌ [DEBUG] Exception in updateUserSettings: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteUserSettings(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/settings/$userId'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserSettingsModel> updateNotificationSettings(
      String userId, NotificationSettings settings) async {
    try {
      final currentSettings = await getUserSettings(userId);
      if (currentSettings == null) {
        final newSettings = await createUserSettings(userId);
        return await updateUserSettings(
            userId,
            newSettings.copyWith(
              notificationSettings: settings,
            ));
      }

      return await updateUserSettings(
          userId,
          currentSettings.copyWith(
            notificationSettings: settings,
          ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserSettingsModel> updateDisplaySettings(
      String userId, DisplaySettings settings) async {
    try {
      final currentSettings = await getUserSettings(userId);
      if (currentSettings == null) {
        final newSettings = await createUserSettings(userId);
        return await updateUserSettings(
            userId,
            newSettings.copyWith(
              displaySettings: settings,
            ));
      }

      return await updateUserSettings(
          userId,
          currentSettings.copyWith(
            displaySettings: settings,
          ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserSettingsModel> updatePrivacySettings(
      String userId, PrivacySettings settings) async {
    try {
      final currentSettings = await getUserSettings(userId);
      if (currentSettings == null) {
        final newSettings = await createUserSettings(userId);
        return await updateUserSettings(
            userId,
            newSettings.copyWith(
              privacySettings: settings,
            ));
      }

      return await updateUserSettings(
          userId,
          currentSettings.copyWith(
            privacySettings: settings,
          ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserSettingsModel> updateReportSettings(
      String userId, ReportSettings settings) async {
    try {
      final currentSettings = await getUserSettings(userId);
      if (currentSettings == null) {
        final newSettings = await createUserSettings(userId);
        return await updateUserSettings(
            userId,
            newSettings.copyWith(
              reportSettings: settings,
            ));
      }

      return await updateUserSettings(
          userId,
          currentSettings.copyWith(
            reportSettings: settings,
          ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserSettingsModel> updateThemeSettings(
      String userId, ThemeSettings settings) async {
    try {
      final currentSettings = await getUserSettings(userId);
      if (currentSettings == null) {
        final newSettings = await createUserSettings(userId);
        return await updateUserSettings(
            userId,
            newSettings.copyWith(
              themeSettings: settings,
            ));
      }

      return await updateUserSettings(
          userId,
          currentSettings.copyWith(
            themeSettings: settings,
          ));
    } catch (e) {
      rethrow;
    }
  }
}
