import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:inhabit_realties/interfaces/auth/authInterface.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';

class AuthService implements AuthInterface {
  @override
  Future<Map<String, dynamic>> login(UsersModel userModel) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.login;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userModel),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "token": data['token'],
          "data": data['data']
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data']
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> register(
      String token, UsersModel userModel) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.register;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userModel),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data']
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data']
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> changePassword(
      String token, String currentPassword, String newPassword) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.changePassword;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data']
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'],
          "data": data['data']
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error
      };
    }
    return result;
  }
}
