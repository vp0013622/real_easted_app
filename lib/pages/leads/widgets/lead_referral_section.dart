import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/services/user/userService.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/pages/widgets/profile_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadReferralSection extends StatefulWidget {
  final LeadsModel lead;

  const LeadReferralSection({Key? key, required this.lead}) : super(key: key);

  @override
  State<LeadReferralSection> createState() => _LeadReferralSectionState();
}

class _LeadReferralSectionState extends State<LeadReferralSection> {
  final UserService _userService = UserService();
  UsersModel? _referredByUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReferredByUserDetails();
  }

  Future<void> _loadReferredByUserDetails() async {
    if (widget.lead.referredByUserId == null ||
        widget.lead.referredByUserId!.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (widget.lead.referredByUserId != null &&
          widget.lead.referredByUserId!.isNotEmpty) {
        final referredByResult = await _userService.getUsersByUserId(
          token,
          widget.lead.referredByUserId!,
        );
        if (referredByResult['statusCode'] == 200 &&
            referredByResult['data'] != null) {
          setState(() {
            _referredByUser = UsersModel.fromJson(referredByResult['data']);
          });
        }
      }
    } catch (error) {
      // Handle error silently
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final secondaryTextColor =
        isDark ? AppColors.greyColor : AppColors.greyColor2;

    // Check if there's any referral information to show
    final hasReferralInfo = widget.lead.referredByUserFirstName != null ||
        widget.lead.referredByUserEmail != null ||
        widget.lead.referredByUserPhoneNumber != null ||
        widget.lead.referredByUserDesignation != null ||
        (widget.lead.referredByUserId != null &&
            widget.lead.referredByUserId!.isNotEmpty) ||
        widget.lead.referanceFrom != null;

    if (!hasReferralInfo) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_add_outlined,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Referral Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    size: 48,
                    color: secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No referral information available',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_add_outlined,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Referral Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.brandPrimary,
                ),
              ),
            )
          else ...[
            // Show referred by user details (fetched from API)
            if (widget.lead.referredByUserId != null &&
                widget.lead.referredByUserId!.isNotEmpty)
              _buildUserInfoRow(
                'Referred By User',
                _referredByUser,
                Icons.person_add_outlined,
                secondaryTextColor,
                widget.lead.referredByUserId!,
                isDark,
              ),

            // Show existing referral information (from lead model)
            if (widget.lead.referredByUserFirstName != null)
              _buildInfoRow(
                'Referred By',
                '${widget.lead.referredByUserFirstName} ${widget.lead.referredByUserLastName ?? ''}',
                Icons.person_outlined,
                secondaryTextColor,
              ),
            if (widget.lead.referredByUserEmail != null)
              _buildInfoRow('Referrer Email', widget.lead.referredByUserEmail!,
                  Icons.email_outlined, secondaryTextColor),
            if (widget.lead.referredByUserPhoneNumber != null)
              _buildInfoRowWithCallButton(
                  'Referrer Phone',
                  widget.lead.referredByUserPhoneNumber!,
                  Icons.phone_outlined,
                  secondaryTextColor,
                  isDark),
            if (widget.lead.referredByUserDesignation != null)
              _buildInfoRow(
                  'Referrer Designation',
                  widget.lead.referredByUserDesignation!,
                  Icons.work_outline,
                  secondaryTextColor),

            // Show reference source information
            if (widget.lead.referanceFrom != null)
              _buildInfoRow(
                'Reference Source',
                widget.lead.referanceFrom!.name,
                Icons.source_outlined,
                secondaryTextColor,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String label, UsersModel? user, IconData icon,
      Color iconColor, String userId, bool isDark) {
    String displayName = 'Loading...';
    String? userEmail;
    String? userPhone;
    String? userRole;

    if (user != null) {
      displayName = '${user.firstName} ${user.lastName}'.trim();
      userEmail = user.email;
      userPhone = user.phoneNumber;
      userRole = user.role;
    } else {
      displayName = 'User ID: $userId';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 12),
              if (user != null) ...[
                ProfileAvatar(
                  userId: user.id,
                  userName: displayName,
                  size: 40,
                  showBorder: false,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: iconColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Add view button for referred by user
              if (user != null)
                IconButton(
                  onPressed: () {
                    // Navigate to user details page
                    Navigator.pushNamed(
                      context,
                      '/users/edit',
                      arguments: user,
                    );
                  },
                  icon: Icon(
                    Icons.visibility,
                    color: isDark
                        ? AppColors.brandSecondary
                        : AppColors.brandPrimary,
                    size: 18,
                  ),
                  tooltip: 'View Referred By User Details',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),
          if (user != null) ...[
            if (userEmail != null && userEmail.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 12,
                      color: iconColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: iconColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (userPhone != null && userPhone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 12,
                      color: iconColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userPhone,
                        style: TextStyle(
                          fontSize: 12,
                          color: iconColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                    // Add call button for user phone
                    IconButton(
                      onPressed: () => _makePhoneCall(userPhone!),
                      icon: Icon(
                        Icons.call,
                        color: AppColors.successColor(isDark),
                        size: 16,
                      ),
                      tooltip: 'Call ${userPhone}',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),
              ),
            if (userRole != null && userRole.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 12,
                      color: iconColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userRole,
                        style: TextStyle(
                          fontSize: 12,
                          color: iconColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: iconColor.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithCallButton(
      String label, String value, IconData icon, Color iconColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: iconColor.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Add call button for phone numbers
          IconButton(
            onPressed: () => _makePhoneCall(value),
            icon: Icon(
              Icons.call,
              color: AppColors.successColor(isDark),
              size: 18,
            ),
            tooltip: 'Call $value',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}
