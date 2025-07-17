import 'package:flutter/material.dart';
import '../../../constants/contants.dart';
import 'settings_section.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'About',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildAppInfo(),
          const Divider(),
          _buildVersionInfo(),
          const Divider(),
          _buildSupportButton(),
          const Divider(),
          _buildPrivacyPolicyButton(),
          const Divider(),
          _buildTermsOfServiceButton(),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return ListTile(
      leading: const Icon(Icons.business, color: AppColors.brandPrimary),
      title: const Text('Inhabit Real Estate'),
      subtitle: const Text('Professional real estate management'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Show app info dialog
      },
    );
  }

  Widget _buildVersionInfo() {
    return ListTile(
      leading: const Icon(Icons.update, color: AppColors.brandPrimary),
      title: const Text('Version'),
      subtitle: const Text('1.0.0'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Check for updates
      },
    );
  }

  Widget _buildSupportButton() {
    return ListTile(
      leading: const Icon(Icons.support_agent, color: AppColors.brandPrimary),
      title: const Text('Support'),
      subtitle: const Text('Get help and contact us'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Open support page or contact
      },
    );
  }

  Widget _buildPrivacyPolicyButton() {
    return ListTile(
      leading: const Icon(Icons.privacy_tip, color: AppColors.brandPrimary),
      title: const Text('Privacy Policy'),
      subtitle: const Text('How we protect your data'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Open privacy policy
      },
    );
  }

  Widget _buildTermsOfServiceButton() {
    return ListTile(
      leading: const Icon(Icons.description, color: AppColors.brandPrimary),
      title: const Text('Terms of Service'),
      subtitle: const Text('App usage terms and conditions'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Open terms of service
      },
    );
  }
}
