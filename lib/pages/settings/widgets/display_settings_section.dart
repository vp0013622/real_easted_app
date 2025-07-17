import 'package:flutter/material.dart';
import '../../../models/settings/UserSettingsModel.dart';
import 'settings_section.dart';

class DisplaySettingsSection extends StatefulWidget {
  final DisplaySettings settings;
  final Function(DisplaySettings) onSettingsChanged;

  const DisplaySettingsSection({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<DisplaySettingsSection> createState() => _DisplaySettingsSectionState();
}

class _DisplaySettingsSectionState extends State<DisplaySettingsSection> {
  late DisplaySettings _settings;

  final List<String> _languageOptions = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko'
  ];

  final List<String> _dateFormatOptions = [
    'MM/dd/yyyy',
    'dd/MM/yyyy',
    'yyyy-MM-dd',
    'dd.MM.yyyy'
  ];

  final List<String> _timeFormatOptions = ['12h', '24h'];

  final List<String> _currencyOptions = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'CHF',
    'CNY',
    'INR'
  ];

  final List<int> _itemsPerPageOptions = [10, 20, 50, 100];

  final List<String> _viewOptions = ['list', 'grid', 'card'];

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(DisplaySettingsSection oldWidget) {
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
      title: 'Display',
      subtitle: 'Customize your app appearance and preferences',
      icon: Icons.display_settings,
      iconColor: Colors.purple,
      child: Column(
        children: [
          _buildDropdownTile(
            'Language',
            'Choose your preferred language',
            _settings.language,
            _languageOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(language: value);
              });
              _updateSettings();
            },
            icon: Icons.language,
          ),
          _buildDropdownTile(
            'Date Format',
            'How dates are displayed',
            _settings.dateFormat,
            _dateFormatOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(dateFormat: value);
              });
              _updateSettings();
            },
            icon: Icons.date_range,
          ),
          _buildDropdownTile(
            'Time Format',
            '12-hour or 24-hour format',
            _settings.timeFormat,
            _timeFormatOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(timeFormat: value);
              });
              _updateSettings();
            },
            icon: Icons.access_time,
          ),
          const Divider(),
          _buildDropdownTile(
            'Currency',
            'Your preferred currency',
            _settings.currency,
            _currencyOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(currency: value);
              });
              _updateSettings();
            },
            icon: Icons.attach_money,
          ),
          _buildSwitchTile(
            'Show Currency Symbol',
            'Display currency symbol with amounts',
            _settings.showCurrencySymbol,
            (value) {
              setState(() {
                _settings = _settings.copyWith(showCurrencySymbol: value);
              });
              _updateSettings();
            },
            icon: Icons.monetization_on,
          ),
          const Divider(),
          _buildDropdownTile(
            'Items Per Page',
            'Number of items to show per page',
            _settings.itemsPerPage.toString(),
            _itemsPerPageOptions.map((e) => e.toString()).toList(),
            (value) {
              setState(() {
                _settings = _settings.copyWith(itemsPerPage: int.parse(value));
              });
              _updateSettings();
            },
            icon: Icons.list,
          ),
          _buildSwitchTile(
            'Compact Mode',
            'Use compact layout for lists',
            _settings.compactMode,
            (value) {
              setState(() {
                _settings = _settings.copyWith(compactMode: value);
              });
              _updateSettings();
            },
            icon: Icons.view_compact,
          ),
          _buildSwitchTile(
            'Show Images',
            'Display images in lists and cards',
            _settings.showImages,
            (value) {
              setState(() {
                _settings = _settings.copyWith(showImages: value);
              });
              _updateSettings();
            },
            icon: Icons.image,
          ),
          _buildDropdownTile(
            'Default View',
            'Default view for lists',
            _settings.defaultView,
            _viewOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(defaultView: value);
              });
              _updateSettings();
            },
            icon: Icons.view_list,
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
        activeColor: Colors.purple,
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
}
