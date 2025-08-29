import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/notification/notificationController.dart';
import '../../models/notification/NotificationModel.dart';
import '../../constants/contants.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/formTextField.dart';
import '../widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../models/meeting_schedule_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isMultiSelectMode = false;
  Set<String> _selectedNotifications = {};
  String _selectedType = 'All';
  String _selectedStatus = 'Unread'; // Default to show unread first
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingMeeting = false; // Add loading state for meeting details

  final List<String> _notificationTypes = [
    'All',
    'Meeting Schedule',
    'Meeting Reminder',
    'Lead Assignment',
    'Contact Us',
    'General'
  ];

  final List<String> _notificationStatuses = ['Unread', 'Read', 'All'];

  @override
  void initState() {
    super.initState();
    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    // Load notifications when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().getNotifications(refresh: true);
      context.read<NotificationController>().getUnreadCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _isMultiSelectMode
              ? '${_selectedNotifications.length} selected'
              : 'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: _isMultiSelectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                    _selectedNotifications.clear();
                  });
                },
              )
            : null,
        actions: [
          if (!_isMultiSelectMode) ...[
            IconButton(
              onPressed: () {
                context
                    .read<NotificationController>()
                    .getNotifications(refresh: true);
                context.read<NotificationController>().getUnreadCount();
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh notifications',
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isMultiSelectMode = true;
                });
              },
              icon: const Icon(Icons.more_vert),
              tooltip: 'More options',
            ),
          ] else ...[
            if (_selectedNotifications.isNotEmpty) ...[
              IconButton(
                onPressed: () => _markSelectedAsRead(),
                icon: const Icon(Icons.done_all),
                tooltip: 'Mark as read',
              ),
              IconButton(
                onPressed: () => _deleteSelected(),
                icon: const Icon(Icons.delete),
                tooltip: 'Delete selected',
              ),
            ],
          ],
        ],
      ),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.notifications.isEmpty) {
            return Center(
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
                    'Loading your notifications...',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.error != null && controller.notifications.isEmpty) {
            return Center(
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
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      controller.clearError();
                      controller.getNotifications(refresh: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredNotifications =
              _getFilteredNotifications(controller.notifications);

          return Column(
            children: [
              // Search and Filter Section - Always visible
              _buildSearchAndFilterSection(),

              // Notifications List or Empty State
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refreshNotifications(),
                  child: filteredNotifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  CupertinoIcons.bell_slash,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No notifications',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedStatus == 'Unread'
                                    ? 'No unread notifications'
                                    : _selectedStatus == 'Read'
                                        ? 'No read notifications'
                                        : 'You\'re all caught up!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _buildNotificationTile(
                                notification, controller);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(
      NotificationModel notification, NotificationController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    // Different styling for read vs unread notifications
    final isUnread = !notification.isRead;
    final backgroundColor = isUnread
        ? cardColor
        : isDark
            ? cardColor.withOpacity(0.7)
            : cardColor.withOpacity(0.5);

    final borderColor =
        isUnread ? AppColors.brandPrimary.withOpacity(0.3) : Colors.transparent;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.lightDanger,
              AppColors.lightDanger.withOpacity(0.8)
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          CupertinoIcons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) =>
          _showDeleteDialog(context, notification.id),
      onDismissed: (direction) {
        controller.deleteNotification(notification.id);
        AppSnackBar.showSnackBar(
          context,
          'Success',
          'Notification deleted',
          ContentType.success,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.darkShadowColor
                  : AppColors.lightShadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isMultiSelectMode) ...[
                Checkbox(
                  value: _selectedNotifications.contains(notification.id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedNotifications.add(notification.id);
                      } else {
                        _selectedNotifications.remove(notification.id);
                      }
                    });
                  },
                  activeColor: AppColors.brandPrimary,
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: isUnread
                      ? AppColors.brandGradient
                      : LinearGradient(
                          colors: [Colors.grey[400]!, Colors.grey[500]!]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
              color: textColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(isUnread ? 0.9 : 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.time,
                    size: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: isUnread
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                  ),
                )
              : (notification.type == 'meeting_schedule' ||
                          notification.type == 'meeting_reminder') &&
                      _isLoadingMeeting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : null,
          onTap: () => _handleNotificationTap(notification, controller),
          onLongPress: () =>
              _showNotificationOptions(context, notification, controller),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'meeting_schedule':
      case 'meeting_reminder':
        return CupertinoIcons.calendar;
      case 'lead_assignment':
        return CupertinoIcons.person_add;
      case 'contact_us':
        return CupertinoIcons.chat_bubble_2;
      default:
        return CupertinoIcons.bell;
    }
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'meeting_schedule':
      case 'meeting_reminder':
        iconData = Icons.schedule;
        iconColor = Colors.blue;
        break;
      case 'lead_assignment':
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case 'contact_us':
        iconData = Icons.contact_support;
        iconColor = Colors.orange;
        break;
      case 'general':
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  // Multi-select methods
  void _markSelectedAsRead() {
    final controller = context.read<NotificationController>();
    final selectedCount = _selectedNotifications.length;
    for (String notificationId in _selectedNotifications) {
      controller.markAsRead(notificationId);
    }
    setState(() {
      _isMultiSelectMode = false;
      _selectedNotifications.clear();
    });
    AppSnackBar.showSnackBar(
      context,
      'Success',
      '$selectedCount notifications marked as read',
      ContentType.success,
    );
  }

  void _deleteSelected() {
    final controller = context.read<NotificationController>();
    final selectedCount = _selectedNotifications.length;
    for (String notificationId in _selectedNotifications) {
      controller.deleteNotification(notificationId);
    }
    setState(() {
      _isMultiSelectMode = false;
      _selectedNotifications.clear();
    });
    AppSnackBar.showSnackBar(
      context,
      'Success',
      '$selectedCount notifications deleted',
      ContentType.success,
    );
  }

  // Search and filter methods
  Widget _buildSearchAndFilterSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color:
                isDark ? AppColors.darkShadowColor : AppColors.lightShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          FormTextField(
            textEditingController: _searchController,
            labelText: 'Search notifications...',
            prefixIcon: CupertinoIcons.search,
          ),
          const SizedBox(height: 12),

          // Status Filter (Read/Unread/All)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _notificationStatuses.map((status) {
                final isSelected = _selectedStatus == status;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    backgroundColor: isDark
                        ? AppColors.darkCardBackground
                        : AppColors.lightCardBackground,
                    selectedColor: AppColors.brandPrimary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.brandPrimary : textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.brandPrimary
                          : textColor.withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Type Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _notificationTypes.map((type) {
                final isSelected = _selectedType == type;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                    backgroundColor: isDark
                        ? AppColors.darkCardBackground
                        : AppColors.lightCardBackground,
                    selectedColor: AppColors.brandPrimary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.brandPrimary : textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.brandPrimary
                          : textColor.withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<NotificationModel> _getFilteredNotifications(
      List<NotificationModel> notifications) {
    return notifications.where((notification) {
      // Status filter (Read/Unread/All)
      if (_selectedStatus == 'Unread') {
        if (notification.isRead) return false;
      } else if (_selectedStatus == 'Read') {
        if (!notification.isRead) return false;
      }
      // If _selectedStatus is 'All', no filtering needed

      // Type filter
      if (_selectedType != 'All') {
        String notificationType = '';
        switch (notification.type.toLowerCase()) {
          case 'meeting_schedule':
            notificationType = 'Meeting Schedule';
            break;
          case 'meeting_reminder':
            notificationType = 'Meeting Reminder';
            break;
          case 'lead_assignment':
            notificationType = 'Lead Assignment';
            break;
          case 'contact_us':
            notificationType = 'Contact Us';
            break;
          default:
            notificationType = 'General';
        }
        if (notificationType != _selectedType) return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return notification.title.toLowerCase().contains(query) ||
            notification.message.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  Widget _buildLoadMoreButton(NotificationController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton(
          onPressed:
              controller.isLoading ? null : controller.loadMoreNotifications,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Load More'),
        ),
      ),
    );
  }

  void _handleNotificationTap(
      NotificationModel notification, NotificationController controller) async {
    // Handle navigation based on notification type
    switch (notification.type) {
      case 'meeting_schedule':
      case 'meeting_reminder':
        // Navigate to meeting details
        if (notification.relatedId != null) {
          try {
            setState(() {
              _isLoadingMeeting = true;
            });

            // Mark notification as read
            await controller.markAsRead(notification.id);

            // Get meeting details
            final meetingResult = await controller
                .handleMeetingNotificationTap(notification.relatedId!);

            if (meetingResult != null && meetingResult['data'] != null) {
              try {
                // Convert the Map data to MeetingSchedule object
                final meetingData =
                    meetingResult['data'] as Map<String, dynamic>;

                // Validate that we have the required fields
                if (meetingData['_id'] == null ||
                    meetingData['title'] == null) {
                  throw Exception('Missing required meeting fields');
                }

                // Ensure all required fields have fallback values
                final safeMeetingData = {
                  '_id': meetingData['_id'] ?? '',
                  'title': meetingData['title'] ?? '',
                  'description': meetingData['description'] ?? '',
                  'meetingDate': meetingData['meetingDate'] ?? '',
                  'startTime': meetingData['startTime'] ?? '',
                  'endTime': meetingData['endTime'],
                  'duration': meetingData['duration'],
                  'status': meetingData['status'] ?? '',
                  'scheduledByUserId': meetingData['scheduledByUserId'] ?? '',
                  'customerId': meetingData['customerId'] ?? '',
                  'propertyId': meetingData['propertyId'],
                  'notes': meetingData['notes'] ?? '',
                  'createdByUserId': meetingData['createdByUserId'] ?? '',
                  'updatedByUserId': meetingData['updatedByUserId'] ?? '',
                  'published': meetingData['published'] ?? true,
                  'createdAt': meetingData['createdAt'],
                  'updatedAt': meetingData['updatedAt'],
                };

                final meeting = MeetingSchedule.fromJson(safeMeetingData);

                // Navigate to meeting details page
                Navigator.pushNamed(
                  context,
                  '/meeting_details',
                  arguments: {'meeting': meeting},
                );
              } catch (e) {
                // Show error message if conversion fails
                AppSnackBar.showSnackBar(
                  context,
                  'Error',
                  'Invalid meeting data format: ${e.toString()}',
                  ContentType.failure,
                );

                // Log the actual data structure for debugging
                print('Meeting data structure: ${meetingResult['data']}');
                print('Error: $e');
              }
            } else {
              // Show error message
              AppSnackBar.showSnackBar(
                context,
                'Error',
                'Failed to load meeting details',
                ContentType.failure,
              );
            }
          } catch (e) {
            AppSnackBar.showSnackBar(
              context,
              'Error',
              'Error loading meeting details: $e',
              ContentType.failure,
            );
          } finally {
            setState(() {
              _isLoadingMeeting = false;
            });
          }
        }
        break;
      case 'lead_assignment':
        // Navigate to lead details
        // Navigator.pushNamed(context, '/lead-details', arguments: notification.relatedId);
        break;
      case 'contact_us':
        // Navigate to contact details
        // Navigator.pushNamed(context, '/contact-details', arguments: notification.relatedId);
        break;
      default:
        // Show notification details in a dialog
        _showNotificationDetails(context, notification);
        break;
    }
  }

  void _showNotificationDetails(
      BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Text(
              'Type: ${notification.type}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Priority: ${notification.priority}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Created: ${_formatDateTime(notification.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationOptions(BuildContext context,
      NotificationModel notification, NotificationController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              notification.isRead
                  ? Icons.mark_email_unread
                  : Icons.mark_email_read,
            ),
            title:
                Text(notification.isRead ? 'Mark as unread' : 'Mark as read'),
            onTap: () {
              Navigator.pop(context);
              if (notification.isRead) {
                controller.markAsUnread(notification.id);
                AppSnackBar.showSnackBar(
                  context,
                  'Success',
                  'Notification marked as unread',
                  ContentType.success,
                );
              } else {
                controller.markAsRead(notification.id);
                AppSnackBar.showSnackBar(
                  context,
                  'Success',
                  'Notification marked as read',
                  ContentType.success,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, notification.id);
            },
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, String notificationId) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content:
            const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMarkAllReadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text(
            'Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationController>().markAllAsRead();
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
