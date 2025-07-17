import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/Enums/leadDesignationEnum.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/pages/widgets/profile_avatar.dart';

class LeadDetailHeader extends StatelessWidget {
  final LeadsModel lead;
  final bool isExpanded;

  const LeadDetailHeader({
    Key? key,
    required this.lead,
    required this.isExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isExpanded ? 0.0 : 1.0,
          child: Text(
            lead.fullName,
            style: const TextStyle(
              color: AppColors.darkWhiteText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
              ),
            ),
            // Lead information when expanded
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isExpanded ? 1.0 : 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // Profile Avatar
                        ProfileAvatar(
                          userId: lead.userId,
                          userName: lead.fullName,
                          size: 60,
                          backgroundColor:
                              AppColors.darkWhiteText.withOpacity(0.2),
                          textColor: AppColors.darkWhiteText,
                          showBorder: true,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lead.fullName,
                                style: const TextStyle(
                                  color: AppColors.darkWhiteText,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lead.leadEmail,
                                style: TextStyle(
                                  color:
                                      AppColors.darkWhiteText.withOpacity(0.8),
                                  fontSize: 14.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.darkWhiteText.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.darkWhiteText
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  LeadDesignation.getLabel(
                                      lead.leadDesignation),
                                  style: const TextStyle(
                                    color: AppColors.darkWhiteText,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Phone',
                            lead.leadPhoneNumber,
                            Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            'Status',
                            lead.leadStatus,
                            Icons.info_outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.darkWhiteText.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkWhiteText.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : 'N/A',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkWhiteText.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
