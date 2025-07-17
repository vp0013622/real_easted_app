import 'package:flutter/material.dart';
import '../../../models/settings/UserSettingsModel.dart';
import 'settings_section.dart';

class ThemeSettingsSection extends StatefulWidget {
  final ThemeSettings settings;
  final Function(ThemeSettings) onSettingsChanged;

  const ThemeSettingsSection({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<ThemeSettingsSection> createState() => _ThemeSettingsSectionState();
}

class _ThemeSettingsSectionState extends State<ThemeSettingsSection> {
  late ThemeSettings _settings;

  final List<String> _themeModeOptions = ['light', 'dark', 'auto'];

  final List<String> _fontSizeOptions = [
    '0.8',
    '0.9',
    '1.0',
    '1.1',
    '1.2',
    '1.3',
    '1.4'
  ];

  final List<String> _primaryColorOptions = [
    '#2196F3',
    '#4CAF50',
    '#FF9800',
    '#9C27B0',
    '#F44336',
    '#607D8B',
    '#795548'
  ];

  final List<String> _accentColorOptions = [
    '#FF4081',
    '#4CAF50',
    '#FF9800',
    '#9C27B0',
    '#F44336',
    '#607D8B',
    '#795548'
  ];

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(ThemeSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _settings = widget.settings;
    }
  }

  void _updateSettings() {
    widget.onSettingsChanged(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Theme & Appearance',
      subtitle: 'Customize the look and feel of the app',
      icon: Icons.palette,
      iconColor: Colors.indigo,
      child: Column(
        children: [
          _buildDropdownTile(
            'Theme Mode',
            'Choose light, dark, or auto theme',
            _settings.themeMode,
            _themeModeOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(themeMode: value);
              });
              _updateSettings();
            },
            icon: Icons.brightness_6,
          ),
          _buildSwitchTile(
            'Use System Theme',
            'Follow your device theme settings',
            _settings.useSystemTheme,
            (value) {
              setState(() {
                _settings = _settings.copyWith(useSystemTheme: value);
              });
              _updateSettings();
            },
            icon: Icons.settings_system_daydream,
          ),
          const Divider(),
          _buildColorPickerTile(
            'Primary Color',
            'Main color theme of the app',
            _settings.primaryColor,
            _primaryColorOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(primaryColor: value);
              });
              _updateSettings();
            },
            icon: Icons.color_lens,
          ),
          _buildColorPickerTile(
            'Accent Color',
            'Secondary color for highlights',
            _settings.accentColor,
            _accentColorOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(accentColor: value);
              });
              _updateSettings();
            },
            icon: Icons.color_lens_outlined,
          ),
          const Divider(),
          _buildDropdownTile(
            'Font Size',
            'Adjust text size throughout the app',
            _settings.fontSize.toString(),
            _fontSizeOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(fontSize: double.parse(value));
              });
              _updateSettings();
            },
            icon: Icons.text_fields,
          ),
          const Divider(),
          _buildSwitchTile(
            'High Contrast',
            'Use high contrast colors for better visibility',
            _settings.highContrast,
            (value) {
              setState(() {
                _settings = _settings.copyWith(highContrast: value);
              });
              _updateSettings();
            },
            icon: Icons.contrast,
          ),
          _buildSwitchTile(
            'Reduce Motion',
            'Minimize animations for accessibility',
            _settings.reduceMotion,
            (value) {
              setState(() {
                _settings = _settings.copyWith(reduceMotion: value);
              });
              _updateSettings();
            },
            icon: Icons.motion_photos_pause,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.indigo,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    Function(String) onChanged, {
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option.toUpperCase()),
          );
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildColorPickerTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    Function(String) onChanged, {
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _hexToColor(value),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: value,
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _hexToColor(option),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Color _hexToColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
