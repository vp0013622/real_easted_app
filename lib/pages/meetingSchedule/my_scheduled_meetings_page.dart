import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/services/meeting_schedule_service.dart';
import 'package:inhabit_realties/models/meeting_schedule_model.dart';
import 'package:inhabit_realties/pages/widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyScheduledMeetingsPage extends StatefulWidget {
  const MyScheduledMeetingsPage({super.key});

  @override
  State<MyScheduledMeetingsPage> createState() =>
      _MyScheduledMeetingsPageState();
}

class _MyScheduledMeetingsPageState extends State<MyScheduledMeetingsPage> {
  final MeetingScheduleService _meetingService = MeetingScheduleService();
  List<MeetingSchedule> _meetings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyScheduledMeetings();
  }

  Future<void> _loadMyScheduledMeetings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current user ID
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get all meetings and filter by scheduledByUserId
      final allMeetings = await _meetingService.getAllMeetings();
      final myScheduledMeetings = allMeetings
          .where((meeting) => meeting.scheduledByUserId == currentUserId)
          .toList();

      setState(() {
        _meetings = myScheduledMeetings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppColors.brandPrimary;
      case 'completed':
        return AppColors.lightSuccess;
      case 'cancelled':
        return AppColors.lightDanger;
      case 'rescheduled':
        return AppColors.lightWarning;
      default:
        return AppColors.greyColor2;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return CupertinoIcons.calendar;
      case 'completed':
        return CupertinoIcons.checkmark_circle;
      case 'cancelled':
        return CupertinoIcons.xmark_circle;
      case 'rescheduled':
        return CupertinoIcons.arrow_2_circlepath;
      default:
        return CupertinoIcons.calendar;
    }
  }

  void _showDeleteDialog(MeetingSchedule meeting) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Meeting'),
          content: Text(
              'Are you sure you want to delete the meeting "${meeting.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _meetingService.deleteMeeting(meeting.id);
                  AppSnackBar.showSnackBar(
                    context,
                    'Success',
                    'Meeting deleted successfully',
                    ContentType.success,
                  );
                  _loadMyScheduledMeetings(); // Refresh the list
                } catch (e) {
                  AppSnackBar.showSnackBar(
                    context,
                    'Error',
                    'Failed to delete meeting: $e',
                    ContentType.failure,
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scheduled Meetings'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: _loadMyScheduledMeetings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyScheduledMeetings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          size: 64,
                          color: AppColors.lightWarning,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading meetings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.greyColor2),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMyScheduledMeetings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _meetings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.calendar,
                              size: 64,
                              color: AppColors.greyColor2,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No scheduled meetings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You haven\'t scheduled any meetings yet.',
                              style: TextStyle(color: AppColors.greyColor2),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _meetings.length,
                        itemBuilder: (context, index) {
                          final meeting = _meetings[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getStatusColor(meeting.getStatusName()),
                                                                  child: Icon(
                                    _getStatusIcon(meeting.getStatusName()),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                meeting.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${meeting.meetingDate}'),
                                  Text('Start Time: ${meeting.startTime}'),
                                  if (meeting.endTime != null)
                                    Text('End Time: ${meeting.endTime}'),
                                  if (meeting.duration != null &&
                                      meeting.duration!.isNotEmpty)
                                    Text('Duration: ${meeting.duration}'),
                                  Text('Status: ${meeting.getStatusName()}'),
                                  if (meeting.description.isNotEmpty)
                                    Text('Description: ${meeting.description}'),
                                  if (meeting.notes.isNotEmpty)
                                    Text('Notes: ${meeting.notes}'),
                                  Text('Customer ID: ${meeting.customerId}'),
                                  if (meeting.propertyId != null)
                                    Text('Property ID: ${meeting.propertyId}'),
                                  Text(
                                      'Scheduled By: ${meeting.scheduledByUserId}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    // TODO: Implement edit functionality
                                    AppSnackBar.showSnackBar(
                                      context,
                                      'Info',
                                      'Edit functionality coming soon',
                                      ContentType.help,
                                    );
                                  } else if (value == 'delete') {
                                    _showDeleteDialog(meeting);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.pencil),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.delete),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
