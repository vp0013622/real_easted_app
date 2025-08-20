import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  static String get baseUrl => ApiUrls.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get user's rental bookings
  Future<Map<String, dynamic>> getMyRentalBookings(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/rental-bookings/my-bookings/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load rental bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rental bookings: $e');
    }
  }

  /// Get user's purchase bookings
  Future<Map<String, dynamic>> getMyPurchaseBookings(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/purchase-bookings/my-bookings/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load purchase bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching purchase bookings: $e');
    }
  }
}
