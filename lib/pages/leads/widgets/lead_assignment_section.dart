import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/services/user/userService.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/pages/widgets/profile_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeadAssignmentSection extends StatefulWidget {
  final LeadsModel lead;

  const LeadAssignmentSection({Key? key, required this.lead}) : super(key: key);

  @override
  State<LeadAssignmentSection> createState() => _LeadAssignmentSectionState();
}

class _LeadAssignmentSectionState extends State<LeadAssignmentSection> {
  final UserService _userService = UserService();
  final Map<String, UsersModel?> _userDetails = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    if (widget.lead.assignedByUserId == null &&
        widget.lead.assignedToUserId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (widget.lead.assignedByUserId.isNotEmpty) {
        final assignedByResult = await _userService.getUsersByUserId(
          token,
          widget.lead.assignedByUserId,
        );
        if (assignedByResult['statusCode'] == 200 &&
            assignedByResult['data'] != null) {
          setState(() {
            _userDetails['assignedBy'] =
                UsersModel.fromJson(assignedByResult['data']);
          });
        }
      }

      if (widget.lead.assignedToUserId.isNotEmpty) {
        final assignedToResult = await _userService.getUsersByUserId(
          token,
          widget.lead.assignedToUserId,
        );
        if (assignedToResult['statusCode'] == 200 &&
            assignedToResult['data'] != null) {
          setState(() {
            _userDetails['assignedTo'] =
                UsersModel.fromJson(assignedToResult['data']);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final secondaryTextColor =
        isDark ? AppColors.greyColor : AppColors.greyColor2;

    // Check if there's any assignment information to show
    final hasAssignmentInfo = widget.lead.assignedByUserId.isNotEmpty ||
        widget.lead.assignedToUserId.isNotEmpty;

    if (!hasAssignmentInfo) {
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
                  Icons.assignment_outlined,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assignment Information',
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
                    Icons.assignment_outlined,
                    size: 48,
                    color: secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No assignment information available',
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
                Icons.assignment_outlined,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Assignment Information',
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
            if (widget.lead.assignedByUserId.isNotEmpty)
              _buildUserInfoRow(
                'Assigned By',
                _userDetails['assignedBy'],
                Icons.person_add_outlined,
                secondaryTextColor,
                widget.lead.assignedByUserId,
                isDark,
              ),
            if (widget.lead.assignedToUserId.isNotEmpty)
              _buildUserInfoRow(
                'Assigned To',
                _userDetails['assignedTo'],
                Icons.check_circle_outline,
                secondaryTextColor,
                widget.lead.assignedToUserId,
                isDark,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(
    String label,
    UsersModel? user,
    IconData icon,
    Color iconColor,
    String userId,
    bool isDark,
  ) {
    String displayValue = 'Loading...';
    String? userEmail;
    String? userPhone;

    if (user != null) {
      displayValue = '${user.firstName} ${user.lastName}'.trim();
      userEmail = user.email;
      userPhone = user.phoneNumber;
    } else {
      displayValue = 'User ID: $userId';
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
                  userName: displayValue,
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
                      displayValue,
                      style: TextStyle(
                        fontSize: 14,
                        color: iconColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Add view button for each user row
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
                  tooltip: 'View ${label} Details',
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
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
