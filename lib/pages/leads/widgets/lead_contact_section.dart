import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:inhabit_realties/controllers/lead/leadsController.dart';
import '../../widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:provider/provider.dart';

class LeadContactSection extends StatelessWidget {
  final LeadsModel lead;

  const LeadContactSection({Key? key, required this.lead}) : super(key: key);

  Future<void> _callAndMarkContacted(BuildContext context, String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        // After launching the call, update the follow-up status
        final leadsController =
            Provider.of<LeadsController>(context, listen: false);
        // Find the 'Contacted' follow-up status (case-insensitive)
        final contactedStatus = leadsController.followUpStatuses.firstWhere(
          (s) => s.name.toLowerCase() == 'contacted',
          orElse: () => throw Exception('Contacted status not found'),
        );
        // Create a new LeadsModel with updated followUpStatus
        final updatedLead = LeadsModel(
          id: lead.id,
          userId: lead.userId,
          userData: lead.userData,
          leadDesignation: lead.leadDesignation,
          leadInterestedPropertyId: lead.leadInterestedPropertyId,
          leadStatus: lead.leadStatus,
          referanceFrom: lead.referanceFrom,
          followUpStatus: contactedStatus
              .name, // or contactedStatus.id if backend expects id
          referredByUserId: lead.referredByUserId,
          referredByUserFirstName: lead.referredByUserFirstName,
          referredByUserLastName: lead.referredByUserLastName,
          referredByUserEmail: lead.referredByUserEmail,
          referredByUserPhoneNumber: lead.referredByUserPhoneNumber,
          referredByUserDesignation: lead.referredByUserDesignation,
          assignedByUserId: lead.assignedByUserId,
          assignedToUserId: lead.assignedToUserId,
          leadAltEmail: lead.leadAltEmail,
          leadAltPhoneNumber: lead.leadAltPhoneNumber,
          leadLandLineNumber: lead.leadLandLineNumber,
          leadWebsite: lead.leadWebsite,
          note: lead.note,
          createdByUserId: lead.createdByUserId,
          updatedByUserId: lead.updatedByUserId,
          published: lead.published,
          createdAt: lead.createdAt,
          updatedAt: DateTime.now(),
        );
        final result = await leadsController.editLead(updatedLead);
        if (result) {
          AppSnackBar.showSnackBar(
            context,
            'Success',
            'Marked as Contacted',
            ContentType.success,
          );
        } else {
          AppSnackBar.showSnackBar(
            context,
            'Error',
            'Failed to update status',
            ContentType.failure,
          );
        }
      } else {
        AppSnackBar.showSnackBar(
          context,
          'Error',
          'Could not launch dialer',
          ContentType.failure,
        );
      }
    } catch (e) {
      AppSnackBar.showSnackBar(
        context,
        'Error',
        'Error: $e',
        ContentType.failure,
      );
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

    // Check if there's any contact information to show
    final hasContactInfo = lead.leadAltEmail != null ||
        lead.leadAltPhoneNumber != null ||
        lead.leadLandLineNumber != null ||
        lead.leadWebsite != null ||
        lead.leadEmail.isNotEmpty ||
        lead.leadPhoneNumber.isNotEmpty;

    if (!hasContactInfo) {
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
                  Icons.contact_phone_outlined,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
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
                    Icons.contact_phone_outlined,
                    size: 48,
                    color: secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No contact information available',
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
                Icons.contact_phone_outlined,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Contact Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (lead.leadEmail.isNotEmpty)
            _buildInfoRow('Email', lead.leadEmail, Icons.email_outlined,
                secondaryTextColor),
          if (lead.leadPhoneNumber.isNotEmpty)
            _buildPhoneRow(context, 'Phone', lead.leadPhoneNumber,
                Icons.phone_outlined, secondaryTextColor),
          if (lead.leadAltEmail != null)
            _buildInfoRow('Alternative Email', lead.leadAltEmail!,
                Icons.email_outlined, secondaryTextColor),
          if (lead.leadAltPhoneNumber != null)
            _buildPhoneRow(
                context,
                'Alternative Phone',
                lead.leadAltPhoneNumber!,
                Icons.phone_outlined,
                secondaryTextColor),
          if (lead.leadLandLineNumber != null)
            _buildInfoRow('Landline', lead.leadLandLineNumber!,
                Icons.phone_outlined, secondaryTextColor),
          if (lead.leadWebsite != null)
            _buildInfoRow('Website', lead.leadWebsite!, Icons.language_outlined,
                secondaryTextColor),
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

  Widget _buildPhoneRow(BuildContext context, String label, String value,
      IconData icon, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: iconColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.call,
                          color: isDark
                              ? AppColors.darkSuccess
                              : AppColors.lightSuccess,
                          size: 20),
                      tooltip: 'Call',
                      onPressed: () => _callAndMarkContacted(context, value),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
