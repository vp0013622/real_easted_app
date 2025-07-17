import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inhabit_realties/services/dashboard/dashboardService.dart';

class DashboardController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _dashboardData = {};

  // Chart Data
  List<double> _weeklyData = [];
  List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Recent Activities
  List<Map<String, dynamic>> _recentActivities = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboardData => _dashboardData;

  // Get total properties count
  int get totalProperties => _dashboardData['totalProperties'] ?? 0;
  int get soldProperties => _dashboardData['soldProperties'] ?? 0;
  int get unsoldProperties => _dashboardData['unsoldProperties'] ?? 0;
  double get totalSales => (_dashboardData['totalSales'] ?? 0).toDouble();
  int get totalLeads => _dashboardData['totalLeads'] ?? 0;
  int get totalUsers => _dashboardData['totalUsers'] ?? 0;
  int get activeLeads => _dashboardData['activeLeads'] ?? 0;
  int get pendingFollowups => _dashboardData['pendingFollowups'] ?? 0;
  double get averageRating =>
      (_dashboardData['averageRating'] ?? 0.0).toDouble();

  // Chart data getters
  List<double> get weeklyData => _weeklyData;
  List<String> get weekDays => _weekDays;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  // Test method to check token and SharedPreferences
  Future<void> debugTokenAndPreferences() async {
    // This method is kept for compatibility but doesn't print anything
  }

  // Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      _setLoading(true);
      _clearError();

      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final overviewResponse =
          await DashboardService.getDashboardOverview(token);

      if (overviewResponse['statusCode'] == 200) {
        final data = overviewResponse['data'] as Map<String, dynamic>;
        _dashboardData = data;

        // Generate weekly data
        _generateWeeklyData();

        notifyListeners();
      } else {
        throw Exception(
            overviewResponse['message'] ?? 'Failed to load dashboard data');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  // Generate weekly data
  void _generateWeeklyData() {
    final now = DateTime.now();
    _weeklyData = List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));

      // Simulate activity based on day of week
      double baseActivity = 5.0;

      // Weekend effect
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        baseActivity += 2.0;
      }

      // Add some randomness
      baseActivity += (index % 3) * 1.5;

      return baseActivity;
    });
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadDashboardData();
  }

  // Get formatted time ago string
  String getTimeAgo(DateTime dateTime) {
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

  // Get formatted currency string
  String formatCurrencySync(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  // Get percentage change
  String getPercentageChange(int current, int previous) {
    if (previous == 0) return '+100%';
    final change = ((current - previous) / previous) * 100;
    return change >= 0
        ? '+${change.toStringAsFixed(1)}%'
        : '${change.toStringAsFixed(1)}%';
  }
}
