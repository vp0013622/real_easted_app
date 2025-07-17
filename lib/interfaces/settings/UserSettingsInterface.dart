import '../../models/settings/UserSettingsModel.dart';

abstract class UserSettingsInterface {
  Future<UserSettingsModel?> getUserSettings(String userId);
  Future<UserSettingsModel> createUserSettings(String userId);
  Future<UserSettingsModel> updateUserSettings(
      String userId, UserSettingsModel settings);
  Future<bool> deleteUserSettings(String userId);
  Future<UserSettingsModel> updateNotificationSettings(
      String userId, NotificationSettings settings);
  Future<UserSettingsModel> updateDisplaySettings(
      String userId, DisplaySettings settings);
  Future<UserSettingsModel> updatePrivacySettings(
      String userId, PrivacySettings settings);
  Future<UserSettingsModel> updateReportSettings(
      String userId, ReportSettings settings);
  Future<UserSettingsModel> updateThemeSettings(
      String userId, ThemeSettings settings);
}
