import 'package:flutter/material.dart';
import '../../../models/settings/UserSettingsModel.dart';
import 'settings_section.dart';

class ReportSettingsSection extends StatefulWidget {
  final ReportSettings settings;
  final Function(ReportSettings) onSettingsChanged;

  const ReportSettingsSection({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<ReportSettingsSection> createState() => _ReportSettingsSectionState();
}

class _ReportSettingsSectionState extends State<ReportSettingsSection> {
  late ReportSettings _settings;

  final List<String> _reportTypeOptions = [
    'overview',
    'properties',
    'leads',
    'financial',
    'performance',
    'analytics'
  ];

  final List<String> _dateRangeOptions = ['7d', '30d', '90d', '1y', 'custom'];

  final List<int> _refreshIntervalOptions = [15, 30, 60, 120];

  final List<String> _exportFormatOptions = ['pdf', 'excel', 'csv'];

  final List<String> _emailScheduleOptions = [
    'never',
    'daily',
    'weekly',
    'monthly'
  ];

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(ReportSettingsSection oldWidget) {
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
      title: 'Reports',
      subtitle: 'Configure your report preferences and export settings',
      icon: Icons.assessment,
      iconColor: Colors.green,
      child: Column(
        children: [
          _buildDropdownTile(
            'Default Report Type',
            'Default report to show when opening reports',
            _settings.defaultReportType,
            _reportTypeOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(defaultReportType: value);
              });
              _updateSettings();
            },
            icon: Icons.bar_chart,
          ),
          _buildDropdownTile(
            'Default Date Range',
            'Default time period for reports',
            _settings.defaultDateRange,
            _dateRangeOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(defaultDateRange: value);
              });
              _updateSettings();
            },
            icon: Icons.date_range,
          ),
          const Divider(),
          _buildSwitchTile(
            'Auto Refresh',
            'Automatically refresh reports',
            _settings.autoRefresh,
            (value) {
              setState(() {
                _settings = _settings.copyWith(autoRefresh: value);
              });
              _updateSettings();
            },
            icon: Icons.refresh,
          ),
          _buildDropdownTile(
            'Refresh Interval',
            'How often to refresh reports (minutes)',
            _settings.refreshInterval.toString(),
            _refreshIntervalOptions.map((e) => e.toString()).toList(),
            (value) {
              setState(() {
                _settings =
                    _settings.copyWith(refreshInterval: int.parse(value));
              });
              _updateSettings();
            },
            icon: Icons.timer,
          ),
          const Divider(),
          _buildSwitchTile(
            'Show Charts',
            'Display charts in reports',
            _settings.showCharts,
            (value) {
              setState(() {
                _settings = _settings.copyWith(showCharts: value);
              });
              _updateSettings();
            },
            icon: Icons.pie_chart,
          ),
          _buildSwitchTile(
            'Show Details',
            'Display detailed information in reports',
            _settings.showDetails,
            (value) {
              setState(() {
                _settings = _settings.copyWith(showDetails: value);
              });
              _updateSettings();
            },
            icon: Icons.info,
          ),
          const Divider(),
          _buildDropdownTile(
            'Export Format',
            'Default format for report exports',
            _settings.exportFormat,
            _exportFormatOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(exportFormat: value);
              });
              _updateSettings();
            },
            icon: Icons.file_download,
          ),
          _buildSwitchTile(
            'Email Reports',
            'Automatically email reports',
            _settings.emailReports,
            (value) {
              setState(() {
                _settings = _settings.copyWith(emailReports: value);
              });
              _updateSettings();
            },
            icon: Icons.email,
          ),
          _buildDropdownTile(
            'Email Schedule',
            'How often to send email reports',
            _settings.emailSchedule,
            _emailScheduleOptions,
            (value) {
              setState(() {
                _settings = _settings.copyWith(emailSchedule: value);
              });
              _updateSettings();
            },
            icon: Icons.schedule,
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
        activeColor: Colors.green,
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
