import 'package:flutter/material.dart';
import '../../../models/settings/UserSettingsModel.dart';
import 'settings_section.dart';

class PrivacySettingsSection extends StatefulWidget {
  final PrivacySettings settings;
  final Function(PrivacySettings) onSettingsChanged;

  const PrivacySettingsSection({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<PrivacySettingsSection> createState() => _PrivacySettingsSectionState();
}

class _PrivacySettingsSectionState extends State<PrivacySettingsSection> {
  late PrivacySettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(PrivacySettingsSection oldWidget) {
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
      title: 'Privacy & Security',
      subtitle: 'Control your privacy and data sharing preferences',
      icon: Icons.security,
      iconColor: Colors.red,
      child: Column(
        children: [
          _buildSwitchTile(
            'Share Profile',
            'Allow others to see your profile information',
            _settings.shareProfile,
            (value) {
              setState(() {
                _settings = _settings.copyWith(shareProfile: value);
              });
              _updateSettings();
            },
            icon: Icons.person,
          ),
          _buildSwitchTile(
            'Show Online Status',
            'Display when you are online',
            _settings.showOnlineStatus,
            (value) {
              setState(() {
                _settings = _settings.copyWith(showOnlineStatus: value);
              });
              _updateSettings();
            },
            icon: Icons.circle,
          ),
          _buildSwitchTile(
            'Allow Messages',
            'Allow other users to send you messages',
            _settings.allowMessages,
            (value) {
              setState(() {
                _settings = _settings.copyWith(allowMessages: value);
              });
              _updateSettings();
            },
            icon: Icons.message,
          ),
          _buildSwitchTile(
            'Show Contact Info',
            'Display your contact information to others',
            _settings.showContactInfo,
            (value) {
              setState(() {
                _settings = _settings.copyWith(showContactInfo: value);
              });
              _updateSettings();
            },
            icon: Icons.contact_phone,
          ),
          const Divider(),
          _buildSwitchTile(
            'Location Sharing',
            'Allow the app to access your location',
            _settings.allowLocationSharing,
            (value) {
              setState(() {
                _settings = _settings.copyWith(allowLocationSharing: value);
              });
              _updateSettings();
            },
            icon: Icons.location_on,
          ),
          const Divider(),
          _buildSwitchTile(
            'Data Analytics',
            'Help improve the app with anonymous usage data',
            _settings.dataAnalytics,
            (value) {
              setState(() {
                _settings = _settings.copyWith(dataAnalytics: value);
              });
              _updateSettings();
            },
            icon: Icons.analytics,
          ),
          _buildSwitchTile(
            'Marketing Emails',
            'Receive promotional emails and offers',
            _settings.marketingEmails,
            (value) {
              setState(() {
                _settings = _settings.copyWith(marketingEmails: value);
              });
              _updateSettings();
            },
            icon: Icons.mark_email_read,
          ),
          _buildSwitchTile(
            'Third Party Sharing',
            'Allow sharing data with trusted partners',
            _settings.thirdPartySharing,
            (value) {
              setState(() {
                _settings = _settings.copyWith(thirdPartySharing: value);
              });
              _updateSettings();
            },
            icon: Icons.share,
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
        activeColor: Colors.red,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
