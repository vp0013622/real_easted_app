import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/lead/LeadStatusModel.dart';
import 'package:inhabit_realties/models/lead/FollowUpStatusModel.dart';

class StatusUtils {
  static List<LeadStatusModel> _leadStatuses = [];
  static List<FollowUpStatusModel> _followUpStatuses = [];

  // Setter methods to update the status lists
  static void setLeadStatuses(List<LeadStatusModel> statuses) {
    _leadStatuses = statuses;
  }

  static void setFollowUpStatuses(List<FollowUpStatusModel> statuses) {
    _followUpStatuses = statuses;
  }

  // Get lead status display name
  static String getLeadStatusDisplayName(String status) {
    // First try to find the status in the loaded leadStatuses list
    final foundStatus = _leadStatuses.firstWhere(
      (leadStatus) =>
          leadStatus.id == status ||
          leadStatus.name.toLowerCase() == status.toLowerCase(),
      orElse: () => LeadStatusModel(
        id: '',
        name: 'Unknown',
        description: '',
        createdByUserId: '',
        updatedByUserId: '',
        published: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // If found in the list, return the name
    if (foundStatus.name != 'Unknown') {
      return foundStatus.name;
    }

    // Fallback to hardcoded values for backward compatibility
    switch (status.toLowerCase()) {
      case 'hot':
        return 'Hot';
      case 'warm':
        return 'Warm';
      case 'cold':
        return 'Cold';
      case 'new':
        return 'New';
      case 'in progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Get lead status color
  static Color getLeadStatusColor(String status) {
    // First try to find the status in the loaded leadStatuses list
    final foundStatus = _leadStatuses.firstWhere(
      (leadStatus) =>
          leadStatus.id == status ||
          leadStatus.name.toLowerCase() == status.toLowerCase(),
      orElse: () => LeadStatusModel(
        id: '',
        name: 'Unknown',
        description: '',
        createdByUserId: '',
        updatedByUserId: '',
        published: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // If found in the list, use the name for color determination
    final statusName =
        foundStatus.name != 'Unknown' ? foundStatus.name : status;

    // If status is an ObjectId (24 character hex string), return default color
    if (status.length == 24 && RegExp(r'^[a-fA-F0-9]+$').hasMatch(status)) {
      return AppColors.greyColor;
    }

    switch (statusName.toLowerCase()) {
      case 'hot':
        return AppColors.lightDanger;
      case 'warm':
        return AppColors.lightWarning;
      case 'cold':
        return AppColors.greyColor;
      case 'new':
        return AppColors.lightPrimary;
      case 'in progress':
        return AppColors.lightWarning;
      case 'completed':
        return AppColors.lightSuccess;
      case 'pending':
        return AppColors.brandPrimary;
      case 'cancelled':
        return AppColors.lightDanger;
      default:
        return AppColors.greyColor;
    }
  }

  // Get follow-up status display name
  static String getFollowUpStatusDisplayName(String status) {
    // First try to find the status in the loaded followUpStatuses list
    final foundStatus = _followUpStatuses.firstWhere(
      (followUpStatus) =>
          followUpStatus.id == status ||
          followUpStatus.name.toLowerCase() == status.toLowerCase(),
      orElse: () => FollowUpStatusModel(
        id: '',
        name: 'Unknown',
        description: '',
        createdByUserId: '',
        updatedByUserId: '',
        published: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // If found in the list, return the name
    if (foundStatus.name != 'Unknown') {
      return foundStatus.name;
    }

    // Fallback to hardcoded values for backward compatibility
    switch (status.toLowerCase()) {
      case 'new lead':
        return 'New Lead';
      case 'contacted':
        return 'Contacted';
      case 'follow up':
        return 'Follow Up';
      case 'qualified':
        return 'Qualified';
      case 'not interested':
        return 'Not Interested';
      default:
        return 'Unknown';
    }
  }

  // Get follow-up status color
  static Color getFollowUpStatusColor(String status) {
    // First try to find the status in the loaded followUpStatuses list
    final foundStatus = _followUpStatuses.firstWhere(
      (followUpStatus) =>
          followUpStatus.id == status ||
          followUpStatus.name.toLowerCase() == status.toLowerCase(),
      orElse: () => FollowUpStatusModel(
        id: '',
        name: 'Unknown',
        description: '',
        createdByUserId: '',
        updatedByUserId: '',
        published: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // If found in the list, use the name for color determination
    final statusName =
        foundStatus.name != 'Unknown' ? foundStatus.name : status;

    switch (statusName.toLowerCase()) {
      case 'new lead':
        return AppColors.lightPrimary;
      case 'contacted':
        return AppColors.lightWarning;
      case 'follow up':
        return AppColors.brandPrimary;
      case 'qualified':
        return AppColors.lightSuccess;
      case 'not interested':
        return AppColors.lightDanger;
      default:
        return AppColors.greyColor;
    }
  }
}
