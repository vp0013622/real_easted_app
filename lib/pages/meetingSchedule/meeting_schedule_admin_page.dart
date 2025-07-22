import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/meeting_schedule_model.dart';
import 'package:inhabit_realties/services/meeting_schedule_service.dart';
import 'package:inhabit_realties/constants/apiUrls.dart';

class MeetingScheduleAdminPage extends StatefulWidget {
  const MeetingScheduleAdminPage({super.key});

  @override
  State<MeetingScheduleAdminPage> createState() =>
      _MeetingScheduleAdminPageState();
}

class _MeetingScheduleAdminPageState extends State<MeetingScheduleAdminPage> {
  final MeetingScheduleService _meetingService = MeetingScheduleService();
  List<MeetingSchedule> _meetings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final meetings = await _meetingService.getAllMeetings();
      setState(() {
        _meetings = meetings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Meeting Schedules'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.question_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/meeting_guide');
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: _loadMeetings,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create_meeting');
          if (result == true) {
            _loadMeetings(); // Refresh the list
          }
        },
        backgroundColor: AppColors.lightPrimary,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMeetings,
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
                        Text(
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
                          onPressed: _loadMeetings,
                          child: Text('Retry'),
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
                            Text(
                              'No meetings found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No meeting schedules have been created yet.',
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: Text('Are you sure you want to delete "${meeting.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _meetingService.deleteMeeting(meeting.id);
                _loadMeetings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meeting deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting meeting: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
