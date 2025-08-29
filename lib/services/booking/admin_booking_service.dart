import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:inhabit_realties/models/booking/purchase_booking_model.dart';
import 'package:inhabit_realties/models/booking/rental_booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminBookingService {
  static String get baseUrl => ApiUrls.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get all purchase bookings (admin/executive only)
  Future<Map<String, dynamic>> getAllPurchaseBookings() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('DEBUG: Token found: ${token.substring(0, 20)}...'); // Debug log
      print('DEBUG: API URL: ${ApiUrls.getAllPurchaseBookings}'); // Debug log
      print(
          'DEBUG: Full URL: ${Uri.parse(ApiUrls.getAllPurchaseBookings)}'); // Debug log

      print('DEBUG: Making HTTP request...'); // Debug log
      final response = await http.get(
        Uri.parse(ApiUrls.getAllPurchaseBookings),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      print('DEBUG: HTTP request completed'); // Debug log

      print('DEBUG: HTTP Status Code: ${response.statusCode}'); // Debug log
      print('DEBUG: Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print('DEBUG: Decoded response: $decodedResponse'); // Debug log
        return decodedResponse;
      } else {
        throw Exception(
            'Failed to load purchase bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Service Exception: $e'); // Debug log
      throw Exception('Error fetching purchase bookings: $e');
    }
  }

  /// Get all rental bookings (admin/executive only)
  Future<Map<String, dynamic>> getAllRentalBookings() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(ApiUrls.getAllRentalBookings),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load rental bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rental bookings: $e');
    }
  }

  /// Get purchase booking by ID
  Future<Map<String, dynamic>> getPurchaseBookingById(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiUrls.getPurchaseBookingById}$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load purchase booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching purchase booking: $e');
    }
  }

  /// Get rental booking by ID
  Future<Map<String, dynamic>> getRentalBookingById(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiUrls.getRentalBookingById}$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load rental booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rental booking: $e');
    }
  }

  /// Confirm a purchase booking (change status to CONFIRMED)
  Future<Map<String, dynamic>> confirmPurchaseBooking(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('${ApiUrls.confirmPurchaseBooking}$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to confirm purchase booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error confirming purchase booking: $e');
    }
  }

  /// Confirm a rental booking (change status to ACTIVE)
  Future<Map<String, dynamic>> confirmRentalBooking(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('${ApiUrls.confirmRentalBooking}$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to confirm rental booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error confirming rental booking: $e');
    }
  }
}
