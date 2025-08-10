import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/meeting_schedule_model.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/models/meetingSchedule/MeetingScheduleStatusModel.dart';
import 'package:inhabit_realties/services/meeting_schedule_service.dart';
import 'package:inhabit_realties/controllers/user/userController.dart';
import 'package:inhabit_realties/controllers/role/roleController.dart';
import 'package:inhabit_realties/controllers/meeting_schedule_status/meeting_schedule_status_controller.dart';
import 'package:inhabit_realties/services/property/propertyService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'widgets/meeting_type_container.dart';

class MeetingScheduleUserPage extends StatefulWidget {
  const MeetingScheduleUserPage({super.key});

  @override
  State<MeetingScheduleUserPage> createState() =>
      _MeetingScheduleUserPageState();
}

class _MeetingScheduleUserPageState extends State<MeetingScheduleUserPage>
    with TickerProviderStateMixin {
  final MeetingScheduleService _meetingService = MeetingScheduleService();
  final UserController _userController = UserController();
  final PropertyService _propertyService = PropertyService();
  final RoleController _roleController = RoleController();
  final MeetingScheduleStatusController _meetingScheduleStatusController =
      MeetingScheduleStatusController();

  List<MeetingSchedule> _meetings = [];
  List<MeetingSchedule> _filteredMeetings = [];
  Map<String, UsersModel> _userCache = {};
  Map<String, PropertyModel> _propertyCache = {};
  Map<String, MeetingScheduleStatusModel> _statusCache = {};
  bool _isLoading = true;
  String? _error;
  bool _showScheduledMeetings = false;

  // Meeting type filter
  List<String> _meetingTypes = [
    'ALL',
    'SCHEDULED',
    'COMPLETED',
    'CANCELLED',
    'RESCHEDULED'
  ];
  int _selectedTypeIndex = 0;

  late AnimationController _animationController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _loadMyMeetings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Widget _buildMeetingTypesList() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _meetingTypes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 8,
              right: index == _meetingTypes.length - 1 ? 20 : 8,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTypeIndex = index;
                });
                _filterMeetingsByType();
              },
              child: MeetingTypeContainer(
                isActive: index == _selectedTypeIndex,
                type: _meetingTypes[index],
              ),
            ),
          );
        },
      ),
    );
  }

  void _filterMeetingsByType() {
    print(
        'DEBUG: Filtering meetings by type: ${_meetingTypes[_selectedTypeIndex]}');
    print('DEBUG: Total meetings: ${_meetings.length}');
    print('DEBUG: Status cache keys: ${_statusCache.keys.toList()}');

    setState(() {
      if (_selectedTypeIndex == 0) {
        // Show all meetings
        _filteredMeetings = List.from(_meetings);
        print('DEBUG: Showing all meetings: ${_filteredMeetings.length}');
      } else {
        // Filter by status
        final selectedType = _meetingTypes[_selectedTypeIndex];
        _filteredMeetings = _meetings.where((meeting) {
          // Handle status properly - it can be a string ID or an object
          String statusKey;
          if (meeting.status is Map<String, dynamic>) {
            final statusObj = meeting.status as Map<String, dynamic>;
            statusKey = statusObj['_id'] ?? statusObj['id'] ?? '';
          } else {
            statusKey = meeting.status.toString();
          }
          
          final status = _statusCache[statusKey];
          print(
              'DEBUG: Meeting ${meeting.id} status: ${meeting.status} -> ${status?.name}');
          if (status != null) {
            final matches = status.name.toUpperCase() == selectedType;
            print(
                'DEBUG: Status ${status.name} matches ${selectedType}: $matches');
            return matches;
          }
          return false;
        }).toList();
        print('DEBUG: Filtered meetings count: ${_filteredMeetings.length}');
      }
    });
  }

  Future<void> _loadMyMeetings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = prefs.getString('currentUser');

      if (currentUserJson == null) {
        throw Exception('User not authenticated');
      }

      final currentUserData = jsonDecode(currentUserJson);
      final currentUserId = currentUserData['_id'] ?? currentUserData['id'];
      final currentUserRole = currentUserData['role'];

      if (currentUserId == null) {
        throw Exception('User ID not found in user data');
      }

      // Use getMyMeetings() for customer meetings and getAllMeetings() for scheduled meetings
      List<MeetingSchedule> meetings;
      if (_showScheduledMeetings) {
        // For scheduled meetings, get all meetings and filter by scheduledByUserId
        final allMeetings = await _meetingService.getAllMeetings();
        meetings = allMeetings
            .where((meeting) => meeting.scheduledByUserId == currentUserId)
            .toList();
        print('DEBUG: Total meetings loaded: ${allMeetings.length}');
        print('DEBUG: Filtered scheduled meetings: ${meetings.length}');
      } else {
        // For customer meetings, use the optimized getMyMeetings() method
        meetings = await _meetingService.getMyMeetings();
        print('DEBUG: My meetings loaded: ${meetings.length}');
      }

      setState(() {
        _meetings = meetings;
        _filteredMeetings = List.from(meetings);
        _isLoading = false;
      });

      // Load associated data and then apply current filter
      await _loadAssociatedData();
      _filterMeetingsByType(); // Re-apply the current filter
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAssociatedData() async {
    // First, load all statuses once to populate the cache
    if (_statusCache.isEmpty) {
      try {
        final response = await _meetingScheduleStatusController
            .getAllMeetingScheduleStatuses();
        if (response['statusCode'] == 200 && response['data'] != null) {
          final statuses = (response['data'] as List)
              .map((json) => MeetingScheduleStatusModel.fromJson(json))
              .toList();

          // Populate status cache with all statuses
          for (final status in statuses) {
            _statusCache[status.id] = status;
          }
          print('DEBUG: Loaded ${statuses.length} statuses into cache');
        }
      } catch (e) {
        print('Error loading statuses: $e');
      }
    }

    for (final meeting in _meetings) {
      // Load customer data
      if (!_userCache.containsKey(meeting.customerId)) {
        try {
          final response =
              await _userController.getUsersByUserId(meeting.customerId);
          if (response['statusCode'] == 200 && response['data'] != null) {
            _userCache[meeting.customerId] =
                UsersModel.fromJson(response['data']);
          }
        } catch (e) {
          print('Error loading customer: $e');
        }
      }

      // Load scheduled by user data
      if (!_userCache.containsKey(meeting.scheduledByUserId)) {
        try {
          final response =
              await _userController.getUsersByUserId(meeting.scheduledByUserId);
          if (response['statusCode'] == 200 && response['data'] != null) {
            _userCache[meeting.scheduledByUserId] =
                UsersModel.fromJson(response['data']);
          }
        } catch (e) {
          print('Error loading scheduled by user: $e');
        }
      }

      // Load property data
      if (meeting.propertyId != null &&
          !_propertyCache.containsKey(meeting.propertyId)) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token') ?? "";
          final response = await _propertyService.getPropertyById(
              token, meeting.propertyId!);
          if (response['statusCode'] == 200 && response['data'] != null) {
            _propertyCache[meeting.propertyId!] =
                PropertyModel.fromJson(response['data']);
          }
        } catch (e) {
          print('Error loading property: $e');
        }
      }

      // Handle status properly - it can be a string ID or an object
      String statusKey;
      MeetingScheduleStatusModel? statusModel;
      
      if (meeting.status is Map<String, dynamic>) {
        // Status is an object, extract the ID
        final statusObj = meeting.status as Map<String, dynamic>;
        statusKey = statusObj['_id'] ?? statusObj['id'] ?? '';
        statusModel = MeetingScheduleStatusModel.fromJson(statusObj);
        print('DEBUG: Status is object, key: $statusKey, name: ${statusModel.name}');
      } else {
        // Status is a string ID
        statusKey = meeting.status.toString();
        print('DEBUG: Status is string, key: $statusKey');
      }
      
      if (!_statusCache.containsKey(statusKey)) {
        if (statusModel != null) {
          _statusCache[statusKey] = statusModel;
          print('DEBUG: Added status to cache: ${statusModel.name}');
        } else {
          print('DEBUG: Status not found in cache for $statusKey, adding fallback');
          _statusCache[statusKey] = MeetingScheduleStatusModel(
            id: statusKey,
            name: 'Unknown',
            description: 'Unknown status',
            statusCode: 0,
            createdByUserId: '',
            updatedByUserId: '',
            published: true,
          );
        }
      }
    }
    setState(() {});
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
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

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return '📅';
      case 'completed':
        return '✅';
      case 'cancelled':
        return '❌';
      case 'rescheduled':
        return '🔄';
      default:
        return '📋';
    }
  }

  Widget _buildMeetingCard(MeetingSchedule meeting, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    final customer = _userCache[meeting.customerId];
    final scheduledBy = _userCache[meeting.scheduledByUserId];
    final property =
        meeting.propertyId != null ? _propertyCache[meeting.propertyId!] : null;
    
    // Handle status properly - it can be a string ID or an object
    MeetingScheduleStatusModel? status;
    if (meeting.status is Map<String, dynamic>) {
      final statusObj = meeting.status as Map<String, dynamic>;
      final statusKey = statusObj['_id'] ?? statusObj['id'] ?? '';
      status = _statusCache[statusKey];
    } else {
      status = _statusCache[meeting.status.toString()];
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = _animationController.value;
        final cardAnimation = animationValue > delay
            ? (animationValue - delay) / (1 - delay)
            : 0.0;

        return Transform.translate(
          offset: Offset(0, 30 * (1 - cardAnimation)),
          child: Opacity(
            opacity: cardAnimation,
            child: Transform.scale(
              scale: 0.9 + (0.1 * cardAnimation),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      backgroundColor,
                      backgroundColor.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(meeting.getStatusName())
                          .withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: _getStatusColor(meeting.getStatusName())
                        .withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/meeting_details',
                        arguments: {'meeting': meeting},
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer name section at the top (replacing document ID)
                          if (customer != null)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.lightWarning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.person_crop_circle,
                                    color: AppColors.lightWarning,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${customer.firstName} ${customer.lastName}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        'Customer',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (customer != null) const SizedBox(height: 16),

                          // Property information (replacing document ID)
                          if (property != null)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.lightPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.house,
                                    color: AppColors.lightPrimary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property.name.isNotEmpty
                                            ? property.name
                                            : 'Property',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        'Property',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (property != null) const SizedBox(height: 16),

                          // Header with status and gradient
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getStatusColor(meeting.getStatusName())
                                      .withOpacity(0.1),
                                  _getStatusColor(meeting.getStatusName())
                                      .withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(meeting.getStatusName())
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getStatusIcon(
                                      status?.name ?? meeting.getStatusName()),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  (status?.name ?? meeting.getStatusName())
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(status?.name ??
                                        meeting.getStatusName()),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Meeting title with icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.brandPrimary
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  CupertinoIcons.calendar,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meeting.title.isNotEmpty
                                          ? meeting.title
                                          : 'Untitled Meeting',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      scheduledBy != null
                                          ? 'Scheduled by: ${scheduledBy.firstName} ${scheduledBy.lastName}'
                                          : 'Scheduled by: Unknown',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_right,
                                color: AppColors.brandPrimary,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Date and time
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.brandPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  CupertinoIcons.time,
                                  color: AppColors.brandPrimary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(meeting.meetingDate),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      '${meeting.startTime}${meeting.endTime != null ? ' - ${meeting.endTime}' : ''}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Customer email information
                          if (customer != null)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.lightSuccess.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.mail,
                                    color: AppColors.lightSuccess,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Contact Email',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: textColor.withOpacity(0.6),
                                        ),
                                      ),
                                      Text(
                                        customer.email,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),

                          // Notes section
                          if (meeting.notes.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.lightWarning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.doc_text,
                                    color: AppColors.lightWarning,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    meeting.notes,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor.withOpacity(0.8),
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'My Meetings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  setState(() {
                    _showScheduledMeetings = !_showScheduledMeetings;
                    // Reset filter to "ALL" when switching views
                    _selectedTypeIndex = 0;
                  });

                  // Get current user ID from SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  final currentUserJson = prefs.getString('currentUser');
                  if (currentUserJson != null) {
                    final currentUserData = jsonDecode(currentUserJson);
                    final currentUserId =
                        currentUserData['_id'] ?? currentUserData['id'];
                    if (currentUserId != null) {
                      _loadMyMeetings();
                    }
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showScheduledMeetings
                            ? CupertinoIcons.person_2
                            : CupertinoIcons.calendar,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showScheduledMeetings ? 'Scheduled' : 'My Meetings',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyMeetings,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading your meetings...',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.lightDanger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            color: AppColors.lightDanger,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading meetings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandPrimary,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _loadMyMeetings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildMeetingTypesList(),
                          Expanded(
                            child: _filteredMeetings.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(30),
                                          decoration: BoxDecoration(
                                            gradient: AppColors.brandGradient,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.brandPrimary
                                                    .withOpacity(0.3),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            CupertinoIcons.calendar_badge_plus,
                                            color: Colors.white,
                                            size: 60,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'No meetings found',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _selectedTypeIndex == 0
                                              ? (_showScheduledMeetings
                                                  ? 'You haven\'t scheduled any meetings yet'
                                                  : 'You don\'t have any meetings scheduled')
                                              : 'No ${_meetingTypes[_selectedTypeIndex].toLowerCase()} meetings found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: textColor.withOpacity(0.7),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 100),
                                    itemCount: _filteredMeetings.length,
                                    itemBuilder: (context, index) {
                                      return _buildMeetingCard(
                                          _filteredMeetings[index], index);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPrimary.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                heroTag: 'meeting_user_add_button',
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  Navigator.pushNamed(context, '/create_meeting');
                },
                icon: const Icon(
                  CupertinoIcons.plus,
                  color: Colors.white,
                ),
                label: const Text(
                  'New Meeting',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
