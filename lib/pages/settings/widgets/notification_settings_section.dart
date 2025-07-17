import 'package:flutter/material.dart';
import '../../../models/settings/UserSettingsModel.dart';
import 'settings_section.dart';

class NotificationSettingsSection extends StatefulWidget {
  final NotificationSettings settings;
  final Function(NotificationSettings) onSettingsChanged;

  const NotificationSettingsSection({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<NotificationSettingsSection> createState() =>
      _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState
    extends State<NotificationSettingsSection> {
  late NotificationSettings _settings;
  final List<String> _timeOptions = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00'
  ];

  final List<String> _dayOptions = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(NotificationSettingsSection oldWidget) {
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
      title: 'Notifications',
      subtitle: 'Manage your notification preferences',
      icon: Icons.notifications,
      iconColor: Colors.orange,
      child: Column(
        children: [
          _buildSwitchTile(
            'Push Notifications',
            'Receive push notifications on your device',
            _settings.pushNotifications,
            (value) {
              setState(() {
                _settings = _settings.copyWith(pushNotifications: value);
              });
              _updateSettings();
            },
            icon: Icons.notifications_active,
          ),
          _buildSwitchTile(
            'Email Notifications',
            'Receive notifications via email',
            _settings.emailNotifications,
            (value) {
              setState(() {
                _settings = _settings.copyWith(emailNotifications: value);
              });
              _updateSettings();
            },
            icon: Icons.email,
          ),
          _buildSwitchTile(
            'SMS Notifications',
            'Receive notifications via SMS',
            _settings.smsNotifications,
            (value) {
              setState(() {
                _settings = _settings.copyWith(smsNotifications: value);
              });
              _updateSettings();
            },
            icon: Icons.sms,
          ),
          const Divider(),
          _buildSwitchTile(
            'Lead Notifications',
            'Get notified about new leads and updates',
            _settings.leadNotifications,
            (value) {
              setState(() {
                _settings = _settings.copyWith(leadNotifications: value);
              });
              _updateSettings();
            },
            icon: Icons.person_add,
          ),
          _buildSwitchTile(
            'Property Notifications',
            'Get notified about property updates',
            _settings.propertyNotifications,
            (value) {
              setState(() {
                _settings = _settings.copyWith(propertyNotifications: value);
              });
              _updateSettings();
            },
            icon: Icons.home,
          ),
          _buildSwitchTile(
            'Document Notifications',
            'Get notified about document uploads',
            _settings.documentNotifications,
            (value) {
              setState(() {
                _settings = _settings.copyWith(documentNotifications: value);
              });
              _updateSettings();
            },
            icon: Icons.description,
          ),
          _buildSwitchTile(
            'Report Notifications',
            'Get notified about report updates',
            _settings.reportNotifications,
            (value) {
              setState(() {
                _settings = _settings.copyWith(reportNotifications: value);
              });
              _updateSettings();
            },
            icon: Icons.assessment,
          ),
          const Divider(),
          _buildDropdownTile(
            'Notification Time',
            'Time to send daily notifications',
            _settings.notificationTime,
            _timeOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(notificationTime: value);
              });
              _updateSettings();
            },
            icon: Icons.access_time,
          ),
          _buildMultiSelectTile(
            'Notification Days',
            'Days to receive notifications',
            _settings.notificationDays,
            _dayOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(notificationDays: value);
              });
              _updateSettings();
            },
            icon: Icons.calendar_today,
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
        activeColor: Colors.orange,
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
            child: Text(option),
          );
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMultiSelectTile(
    String title,
    String subtitle,
    List<String> selectedValues,
    List<String> options,
    Function(List<String>) onChanged, {
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: TextButton(
        onPressed: () =>
            _showMultiSelectDialog(title, selectedValues, options, onChanged),
        child: Text('${selectedValues.length} selected'),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showMultiSelectDialog(
    String title,
    List<String> selectedValues,
    List<String> options,
    Function(List<String>) onChanged,
  ) {
    List<String> tempSelected = List.from(selectedValues);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $title'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return CheckboxListTile(
                title: Text(option.toUpperCase()),
                value: tempSelected.contains(option),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      tempSelected.add(option);
                    } else {
                      tempSelected.remove(option);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onChanged(tempSelected);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
