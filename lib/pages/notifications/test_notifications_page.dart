import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/notification/notificationService.dart';
import '../../constants/contants.dart';

class TestNotificationsPage extends StatefulWidget {
  const TestNotificationsPage({Key? key}) : super(key: key);

  @override
  State<TestNotificationsPage> createState() => _TestNotificationsPageState();
}

class _TestNotificationsPageState extends State<TestNotificationsPage> {
  bool _isLoading = false;
  String? _message;
  String? _error;

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('currentUser');
    if (currentUser != null) {
      final userData = jsonDecode(currentUser);
      return userData['_id'];
    }
    return null;
  }

  Future<void> _createTestNotifications() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _error = null;
    });

    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        setState(() {
          _error = 'User not found. Please login again.';
          _isLoading = false;
        });
        return;
      }

      final token = await SharedPreferences.getInstance();
      final authToken = token.getString('token');

      if (authToken == null) {
        setState(() {
          _error = 'Authentication token not found. Please login again.';
          _isLoading = false;
        });
        return;
      }

      final response = await NotificationService.createNotification(
        recipientIds: userId,
        type: 'general',
        title: 'Test Notification',
        message:
            'This is a test notification created at ${DateTime.now().toString()}',
        priority: 'medium',
      );

      if (response['statusCode'] == 201) {
        setState(() {
          _message = 'Test notification created successfully!';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to create test notification';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error creating test notification: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications'),
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Notification System',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This page allows you to create test notifications to verify the notification system is working properly.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTestNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Create Test Notification'),
            ),
            const SizedBox(height: 16),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _message!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Types',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildNotificationTypeInfo('meeting_schedule',
                        'Meeting notifications', Icons.schedule, Colors.blue),
                    _buildNotificationTypeInfo(
                        'lead_assignment',
                        'Lead assignment notifications',
                        Icons.person_add,
                        Colors.green),
                    _buildNotificationTypeInfo(
                        'contact_us',
                        'Contact form notifications',
                        Icons.contact_support,
                        Colors.orange),
                    _buildNotificationTypeInfo(
                        'general',
                        'General notifications',
                        Icons.notifications,
                        Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeInfo(
      String type, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
