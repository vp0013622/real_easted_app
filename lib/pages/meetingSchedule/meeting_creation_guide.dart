import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';

class MeetingCreationGuide extends StatelessWidget {
  const MeetingCreationGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Creation Guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Admin Section
          _buildRoleSection(
            context,
            'ADMIN',
            'Full Control',
            AppColors.brandPrimary,
            [
              'Can create meetings for any customer',
              'Can assign any property to meetings',
              'Can view all meetings in the system',
              'Can edit and delete any meeting',
              'Can manage meeting statuses',
              'Access to comprehensive meeting analytics',
            ],
            CupertinoIcons.person_3_fill,
          ),
          const SizedBox(height: 16),

          // Executive Section
          _buildRoleSection(
            context,
            'EXECUTIVE',
            'Management Level',
            AppColors.lightWarning,
            [
              'Can create meetings for customers',
              'Can assign properties to meetings',
              'Can view meetings they created',
              'Can edit meetings they created',
              'Can manage their own meeting schedules',
              'Access to team meeting analytics',
            ],
            CupertinoIcons.person_2_fill,
          ),
          const SizedBox(height: 16),

          // Sales Section
          _buildRoleSection(
            context,
            'SALES',
            'Customer Focused',
            AppColors.lightSuccess,
            [
              'Can create meetings for assigned customers',
              'Can schedule property viewings',
              'Can view their own meetings',
              'Can update meeting statuses',
              'Can add meeting notes and follow-ups',
              'Access to customer meeting history',
            ],
            CupertinoIcons.person_fill,
          ),
          const SizedBox(height: 16),

          // User Section
          _buildRoleSection(
            context,
            'USER',
            'Basic Access',
            AppColors.lightPrimary,
            [
              'Can create personal meetings',
              'Can view their own meetings',
              'Can update meeting status',
              'Can add personal notes',
              'Limited to self-scheduled meetings',
              'Basic meeting management',
            ],
            CupertinoIcons.person_crop_circle,
          ),
          const SizedBox(height: 24),

          // How to Create Meetings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.plus_circle_fill,
                        color: AppColors.lightPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'How to Create Meetings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStep('1', 'Navigate to Meeting Schedules',
                      'Go to the drawer menu and select "Meeting Schedules" or "My Meetings" from your profile'),
                  _buildStep('2', 'Tap the + Button',
                      'Click the floating action button (plus icon) to create a new meeting'),
                  _buildStep('3', 'Fill Meeting Details',
                      'Enter the meeting title, description, date, time, and location'),
                  _buildStep('4', 'Select Participants',
                      'Choose customers and properties based on your role permissions'),
                  _buildStep('5', 'Set Status',
                      'Select the initial meeting status (Scheduled, Completed, etc.)'),
                  _buildStep('6', 'Add Notes',
                      'Include any additional notes or special requirements'),
                  _buildStep('7', 'Create Meeting',
                      'Tap "Create Meeting" to save and schedule the meeting'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Meeting Types
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        color: AppColors.lightPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Meeting Types',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMeetingType(
                      'Property Viewing',
                      'Show properties to potential buyers',
                      CupertinoIcons.house_fill),
                  _buildMeetingType(
                      'Client Consultation',
                      'Discuss client requirements and preferences',
                      CupertinoIcons.chat_bubble_2_fill),
                  _buildMeetingType(
                      'Contract Signing',
                      'Finalize property transactions',
                      CupertinoIcons.doc_text_fill),
                  _buildMeetingType(
                      'Follow-up Meeting',
                      'Check on client progress and feedback',
                      CupertinoIcons.arrow_clockwise),
                  _buildMeetingType(
                      'Team Meeting',
                      'Internal team discussions and planning',
                      CupertinoIcons.person_3_fill),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Best Practices
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.lightbulb_fill,
                        color: AppColors.lightWarning,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Best Practices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPractice('Clear Titles',
                      'Use descriptive meeting titles that clearly indicate the purpose'),
                  _buildPractice('Detailed Descriptions',
                      'Include relevant context and objectives in the description'),
                  _buildPractice('Accurate Timing',
                      'Set realistic start and end times for meetings'),
                  _buildPractice('Location Details',
                      'Provide specific location information or meeting links'),
                  _buildPractice('Status Updates',
                      'Regularly update meeting status to keep everyone informed'),
                  _buildPractice('Follow-up Notes',
                      'Add notes after meetings to track outcomes and next steps'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection(
    BuildContext context,
    String role,
    String subtitle,
    Color color,
    List<String> permissions,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...permissions.map((permission) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          permission,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingType(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.lightPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPractice(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.star_fill,
            color: AppColors.lightWarning,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
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
