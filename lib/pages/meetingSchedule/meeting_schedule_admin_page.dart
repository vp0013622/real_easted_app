import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/meeting_schedule_model.dart';
import 'package:inhabit_realties/services/meeting_schedule_service.dart';
import 'package:inhabit_realties/constants/apiUrls.dart';
import '../widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shimmer/shimmer.dart';
import 'package:inhabit_realties/pages/properties/widgets/property_image_display.dart';
import 'dart:async';

class MeetingScheduleAdminPage extends StatefulWidget {
  const MeetingScheduleAdminPage({super.key});

  @override
  State<MeetingScheduleAdminPage> createState() =>
      _MeetingScheduleAdminPageState();
}

class _MeetingScheduleAdminPageState extends State<MeetingScheduleAdminPage>
    with TickerProviderStateMixin {
  final MeetingScheduleService _meetingService = MeetingScheduleService();
  List<MeetingSchedule> _meetings = [];
  bool _isLoading = true;
  String? _error;

  // Cache for user and property details
  Map<String, Map<String, dynamic>> _userCache = {};
  Map<String, Map<String, dynamic>> _propertyCache = {};

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Timer for checking missed meetings
  Timer? _missedMeetingTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMeetings();
    _startMissedMeetingTimer();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _missedMeetingTimer?.cancel();
    super.dispose();
  }

  void _startMissedMeetingTimer() {
    // Check for missed meetings every 5 minutes
    _missedMeetingTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _checkMissedMeetings();
      }
    });
  }

  Future<void> _checkMissedMeetings() async {
    try {
      await _meetingService.checkAndUpdateMissedMeetings();
      // Refresh the meetings list to show updated statuses
      if (mounted) {
        _loadMeetings();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadMeetings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final meetings = await _meetingService.getAllMeetings();

      // Check and update missed meetings
      await _meetingService.checkAndUpdateMissedMeetings();

      // Load associated data for all meetings
      await _loadAssociatedData(meetings);

      setState(() {
        _meetings = meetings;
        _isLoading = false;
      });

      // Start animation after data is loaded
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAssociatedData(List<MeetingSchedule> meetings) async {
    // Load user and property details for all meetings
    for (final meeting in meetings) {
      // Load customer details
      if (meeting.customerId.isNotEmpty &&
          !_userCache.containsKey(meeting.customerId)) {
        final userDetails =
            await _meetingService.getUserDetails(meeting.customerId);
        if (userDetails != null) {
          _userCache[meeting.customerId] = userDetails;
        }
      }

      // Load scheduled by user details
      if (meeting.scheduledByUserId.isNotEmpty &&
          !_userCache.containsKey(meeting.scheduledByUserId)) {
        final userDetails =
            await _meetingService.getUserDetails(meeting.scheduledByUserId);
        if (userDetails != null) {
          _userCache[meeting.scheduledByUserId] = userDetails;
        }
      }

      // Load property details
      if (meeting.propertyId != null &&
          meeting.propertyId!.isNotEmpty &&
          !_propertyCache.containsKey(meeting.propertyId!)) {
        final propertyDetails =
            await _meetingService.getPropertyDetails(meeting.propertyId!);
        if (propertyDetails != null) {
          _propertyCache[meeting.propertyId!] = propertyDetails;
        }
      }
    }

    // Notify UI to rebuild with loaded data
    if (mounted) {
      setState(() {});
    }
  }

  String _getUserName(String userId) {
    final userDetails = _userCache[userId];
    if (userDetails != null) {
      final firstName = userDetails['firstName'] ?? '';
      final lastName = userDetails['lastName'] ?? '';
      return '${firstName} ${lastName}'.trim();
    }
    return 'User $userId';
  }

  String _getPropertyName(String? propertyId) {
    if (propertyId == null || propertyId.isEmpty) return 'No Property';

    final propertyDetails = _propertyCache[propertyId];
    if (propertyDetails != null) {
      return propertyDetails['name'] ?? 'Property $propertyId';
    }
    return 'Property $propertyId';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        foregroundColor:
            isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
        title: Text(
          'All Meeting Schedules',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.refresh,
              color: AppColors.brandPrimary,
            ),
            onPressed: _loadMeetings,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'meeting_admin_add_button',
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create_meeting');
          if (result == true) {
            _loadMeetings(); // Refresh the list
          }
        },
        backgroundColor: AppColors.brandPrimary,
        elevation: 8,
        child: const Icon(CupertinoIcons.add, color: Colors.white, size: 24),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMeetings,
        color: AppColors.brandPrimary,
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : _meetings.isEmpty
                    ? _buildEmptyState()
                    : _buildMeetingsList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightDanger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 64,
                color: AppColors.lightDanger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Meetings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadMeetings,
              icon: const Icon(CupertinoIcons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.calendar_badge_plus,
                size: 64,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Meetings Scheduled',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create your first meeting schedule to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result =
                    await Navigator.pushNamed(context, '/create_meeting');
                if (result == true) {
                  _loadMeetings();
                }
              },
              icon: const Icon(CupertinoIcons.add),
              label: const Text('Create Meeting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingsList() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _meetings.length,
          itemBuilder: (context, index) {
            final meeting = _meetings[index];
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildMeetingCard(meeting, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMeetingCard(MeetingSchedule meeting, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final borderColor = isDark ? Colors.grey[800] : Colors.grey[200];
    final statusColor = _getStatusColor(meeting.status);

    return GestureDetector(
      onTap: () {
        // Navigate to meeting details page
        Navigator.pushNamed(
          context,
          '/meeting_details',
          arguments: {'meeting': meeting},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              (isDark ? Colors.black : Colors.white).withOpacity(0.95),
            ],
          ),
          border: Border.all(
            color: statusColor.withOpacity(0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey[900] : Colors.grey[50])!
                    .withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: statusColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(meeting.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Schedule Card
            _buildScheduleCard(meeting),

            // Details Card (only if there's content)
            if (meeting.description.isNotEmpty || meeting.notes.isNotEmpty)
              _buildDetailsCard(meeting),

            // People & Property Card
            _buildPeoplePropertyCard(meeting),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.brandPrimary,
            ),
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
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Schedule Card
  Widget _buildScheduleCard(MeetingSchedule meeting) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[50];
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Schedule', CupertinoIcons.calendar),
          const SizedBox(height: 16),

          // Date row
          _buildInfoRow('Date', _formatDate(meeting.meetingDate),
              CupertinoIcons.calendar),

          // Time details all in one row
          Row(
            children: [
              Expanded(
                child: _buildCompactInfoRow(
                    'Start Time', meeting.startTime, CupertinoIcons.time),
              ),
              if (meeting.endTime != null && meeting.endTime!.isNotEmpty) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCompactInfoRow(
                      'End Time', meeting.endTime!, CupertinoIcons.time_solid),
                ),
              ],
              if (meeting.duration != null && meeting.duration!.isNotEmpty) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCompactInfoRow(
                      'Duration', meeting.duration!, CupertinoIcons.clock),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Details Card
  Widget _buildDetailsCard(MeetingSchedule meeting) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[50];
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Details', CupertinoIcons.text_bubble),
          const SizedBox(height: 12),

          // Description and Notes side by side if both exist
          if (meeting.description.isNotEmpty && meeting.notes.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: _buildCompactInfoRow('Description',
                      meeting.description, CupertinoIcons.text_bubble),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCompactInfoRow(
                      'Notes', meeting.notes, CupertinoIcons.doc_text),
                ),
              ],
            ),
          ] else ...[
            if (meeting.description.isNotEmpty)
              _buildInfoRow('Description', meeting.description,
                  CupertinoIcons.text_bubble),
            if (meeting.notes.isNotEmpty)
              _buildInfoRow('Notes', meeting.notes, CupertinoIcons.doc_text),
          ],
        ],
      ),
    );
  }

  // People & Property Card
  Widget _buildPeoplePropertyCard(MeetingSchedule meeting) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[50];
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('People & Property', CupertinoIcons.person_2),
          const SizedBox(height: 12),

          // Customer and Scheduled By side by side
          Row(
            children: [
              Expanded(
                child: _buildCompactPersonRow(
                    'Customer',
                    _getUserName(meeting.customerId),
                    meeting.customerId,
                    CupertinoIcons.person),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactPersonRow(
                    'Scheduled By',
                    _getUserName(meeting.scheduledByUserId),
                    meeting.scheduledByUserId,
                    CupertinoIcons.person_crop_circle),
              ),
            ],
          ),

          // Property with image (full width)
          if (meeting.propertyId != null && meeting.propertyId!.isNotEmpty)
            _buildPropertyRow(meeting.propertyId!),
        ],
      ),
    );
  }

  // Person row with image/initial
  Widget _buildPersonRow(
      String label, String name, String userId, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Avatar/Initial
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Property row with image
  Widget _buildPropertyRow(String propertyId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final propertyName = _getPropertyName(propertyId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Property image using PropertyImageDisplay
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: PropertyImageDisplay(
                propertyId: propertyId,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Property',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  propertyName,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Compact info row for side-by-side layout
  Widget _buildCompactInfoRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Compact person row for side-by-side layout
  Widget _buildCompactPersonRow(
      String label, String name, String userId, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar/Initial
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    String statusText = '';
    if (status is Map<String, dynamic>) {
      statusText = status['name'] ?? '';
    } else {
      statusText = status.toString();
    }

    switch (statusText.toLowerCase()) {
      case 'scheduled':
        return AppColors.lightSuccess;
      case 'completed':
        return AppColors.lightPrimary;
      case 'cancelled':
      case 'canceled':
        return AppColors.lightDanger;
      case 'rescheduled':
        return AppColors.lightWarning;
      case 'missed':
        return AppColors.lightDanger;
      default:
        return AppColors.brandPrimary;
    }
  }

  String _getStatusText(dynamic status) {
    if (status is Map<String, dynamic>) {
      return status['name'] ?? 'Unknown';
    }
    return status.toString();
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return CupertinoIcons.calendar;
      case 'completed':
        return CupertinoIcons.checkmark_circle;
      case 'cancelled':
      case 'canceled':
        return CupertinoIcons.xmark_circle;
      case 'rescheduled':
        return CupertinoIcons.arrow_2_circlepath;
      case 'missed':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.calendar;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
