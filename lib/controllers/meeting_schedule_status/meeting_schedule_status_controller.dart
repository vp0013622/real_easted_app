import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeetingScheduleStatusController {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> getAllMeetingScheduleStatuses() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Debug: Check current user
      final prefs = await SharedPreferences.getInstance();
      final currentUser = prefs.getString('currentUser');
      print('DEBUG: Current user: $currentUser'); // Debug log
      print('DEBUG: Token length: ${token.length}'); // Debug log
      print('DEBUG: Token: ${token.substring(0, 20)}...'); // Debug log

      final response = await http.get(
        Uri.parse(ApiUrls.getAllMeetingScheduleStatuses),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: Response status: ${response.statusCode}'); // Debug log
      print('DEBUG: Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'statusCode': 200,
          'data': data['data'] ?? [],
        };
      } else {
        throw Exception(
            'Failed to load meeting schedule statuses: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading meeting schedule statuses: $e');
    }
  }

  Future<Map<String, dynamic>> getMeetingScheduleStatusById(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiUrls.getMeetingScheduleStatusById}$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'statusCode': 200,
          'data': data['data'],
        };
      } else {
        throw Exception(
            'Failed to load meeting schedule status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading meeting schedule status: $e');
    }
  }
}
