import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:inhabit_realties/interfaces/role/roleInterface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleService implements RoleInterface {
  @override
  Future<Map<String, dynamic>> getAllRoles(String token) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.getAllRoles;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "count": data['count'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> getRoleById(String roleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.getAllRoles}/$roleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load role');
      }
    } catch (e) {
      throw Exception('Failed to load role: $e');
    }
  }
}
