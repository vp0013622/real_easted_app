import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inhabit_realties/constants/apiUrls.dart';

class FavoritePropertyService {
  // Get auth token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Add property to favorites
  static Future<Map<String, dynamic>> addToFavorites(
      String userId, String propertyId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'statusCode': 401,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiUrls.createFavoriteProperty),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'propertyId': propertyId,
        }),
      );

      final responseData = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': responseData['message'] ?? 'No message',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Error adding to favorites: $e',
      };
    }
  }

  // Remove property from favorites
  static Future<Map<String, dynamic>> removeFromFavorites(
      String userId, String propertyId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'statusCode': 401,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.delete(
        Uri.parse(ApiUrls.deleteFavoriteProperty),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'propertyId': propertyId,
        }),
      );

      final responseData = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': responseData['message'] ?? 'No message',
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Error removing from favorites: $e',
      };
    }
  }

  // Get all favorite properties for a user
  static Future<Map<String, dynamic>> getFavoriteProperties(
      String userId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'statusCode': 401,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiUrls.getFavoritePropertiesByUserId}$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': responseData['message'] ?? 'No message',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Error getting favorite properties: $e',
      };
    }
  }

  // Check if a property is favorited by user
  static Future<Map<String, dynamic>> checkIfFavorited(
      String userId, String propertyId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'statusCode': 401,
          'message': 'Authentication token not found',
          'isFavorited': false,
        };
      }

      final response = await http.post(
        Uri.parse(ApiUrls.getFavoritePropertiesWithParams),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'propertyId': propertyId,
        }),
      );

      final responseData = jsonDecode(response.body);
      final isFavorited =
          responseData['data'] != null && responseData['data'].isNotEmpty;

      return {
        'statusCode': response.statusCode,
        'message': responseData['message'] ?? 'No message',
        'data': responseData['data'],
        'isFavorited': isFavorited,
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Error checking favorite status: $e',
        'isFavorited': false,
      };
    }
  }
}
