import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/contants.dart';
import 'settings_section.dart';

class DataSettingsSection extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const DataSettingsSection({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<DataSettingsSection> createState() => _DataSettingsSectionState();
}

class _DataSettingsSectionState extends State<DataSettingsSection> {
  late bool _autoSync;
  late bool _offlineMode;
  late String _cacheSize;
  late bool _backupData;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _autoSync = widget.settings['autoSync'] ?? true;
    _offlineMode = widget.settings['offlineMode'] ?? false;
    _cacheSize = widget.settings['cacheSize'] ?? '50 MB';
    _backupData = widget.settings['backupData'] ?? true;
  }

  void _updateSetting(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(widget.settings);
    updatedSettings[key] = value;
    widget.onSettingsChanged(updatedSettings);
    _saveToLocalStorage(key, value);
  }

  Future<void> _saveToLocalStorage(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('data_setting_$key', value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Data & Storage',
      icon: Icons.storage,
      child: Column(
        children: [
          _buildAutoSyncSetting(),
          const Divider(),
          _buildOfflineModeSetting(),
          const Divider(),
          _buildCacheSizeSetting(),
          const Divider(),
          _buildBackupSetting(),
          const Divider(),
          _buildClearCacheButton(),
          const Divider(),
          _buildExportDataButton(),
        ],
      ),
    );
  }

  Widget _buildAutoSyncSetting() {
    return SwitchListTile(
      secondary: const Icon(Icons.sync, color: AppColors.brandPrimary),
      title: const Text('Auto Sync'),
      subtitle: const Text('Automatically sync data with server'),
      value: _autoSync,
      onChanged: (value) {
        setState(() {
          _autoSync = value;
        });
        _updateSetting('autoSync', value);
      },
    );
  }

  Widget _buildOfflineModeSetting() {
    return SwitchListTile(
      secondary: const Icon(Icons.offline_bolt, color: AppColors.brandPrimary),
      title: const Text('Offline Mode'),
      subtitle: const Text('Work without internet connection'),
      value: _offlineMode,
      onChanged: (value) {
        setState(() {
          _offlineMode = value;
        });
        _updateSetting('offlineMode', value);
      },
    );
  }

  Widget _buildCacheSizeSetting() {
    return ListTile(
      leading: const Icon(Icons.folder, color: AppColors.brandPrimary),
      title: const Text('Cache Size'),
      subtitle: Text(_cacheSize),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showCacheSizeDialog(),
    );
  }

  Widget _buildBackupSetting() {
    return SwitchListTile(
      secondary: const Icon(Icons.backup, color: AppColors.brandPrimary),
      title: const Text('Auto Backup'),
      subtitle: const Text('Automatically backup your data'),
      value: _backupData,
      onChanged: (value) {
        setState(() {
          _backupData = value;
        });
        _updateSetting('backupData', value);
      },
    );
  }

  Widget _buildClearCacheButton() {
    return ListTile(
      leading: const Icon(Icons.clear_all, color: AppColors.lightWarning),
      title: const Text('Clear Cache'),
      subtitle: const Text('Free up storage space'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showClearCacheDialog(),
    );
  }

  Widget _buildExportDataButton() {
    return ListTile(
      leading: const Icon(Icons.download, color: AppColors.brandPrimary),
      title: const Text('Export Data'),
      subtitle: const Text('Download your data'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _exportData(),
    );
  }

  void _showCacheSizeDialog() {
    final cacheSizes = ['25 MB', '50 MB', '100 MB', '250 MB', '500 MB'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Cache Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: cacheSizes.map((size) {
            return RadioListTile<String>(
              title: Text(size),
              value: size,
              groupValue: _cacheSize,
              onChanged: (value) {
                setState(() {
                  _cacheSize = value!;
                });
                _updateSetting('cacheSize', value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'This will clear all cached data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightWarning),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    // In a real app, you would clear the cache here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully!'),
        backgroundColor: AppColors.lightSuccess,
      ),
    );
  }

  void _exportData() {
    // In a real app, you would export data here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export feature coming soon!'),
        backgroundColor: AppColors.brandPrimary,
      ),
    );
  }
}
