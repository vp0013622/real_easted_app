import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../constants/contants.dart';
import '../../controllers/settings/UserSettingsController.dart';
import '../../models/auth/UsersModel.dart';
import '../../providers/theme_provider.dart';
import 'widgets/notification_settings_section.dart';
import 'widgets/display_settings_section.dart';
import 'widgets/privacy_settings_section.dart';
import 'widgets/report_settings_section.dart';
import 'widgets/theme_settings_section.dart';
import 'widgets/app_settings_section.dart';
import 'widgets/data_settings_section.dart';
import 'widgets/about_section.dart';
import '../widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserSettingsController _settingsController;
  UsersModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _settingsController = UserSettingsController();
    _loadUserAndSettings();
  }

  Future<void> _loadUserAndSettings() async {
    await _loadCurrentUser();
    if (_currentUser != null) {
      await _settingsController.loadUserSettings(_currentUser!.id);
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');

      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = UsersModel.fromJson(userData);
      }
    } catch (e) {
      // Error handled silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.currentTheme == 'dark';
        final cardColor = isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground;
        final textColor =
            isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: AppBar(
            title: Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: textColor),
                onPressed: () => _loadUserAndSettings(),
                tooltip: 'Refresh Settings',
              ),
            ],
          ),
          body: AnimatedBuilder(
            animation: _settingsController,
            builder: (context, child) {
              if (_settingsController.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading your settings...',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.darkWhiteText
                              : AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_settingsController.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: isDark
                            ? AppColors.darkDanger
                            : AppColors.lightDanger,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading settings',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: textColor,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _settingsController.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkWhiteText
                                : AppColors.greyColor),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadUserAndSettings(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!_settingsController.hasSettings) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings,
                        size: 64,
                        color: isDark
                            ? AppColors.darkWhiteText
                            : AppColors.greyColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No settings found',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: textColor,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your settings will be created automatically',
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkWhiteText
                                : AppColors.greyColor),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadUserAndSettings(),
                        child: const Text('Create Settings'),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Section
                    _buildUserInfoSection(),
                    const SizedBox(height: 24),

                    // Settings Sections
                    AppSettingsSection(
                      settings: {
                        'language': 'English',
                        'currency': 'INR',
                        'theme': themeProvider.currentTheme,
                        'notificationsEnabled': true,
                        'hapticFeedbackEnabled': true,
                        'fontSize': themeProvider.fontSize,
                        'dateRange': '30d',
                        'itemsPerPage': '20',
                        'timeFormat': '12h',
                        'dateFormat': 'MM/dd/yyyy',
                      },
                      onSettingsChanged: (settings) {
                        // TODO: Implement app settings update
                    
                      },
                    ),
                    const SizedBox(height: 16),

                    const AboutSection(),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 35,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.firstName != null &&
                          _currentUser?.lastName != null
                      ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
                      : _currentUser?.email ?? 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser?.email ?? 'user@example.com',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Settings saved in cloud',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.cloud_done,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showResetConfirmation(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _saveSettings(),
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _exportSettings(),
                icon: const Icon(Icons.download),
                label: const Text('Export Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to default? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentUser != null) {
                _settingsController.resetToDefault(_currentUser!.id);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Settings'),
        content: const Text(
          'Are you sure you want to delete all settings? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentUser != null) {
                _settingsController.deleteUserSettings(_currentUser!.id);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportSettings() {
    if (_settingsController.userSettings != null) {
      // In a real app, you would export to file or share
      AppSnackBar.showSnackBar(
        context,
        'Info',
        'Settings export feature coming soon!',
        ContentType.help,
      );
    }
  }

  void _saveSettings() async {
    try {
      // Save all settings to backend and local storage
      await _settingsController.saveAllSettings();

      AppSnackBar.showSnackBar(
        context,
        'Success',
        'Settings saved successfully!',
        ContentType.success,
      );
    } catch (e) {
      AppSnackBar.showSnackBar(
        context,
        'Error',
        'Failed to save settings: $e',
        ContentType.failure,
      );
    }
  }
}
