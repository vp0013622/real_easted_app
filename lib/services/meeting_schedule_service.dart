import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inhabit_realties/models/meeting_schedule_model.dart';
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeetingScheduleService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<MeetingSchedule>> getAllMeetings() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}/meetingschedule'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> meetingsData = data['data'] ?? [];
        return meetingsData
            .map((json) => MeetingSchedule.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load meetings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading meetings: $e');
    }
  }

  Future<List<MeetingSchedule>> getMyMeetings() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}/meetingschedule/my-meetings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> meetingsData = data['data'] ?? [];
        return meetingsData
            .map((json) => MeetingSchedule.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load my meetings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading my meetings: $e');
    }
  }

  Future<List<MeetingSchedule>> createMeeting(
      Map<String, dynamic> meetingData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}/meetingschedule/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(meetingData),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> meetingsData = data['data'] ?? [];
        return meetingsData
            .map((json) => MeetingSchedule.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to create meeting: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating meeting: $e');
    }
  }

  Future<MeetingSchedule> updateMeeting(
      String id, Map<String, dynamic> meetingData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('${ApiUrls.baseUrl}/meetingschedule/edit/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(meetingData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MeetingSchedule.fromJson(data['data']);
      } else {
        throw Exception('Failed to update meeting: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating meeting: $e');
    }
  }

  Future<void> deleteMeeting(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('${ApiUrls.baseUrl}/meetingschedule/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete meeting: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting meeting: $e');
    }
  }
}
