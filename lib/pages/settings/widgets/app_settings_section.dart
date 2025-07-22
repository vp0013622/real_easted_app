import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/providers/theme_provider.dart';
import 'package:inhabit_realties/pages/settings/widgets/settings_section.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

class AppSettingsSection extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const AppSettingsSection({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<AppSettingsSection> createState() => _AppSettingsSectionState();
}

class _AppSettingsSectionState extends State<AppSettingsSection> {
  late String _selectedLanguage;
  late String _selectedCurrency;
  late String _selectedTheme;
  late bool _notificationsEnabled;
  late bool _hapticFeedbackEnabled;
  late String _fontSize;
  late String _dateRange;
  late String _itemsPerPage;
  late String _timeFormat;
  late String _dateFormat;

  final List<String> _languageOptions = [
    'English',
    'Spanish',
    'French',
    'German'
  ];
  final List<String> _currencyOptions = ['INR', 'USD', 'EUR', 'GBP'];
  final List<String> _themeOptions = ['light', 'dark'];
  final List<String> _fontSizeOptions = [
    '0.8',
    '0.9',
    '1.0',
    '1.1',
    '1.2',
    '1.3'
  ];
  final List<String> _dateRangeOptions = ['7d', '30d', '90d', '1y'];
  final List<String> _itemsPerPageOptions = ['10', '20', '50', '100'];
  final List<String> _timeFormatOptions = ['12h', '24h'];
  final List<String> _dateFormatOptions = [
    'MM/dd/yyyy',
    'dd/MM/yyyy',
    'yyyy-MM-dd'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load from ThemeProvider first, then fallback to widget settings
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    _selectedLanguage = widget.settings['language'] ?? 'English';
    _notificationsEnabled = widget.settings['notificationsEnabled'] ?? true;
    _hapticFeedbackEnabled = widget.settings['hapticFeedbackEnabled'] ?? true;
    _selectedTheme = themeProvider.currentTheme;
    _fontSize = themeProvider.fontSize;
    _dateRange = widget.settings['dateRange'] ?? '30d';
    _itemsPerPage = widget.settings['itemsPerPage'] ?? '20';
    _timeFormat = widget.settings['timeFormat'] ?? '12h';
    _dateFormat = widget.settings['dateFormat'] ?? 'MM/dd/yyyy';
  }

  void _updateSetting(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(widget.settings);
    updatedSettings[key] = value;
    widget.onSettingsChanged(updatedSettings);
    _saveToLocalStorage(key, value);

    // Update theme provider for theme-related settings
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    switch (key) {
      case 'theme':
        themeProvider.updateTheme(value);
        break;
      case 'fontSize':
        themeProvider.updateFontSize(value);
        break;
    }
  }

  Future<void> _saveToLocalStorage(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_setting_$key', value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Update local state when theme provider changes
        _selectedTheme = themeProvider.currentTheme;
        _fontSize = themeProvider.fontSize;

        return SettingsSection(
          title: 'App Settings',
          icon: Icons.settings,
          child: Column(
            children: [
              _buildHapticFeedbackSetting(),
              const Divider(),
              _buildFeedbackButton(),
              const Divider(),
              _buildChangePasswordButton(),
              const Divider(),
              _buildLanguageSetting(),
              const Divider(),
              _buildNotificationsSetting(),
              const Divider(),
              _buildThemeSetting(),
              const Divider(),
              _buildFontSizeSetting(),
              const Divider(),
              _buildDateRangeSetting(),
              const Divider(),
              _buildItemsPerPageSetting(),
              const Divider(),
              _buildTimeFormatSetting(),
              const Divider(),
              _buildDateFormatSetting(),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHapticFeedbackSetting() {
    return SwitchListTile(
      secondary: const Icon(Icons.vibration, color: AppColors.brandPrimary),
      title: const Text('Haptic Feedback'),
      subtitle: const Text('Enable vibration feedback'),
      value: _hapticFeedbackEnabled,
      onChanged: (value) {
        setState(() {
          _hapticFeedbackEnabled = value;
        });
        _updateSetting('hapticFeedbackEnabled', value);
      },
    );
  }

  Widget _buildFeedbackButton() {
    return ListTile(
      leading: const Icon(Icons.feedback, color: AppColors.brandPrimary),
      title: const Text('Send Feedback'),
      subtitle: const Text('Let us know your thoughts'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: 'support@inhabit.com',
          query: 'subject=App Feedback',
        );
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
        }
      },
    );
  }

  Widget _buildChangePasswordButton() {
    return ListTile(
      leading: const Icon(Icons.lock_outline, color: AppColors.brandPrimary),
      title: const Text('Change Password'),
      subtitle: const Text('Update your account password'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pushNamed(context, '/auth/change_password');
      },
    );
  }

  Widget _buildLanguageSetting() {
    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.brandPrimary),
      title: const Text('Language'),
      subtitle: Text(_selectedLanguage),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageDialog(),
    );
  }

  Widget _buildNotificationsSetting() {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications, color: AppColors.brandPrimary),
      title: const Text('Notifications'),
      subtitle: const Text('Enable or disable app notifications'),
      value: _notificationsEnabled,
      onChanged: (value) {
        setState(() {
          _notificationsEnabled = value;
        });
        _updateSetting('notificationsEnabled', value);
      },
    );
  }

  Widget _buildThemeSetting() {
    return ListTile(
      leading: const Icon(Icons.brightness_6, color: AppColors.brandPrimary),
      title: const Text('Theme'),
      subtitle: Text(_selectedTheme == 'light' ? 'Light' : 'Dark'),
      trailing: DropdownButton<String>(
        value: _selectedTheme,
        items: _themeOptions.map((theme) {
          return DropdownMenuItem(
            value: theme,
            child: Text(theme == 'light' ? 'Light' : 'Dark'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedTheme = value;
            });
            _updateSetting('theme', value);
          }
        },
      ),
    );
  }

  Widget _buildFontSizeSetting() {
    return ListTile(
      leading: const Icon(Icons.text_fields, color: AppColors.brandPrimary),
      title: const Text('Font Size'),
      subtitle: Text('${_fontSize}x'),
      trailing: DropdownButton<String>(
        value: _fontSize,
        items: _fontSizeOptions.map((size) {
          return DropdownMenuItem(
            value: size,
            child: Text('${size}x'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _fontSize = value;
            });
            _updateSetting('fontSize', value);
          }
        },
      ),
    );
  }

  Widget _buildDateRangeSetting() {
    return ListTile(
      leading: const Icon(Icons.date_range, color: AppColors.brandPrimary),
      title: const Text('Default Date Range'),
      subtitle: Text(_dateRange),
      trailing: DropdownButton<String>(
        value: _dateRange,
        items: _dateRangeOptions.map((range) {
          return DropdownMenuItem(
            value: range,
            child: Text(range),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _dateRange = value;
            });
            _updateSetting('dateRange', value);
          }
        },
      ),
    );
  }

  Widget _buildItemsPerPageSetting() {
    return ListTile(
      leading: const Icon(Icons.list, color: AppColors.brandPrimary),
      title: const Text('Items Per Page'),
      subtitle: Text(_itemsPerPage),
      trailing: DropdownButton<String>(
        value: _itemsPerPage,
        items: _itemsPerPageOptions.map((items) {
          return DropdownMenuItem(
            value: items,
            child: Text(items),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _itemsPerPage = value;
            });
            _updateSetting('itemsPerPage', value);
          }
        },
      ),
    );
  }

  Widget _buildTimeFormatSetting() {
    return ListTile(
      leading: const Icon(Icons.access_time, color: AppColors.brandPrimary),
      title: const Text('Time Format'),
      subtitle: Text(_timeFormat),
      trailing: DropdownButton<String>(
        value: _timeFormat,
        items: _timeFormatOptions.map((format) {
          return DropdownMenuItem(
            value: format,
            child: Text(format),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _timeFormat = value;
            });
            _updateSetting('timeFormat', value);
          }
        },
      ),
    );
  }

  Widget _buildDateFormatSetting() {
    return ListTile(
      leading: const Icon(Icons.calendar_today, color: AppColors.brandPrimary),
      title: const Text('Date Format'),
      subtitle: Text(_dateFormat),
      trailing: DropdownButton<String>(
        value: _dateFormat,
        items: _dateFormatOptions.map((format) {
          return DropdownMenuItem(
            value: format,
            child: Text(format),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _dateFormat = value;
            });
            _updateSetting('dateFormat', value);
          }
        },
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languageOptions.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _updateSetting('language', value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = [
      {'code': 'INR', 'name': 'Indian Rupee (₹)'},
      {'code': 'USD', 'name': 'US Dollar (\$)'},
      {'code': 'EUR', 'name': 'Euro (€)'},
      {'code': 'GBP', 'name': 'British Pound (£)'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency['name']!),
              value: currency['code']!,
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
                _updateSetting('currency', value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
