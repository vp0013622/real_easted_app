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
        Uri.parse(ApiUrls.getAllMeetingSchedules),
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
        Uri.parse(ApiUrls.getMyMeetings),
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
        Uri.parse(ApiUrls.createMeetingSchedule),
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
        Uri.parse('${ApiUrls.editMeetingSchedule}$id'),
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
        Uri.parse('${ApiUrls.deleteMeetingSchedule}$id'),
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

  // Get all not published meeting schedules (admin only)
  Future<List<MeetingSchedule>> getAllNotPublishedMeetings() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(ApiUrls.getAllNotPublishedMeetingSchedules),
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
        throw Exception('Failed to load not published meetings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading not published meetings: $e');
    }
  }

  // Get meeting schedule by user ID
  Future<MeetingSchedule> getMeetingScheduleByUserId(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiUrls.getMeetingScheduleById}$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MeetingSchedule.fromJson(data['data']);
      } else {
        throw Exception('Failed to load meeting schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading meeting schedule: $e');
    }
  }
}
