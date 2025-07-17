import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/Enums/leadDesignationEnum.dart';
import 'package:inhabit_realties/services/property/propertyService.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inhabit_realties/constants/status_utils.dart';

class LeadInfoSection extends StatefulWidget {
  final LeadsModel lead;

  const LeadInfoSection({Key? key, required this.lead}) : super(key: key);

  @override
  State<LeadInfoSection> createState() => _LeadInfoSectionState();
}

class _LeadInfoSectionState extends State<LeadInfoSection> {
  final PropertyService _propertyService = PropertyService();
  PropertyModel? _interestedProperty;
  bool _isLoadingProperty = false;

  @override
  void initState() {
    super.initState();
    _loadInterestedPropertyDetails();
  }

  Future<void> _loadInterestedPropertyDetails() async {
    if (widget.lead.leadInterestedPropertyId.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingProperty = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final propertyResult = await _propertyService.getPropertyById(
        token,
        widget.lead.leadInterestedPropertyId,
      );

      if (propertyResult['statusCode'] == 200 &&
          propertyResult['data'] != null) {
        setState(() {
          _interestedProperty = PropertyModel.fromJson(propertyResult['data']);
        });
      }
    } catch (error) {
      // Handle error silently
    } finally {
      setState(() {
        _isLoadingProperty = false;
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
                Icons.info_outline,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lead Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('First Name', widget.lead.leadFirstName,
              Icons.person_outlined, secondaryTextColor),
          _buildInfoRow('Last Name', widget.lead.leadLastName,
              Icons.person_outlined, secondaryTextColor),
          _buildInfoRow('Email', widget.lead.leadEmail, Icons.email_outlined,
              secondaryTextColor),
          _buildInfoRow('Phone', widget.lead.leadPhoneNumber,
              Icons.phone_outlined, secondaryTextColor),
          _buildInfoRow(
              'Designation',
              LeadDesignation.getLabel(widget.lead.leadDesignation),
              Icons.work_outline,
              secondaryTextColor),
          _buildInfoRow(
              'Status',
              StatusUtils.getLeadStatusDisplayName(widget.lead.leadStatus),
              Icons.info_outline,
              secondaryTextColor),
          _buildInfoRow(
              'Follow Up Status',
              StatusUtils.getFollowUpStatusDisplayName(
                  widget.lead.followUpStatus),
              Icons.update_outlined,
              secondaryTextColor),
          if (widget.lead.leadInterestedPropertyId.isNotEmpty)
            _buildInfoRow(
                'Interested Property ID',
                widget.lead.leadInterestedPropertyId,
                Icons.home_outlined,
                secondaryTextColor),
          if (widget.lead.leadWebsite != null &&
              widget.lead.leadWebsite!.isNotEmpty)
            _buildInfoRow('Website', widget.lead.leadWebsite!,
                Icons.language_outlined, secondaryTextColor),
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
                  value.isNotEmpty ? value : 'N/A',
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
}
