import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/meeting_schedule_model.dart';
import 'package:inhabit_realties/controllers/user/userController.dart';
import 'package:inhabit_realties/services/property/propertyService.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MeetingDetailsPage extends StatefulWidget {
  final MeetingSchedule meeting;

  const MeetingDetailsPage({super.key, required this.meeting});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage>
    with TickerProviderStateMixin {
  final UserController _userController = UserController();
  final PropertyService _propertyService = PropertyService();

  UsersModel? _customer;
  UsersModel? _scheduledBy;
  PropertyModel? _property;
  bool _isLoading = true;

  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _loadMeetingDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadMeetingDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load customer data
      if (widget.meeting.customerId.isNotEmpty) {
        try {
          final response =
              await _userController.getUsersByUserId(widget.meeting.customerId);
          if (response['statusCode'] == 200 && response['data'] != null) {
            _customer = UsersModel.fromJson(response['data']);
          }
        } catch (e) {
          print('Error loading customer: $e');
        }
      }

      // Load scheduled by user data
      if (widget.meeting.scheduledByUserId.isNotEmpty) {
        try {
          final response = await _userController
              .getUsersByUserId(widget.meeting.scheduledByUserId);
          if (response['statusCode'] == 200 && response['data'] != null) {
            _scheduledBy = UsersModel.fromJson(response['data']);
          }
        } catch (e) {
          print('Error loading scheduled by user: $e');
        }
      }

      // Load property data
      if (widget.meeting.propertyId != null &&
          widget.meeting.propertyId!.isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token') ?? "";
          final response = await _propertyService.getPropertyById(
              token, widget.meeting.propertyId!);
          if (response['statusCode'] == 200 && response['data'] != null) {
            _property = PropertyModel.fromJson(response['data']);
          }
        } catch (e) {
          print('Error loading property: $e');
        }
      }

      setState(() {
        _isLoading = false;
      });

      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _cardAnimationController.forward();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _cardAnimationController.value)),
          child: Opacity(
            opacity: _cardAnimationController.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor,
                    backgroundColor.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color.withOpacity(0.2),
                                    color.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (onTap != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  CupertinoIcons.chevron_right,
                                  color: color,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        content,
                      ],
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

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
          'Meeting Details',
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
                onTap: () {
                  // TODO: Navigate to edit meeting page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit functionality coming soon!'),
                      backgroundColor: AppColors.brandPrimary,
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.pencil,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(
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
      body: _isLoading
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
                    'Loading meeting details...',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      _buildInfoCard(
                        title: 'Meeting Status',
                        icon: CupertinoIcons.info_circle,
                        color: _getStatusColor(widget.meeting.getStatusName()),
                        content: Row(
                          children: [
                            Text(
                              _getStatusIcon(widget.meeting.getStatusName()),
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.meeting
                                        .getStatusName()
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(
                                          widget.meeting.getStatusName()),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Meeting is ${widget.meeting.getStatusName().toLowerCase()}',
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
                      ),

                      // Meeting Info Card
                      _buildInfoCard(
                        title: 'Meeting Information',
                        icon: CupertinoIcons.calendar,
                        color: AppColors.brandPrimary,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'Title',
                              widget.meeting.title.isNotEmpty
                                  ? widget.meeting.title
                                  : 'Untitled Meeting',
                            ),
                            _buildInfoRow('Meeting ID', widget.meeting.id),
                            _buildInfoRow('Date',
                                _formatDate(widget.meeting.meetingDate)),
                            _buildInfoRow(
                                'Start Time', widget.meeting.startTime),
                            if (widget.meeting.endTime != null)
                              _buildInfoRow(
                                  'End Time', widget.meeting.endTime!),
                            if (widget.meeting.duration != null &&
                                widget.meeting.duration!.isNotEmpty)
                              _buildInfoRow(
                                  'Duration', widget.meeting.duration!),
                          ],
                        ),
                      ),

                      // Customer Card
                      if (_customer != null)
                        _buildInfoCard(
                          title: 'Customer',
                          icon: CupertinoIcons.person,
                          color: AppColors.lightSuccess,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Name',
                                  '${_customer!.firstName} ${_customer!.lastName}'),
                              _buildInfoRow('Email', _customer!.email),
                              _buildInfoRow('Phone', _customer!.phoneNumber),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/user_details',
                              arguments: {'userId': widget.meeting.customerId},
                            );
                          },
                        ),

                      // Scheduled By Card
                      if (_scheduledBy != null)
                        _buildInfoCard(
                          title: 'Scheduled By',
                          icon: CupertinoIcons.person_crop_circle,
                          color: AppColors.brandSecondary,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Name',
                                  '${_scheduledBy!.firstName} ${_scheduledBy!.lastName}'),
                              _buildInfoRow('Email', _scheduledBy!.email),
                              _buildInfoRow('Phone', _scheduledBy!.phoneNumber),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/user_details',
                              arguments: {
                                'userId': widget.meeting.scheduledByUserId
                              },
                            );
                          },
                        ),

                      // Property Card
                      if (_property != null)
                        _buildInfoCard(
                          title: 'Property',
                          icon: CupertinoIcons.home,
                          color: AppColors.lightWarning,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Name', _property!.name),
                              _buildInfoRow('Price', '\$${_property!.price}'),
                              _buildInfoRow('Address', '${_property!.propertyAddress.street}, ${_property!.propertyAddress.city}'),
                              if (_property!.description.isNotEmpty)
                                _buildInfoRow(
                                    'Description', _property!.description),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/property_details',
                              arguments: {'property': _property},
                            );
                          },
                        ),

                      // Notes Card
                      if (widget.meeting.notes.isNotEmpty)
                        _buildInfoCard(
                          title: 'Notes',
                          icon: CupertinoIcons.doc_text,
                          color: AppColors.lightWarning,
                          content: Text(
                            widget.meeting.notes,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _animationController.value)),
            child: Opacity(
              opacity: _animationController.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightWarning,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Implement reschedule functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Reschedule functionality coming soon!'),
                              backgroundColor: AppColors.lightWarning,
                            ),
                          );
                        },
                        child: const Text(
                          'Reschedule',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightDanger,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Implement cancel functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Cancel functionality coming soon!'),
                              backgroundColor: AppColors.lightDanger,
                            ),
                          );
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
